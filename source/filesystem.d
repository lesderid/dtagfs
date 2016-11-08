module dtagfs.filesystem;

import std.algorithm;
import std.range;
import std.file;
import std.conv;
import std.path;
import std.array;
import std.string;
import std.stdio;

import core.sys.posix.unistd;
import core.stdc.string;
import core.stdc.errno;

import dfuse.fuse;

import dtagfs.tagprovider;

class FileSystem : Operations
{
	private string _source;
	private TagProvider[] _tagProviders;

	private stat_t _sourceStat;

	private string[][string] _tagCache;
	private string[][string] _dirCache;

	private string[] _tagList;
	private string[string] _fileLinkCache;

	this(string source, TagProvider[] tagProviders)
	{
		_source = source;
		_tagProviders = tagProviders;

		lstat(toStringz(source), &_sourceStat);

		cacheTags();
	}

	@property
	TagProvider primaryTagProvider()
	{
		return _tagProviders[0];
	}

	void cacheTags()
	{
		foreach(tagProvider; _tagProviders.filter!(a => a.cacheReads))
		{
			foreach(file; dirEntries(_source, SpanMode.breadth).filter!(a => a.isFile))
			{
				_tagCache[file] ~= tagProvider.getTags(file);

				_fileLinkCache[file.baseName] = file;
			}
		}

		_tagList = _tagCache.byValue()
			.joiner
			.array
			.sort()
			.uniq
			.array;
	}

	override void getattr(const(char)[] path, ref stat_t stat)
	{
		stat.st_uid = _sourceStat.st_uid;
		stat.st_gid = _sourceStat.st_gid;

		if(path == "/" || isTag(path.baseName))
		{
			stat.st_mode = _sourceStat.st_mode;
		}
		else if(isFile(path.baseName))
		{
			stat.st_mode = S_IFLNK | octal!777;
			stat.st_nlink = 1;
		}
		else
		{
			throw new FuseException(ENOENT);
		}
	}

	bool isTag(const(char)[] name)
	{
		return _tagList.canFind(name);
	}

	bool isFile(const(char)[] name)
	{
		return (name in _fileLinkCache) !is null;
	}

	string findFile(const(char)[] name)
	{
		if(!isFile(name))
		{
			return null;
		}

		return _fileLinkCache[name];
	}

	string[] getTags(const(char)[] path)
	{
		if(path == "/")
		{
			return _tagList;
		}
		else
		{
			auto tags = pathSplitter(path).array[1..$];

			return _tagCache.byKeyValue()
				.filter!(a => tags.all!(b => a.value.canFind(b)))
				.map!(a => a.value)
				.joiner
				.filter!(a => !tags.canFind(a))
				.array
				.sort()
				.uniq
				.array;
		}
	}

	string[] getFiles(const(char)[] path)
	{
		if(path == "/")
		{
			return _tagCache.keys.map!(a => a.baseName).array;
		}
		else
		{
			auto tags = pathSplitter(path).array[1..$];

			return _tagCache.byKeyValue()
				.filter!(a => tags.all!(b => a.value.canFind(b)))
				.map!(a => a.key.baseName)
				.array;
		}
	}

	override ulong readlink(const(char)[] path, ubyte[] buf)
	{
		auto realPath = findFile(path.baseName);
		if(realPath is null)
		{
			throw new FuseException(ENOENT);
		}

		strncpy(cast(char*)buf, cast(char*)realPath.toStringz, realPath.length);

		return realPath.length;
	}

	override string[] readdir(const(char)[] path)
	{
		if(path in _dirCache)
		{
			return _dirCache[path];
		}

		//TODO: Don't return tags if only one file (or files with exactly the same set of tags)?
		if (path == "/")
		{
			return _dirCache[path] = getTags(path) ~ getFiles(path);
		}
		else
		{
			return _dirCache[path] = getTags(path) ~ getFiles(path) ~ [".", ".."];
		}
	}
}

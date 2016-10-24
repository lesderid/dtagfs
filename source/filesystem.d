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

import dfuse.fuse;

import dtagfs.tagprovider;

class FileSystem : Operations
{
	private string _source;
	private TagProvider[] _tagProviders;

	private string[][string] _tagCache;

	private stat_t _sourceStat;

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
			}
		}
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
			auto file = findFile(path.baseName);
			lstat(toStringz(file), &stat);
		}
		else
		{
			throw new FuseException(errno.ENOENT);
		}
	}

	bool isTag(const(char)[] name)
	{
		return _tagCache.values.any!(a => a.canFind(name));
	}

	bool isFile(const(char)[] name)
	{
		return _tagCache.keys.any!(a => a.baseName == name);
	}

	string findFile(const(char)[] name)
	{
		if(!isFile(name))
		{
			return null;
		}

		return _tagCache.keys.filter!(a => indexOf(a, name) != -1).array[0];
	}

	string[] getTags(const(char)[] path)
	{
		if(path == "/")
		{
			return _tagCache.byValue()
				.joiner
				.array
				.sort()
				.uniq
				.array;
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


	override string[] readdir(const(char)[] path)
	{
		//TODO: Don't return tags if only one file (or files with exactly the same set of tags) files?
		if (path == "/")
		{
			return getTags(path) ~ getFiles(path);
		}
		else
		{
			return getTags(path) ~ getFiles(path) ~ [".", ".."];
		}
	}

	override ulong read(const(char)[] path, ubyte[] buf, ulong offset)
    {
		auto realPath = findFile(path.baseName);
		if(realPath is null)
		{
			throw new FuseException(errno.ENOENT);
		}

		auto file = File(realPath, "r");
		file.seek(offset);
		auto bytesRead = file.rawRead(buf).length;
		file.close();

		return bytesRead;
    }
}

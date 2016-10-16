module dtagfs.filesystem;

import std.algorithm;
import std.range;
import std.file;
import std.conv;
import std.path;
import std.array;

import dfuse.fuse;

import dtagfs.tagprovider;

class FileSystem : Operations
{
	private string _source;
	private TagProvider[] _tagProviders;

	private string[][string] _tagCache;

	this(string source, TagProvider[] tagProviders)
	{
		_source = source;
		_tagProviders = tagProviders;

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
		if(path == "/" || isTag(path.baseName))
		{
			stat.st_mode = S_IFDIR | octal!700;
			stat.st_size = 0;
			return;
		}
		else if(isFile(path.baseName))
		{
			stat.st_mode = S_IFREG | octal!700;
			stat.st_size = 42;
			return;
		}

		throw new FuseException(errno.ENOENT);
	}

	bool isTag(const(char)[] name)
	{
		return _tagCache.values.any!(a => a.canFind(name));
	}

	bool isFile(const(char)[] name)
	{
		return _tagCache.keys.any!(a => a.baseName == name);
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
		return getTags(path) ~ getFiles(path);
	}
}

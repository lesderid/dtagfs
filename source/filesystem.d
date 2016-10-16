module dtagfs.filesystem;

import std.algorithm;
import std.range;
import std.file;
import std.conv;

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
		if(path == "/")
		{
			stat.st_mode = S_IFDIR | octal!755;
			stat.st_size = 0;
			return;
		}

		throw new FuseException(errno.ENOENT);
	}

	override string[] readdir(const(char)[] path)
	{
		return _tagCache.byValue()
			.joiner
			.array
			.sort()
			.uniq
			.array;
	}
}

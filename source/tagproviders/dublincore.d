module dtagfs.dublincore;

import std.process;
import std.string;
import std.algorithm;
import std.array;

import dtagfs.tagprovider;

class DublinCoreTagProvider : TagProvider
{
	override string[] getTags(string path)
	{
		//TODO: Make prefixes configurable

		string[] tags;

		tags ~= map!(a => a)(getElementData!"Subject"(path)).array;
		tags ~= map!(a => "copyright:" ~ a)(getElementData!"Rights"(path)).array;
		tags ~= map!(a => "relation:" ~ a)(getElementData!"Relation"(path)).array;
		tags ~= map!(a => "type:" ~ a)(getElementData!"Type"(path)).array;

		return tags;
	}

	string[] getElementData(string element)(string path)
	{
		//TODO: Use a proper metadata library instead of exiftool

		auto exiftool = execute(["exiftool", "-b", "-" ~ element, path]);
		auto rawData = exiftool.output;

		return splitLines(rawData);
	}

	@property
	override bool cacheReads()
	{
		return true;
	}
}


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

		std.stdio.writeln(path);

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

		string[] data;
		foreach(line; splitLines(rawData))
		{
			if(indexOf(line, ' ') == -1)
			{
				data ~= line;
			}
			else
			{
				data ~= '"' ~ line ~ '"';
			}
		}

		return data;
	}

	@property
	override bool cacheReads()
	{
		return true;
	}
}

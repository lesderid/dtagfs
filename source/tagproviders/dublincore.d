module dtagfs.dublincore;

import std.process;
import std.string;
import std.algorithm;
import std.array;
import std.stdio;

import exempi.xmp;
import exempi.xmpconsts;

import dtagfs.tagprovider;

class DublinCoreTagProvider : TagProvider
{
	private XmpPtr _xmp;

	override string[] getTags(string path)
	{
		//TODO: Make prefixes configurable

		string[] tags;

		tags ~= getElementData!"subject"(path).map!(a => a).array;
		tags ~= getElementData!"rights"(path).map!(a => "copyright:" ~ a).array;
		tags ~= getElementData!"relation"(path).map!(a => "relation:" ~ a).array;
		tags ~= getElementData!"type"(path).map!(a => "type:" ~ a).array;

		return tags;
	}

	string[] getElementData(string element)(string path)
	{
		string[] data;

		auto file = xmp_files_open_new(path.toStringz(), XmpOpenFileOptions.XMP_OPEN_READ);

		xmp_files_get_xmp(file, _xmp);

		auto iterator = xmp_iterator_new(_xmp, NS_DC.ptr, element, XmpIterOptions.XMP_ITER_JUSTLEAFNODES);

		auto property = xmp_string_new();
		while(xmp_iterator_next(iterator, null, null, property, null))
		{
			auto propertyString = fromStringz(xmp_string_cstr(property)).dup;
			if(propertyString != "x-default")
			{
				data ~= propertyString.idup;
			}
		}
		xmp_string_free(property);

		xmp_iterator_free(iterator);

		xmp_files_free(file);

		return data;
	}

	this()
	{
		xmp_init();

		_xmp = xmp_new_empty();
	}

	~this()
	{
		xmp_free(_xmp);

		xmp_terminate();
	}

	@property
	override bool cacheReads()
	{
		return true;
	}
}


module dtagfs.app;

import std.stdio;
import std.getopt;
import std.array;

import dfuse.fuse;

import dtagfs.filesystem;
import dtagfs.tagprovider;

void main(string[] args)
{
	//TODO: Make tag provider(s) configurable

	if(args.length < 2)
	{
		stderr.writeln("usage: dtagfs <source> <mount point> [-f] [-o option[,options...]]");
		return;
	}

	auto source = args[0];
	auto mountPoint = args[1];

	TagProvider[] tagProviders;

	string[] mountOptions;
	bool fork;
	arraySep = ",";
	auto otherArgs = args[2..$];
	auto options = getopt(
		otherArgs,

		"o", &mountOptions,
		"f|fork", &fork
	);

	auto filesystem = mount(source, mountPoint, tagProviders, mountOptions, fork);
}

FileSystem mount(string source, string mountPoint, TagProvider[] tagProviders, string[] options, bool fork)
{
	auto filesystem = new FileSystem(source, tagProviders);

	auto fuse = new Fuse("dtagfs", !fork, false);
	fuse.mount(filesystem, mountPoint, options);

	return filesystem;
}


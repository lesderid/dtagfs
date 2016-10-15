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

	if(args.length < 3)
	{
		stderr.writeln("usage: dtagfs <source> <mount point> [-f] [-o option[,options...]]");
		return;
	}

	auto source = args[1];
	auto mountPoint = args[2];

	TagProvider[] tagProviders;

	string[] mountOptions;
	bool fork;
	arraySep = ",";
	auto options = getopt(
		args,

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


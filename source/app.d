module dtagfs.app;

import std.stdio;
import std.getopt;
import std.array;

import dfuse.fuse;

import dtagfs.filesystem;
import dtagfs.tagprovider;
import dtagfs.dublincore;

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

	TagProvider[] tagProviders = [new DublinCoreTagProvider()];

	string[] mountOptions;
	bool foreground;
	arraySep = ",";
	auto options = getopt(
		args,

		"o", &mountOptions,
		"f|foreground", &foreground
	);

	auto filesystem = mount(source, mountPoint, tagProviders, mountOptions, foreground);
}

FileSystem mount(string source, string mountPoint, TagProvider[] tagProviders, string[] options, bool foreground)
{
	auto filesystem = new FileSystem(source, tagProviders);

	auto fuse = new Fuse("dtagfs", foreground, false);
	fuse.mount(filesystem, mountPoint, options);

	return filesystem;
}


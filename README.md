# dtagfs
dtagfs is a FUSE file system that mounts a directory with tagged files as a file system tree.

This allows for easy filtering of tagged files (e.g. '/mountpoint/tag1/tag2/' contains all files with tags 'tag1' and 'tag2').

## Example
See [example.md](example.md).

## Usage
`usage: dtagfs <source> <mount point> [-f] [-o option[,options...]]`

-f: fork to background

## Supported tag sources
* Dublin Core (XMP), via [exempi-d](https://github.com/lesderid/exempi-d)

## License
dtags is released under the [University of Illinois/NCSA license](LICENSE).

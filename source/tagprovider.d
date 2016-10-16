module dtagfs.tagprovider;

interface TagProvider
{
	string[] getTags(string path);

	@property
	bool cacheReads();
}

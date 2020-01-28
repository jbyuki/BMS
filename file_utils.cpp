#include "file_utils.h"

auto same_directory_as(const std::string& filename, const std::string& ref_filename) -> std::string
{
	auto dir = std::experimental::filesystem::path(ref_filename).parent_path();
	auto fn = std::experimental::filesystem::path(filename);
	return (dir / fn).generic_string();
}

auto replace_extension(const std::string& filename, const std::string& extension) -> std::string
{
	return filename.substr(0, filename.size()-4) + extension;
}

auto file_exists(const std::string& filename) -> bool
{
	std::ifstream in(filename);
	return in.good();
}


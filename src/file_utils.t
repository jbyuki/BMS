@file_utils.h=
#pragma once
@includes

@functions

@file_utils.cpp=
#include "file_utils.h"

@define_functions

@includes=
#include <string>

@functions=
auto same_directory_as(const std::string& filename, const std::string& ref_filename) -> std::string;

@includes+=
#include <filesystem>

@define_functions=
auto same_directory_as(const std::string& filename, const std::string& ref_filename) -> std::string
{
	auto dir = std::experimental::filesystem::path(ref_filename).parent_path();
	auto fn = std::experimental::filesystem::path(filename);
	return (dir / fn).generic_string();
}

@functions+=
auto replace_extension(const std::string& filename, const std::string& extension) -> std::string;

@define_functions+=
auto replace_extension(const std::string& filename, const std::string& extension) -> std::string
{
	return filename.substr(0, filename.size()-4) + extension;
}

@functions+=
auto file_exists(const std::string& filename) -> bool;

@includes+=
#include <fstream>

@define_functions+=
auto file_exists(const std::string& filename) -> bool
{
	std::ifstream in(filename);
	return in.good();
}

#pragma once
#include <string>

#include <filesystem>

#include <fstream>


auto same_directory_as(const std::string& filename, const std::string& ref_filename) -> std::string;

auto replace_extension(const std::string& filename, const std::string& extension) -> std::string;

auto file_exists(const std::string& filename) -> bool;



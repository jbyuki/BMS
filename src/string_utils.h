#pragma once
#include <cctype>
#include <algorithm>
#include <string>

#include <array>


auto str_tolower(std::string s) -> std::string;

auto zz_tonum(const std::array<char, 2>& a) -> unsigned;

auto trim(const std::string& s) -> std::string;



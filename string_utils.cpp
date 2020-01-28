#include "string_utils.h"

auto str_tolower(std::string s) -> std::string
{
	std::transform(s.begin(), s.end(), s.begin(), 
		[](unsigned char c) { return std::tolower(c); });
	return s;
}

auto zz_tonum(const std::array<char, 2>& a) -> unsigned
{
	unsigned result = 0;
	for(char c : a) {
		result *= (26+10);
		result += c >= '0' && c <= '9' ? (unsigned)(c - '0') : (unsigned)(c - 'A')+10;
	}
	return result;
}


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

auto trim(const std::string& s) -> std::string
{
	unsigned i1 = 0, i2 = s.size();
	for(; i1<s.size() && std::isspace(s[i1]); ++i1);
	for(; i2>i1 && std::isspace(s[i2-1]); --i2);
	return s.substr(i1, i2-i1);
}


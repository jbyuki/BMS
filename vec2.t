@vec2.h=
#pragma once

template<typename T>
struct Vec2
{
	@methods
	@member_data
};

@type_aliases

@member_data=
T x, y;

@methods=
Vec2(const T& x = (T)0, const T& y = (T)0) :
	x(x), y(y)
{
}

@type_aliases=
using Vec2f = Vec2<float>;

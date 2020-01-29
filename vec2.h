#pragma once

template<typename T>
struct Vec2
{
	Vec2(const T& x = (T)0, const T& y = (T)0) :
		x(x), y(y)
	{
	}
	
	T x, y;
	
};

using Vec2f = Vec2<float>;


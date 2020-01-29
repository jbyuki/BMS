@font_utils.h=
#pragma once
@includes

@functions

@font_utils.cpp=
#include "font_utils.h"

@define_functions

@includes=
#include <string>
#include <memory>
#include <SDL.h>
#include "vec2.h"
#include <SDL_ttf.h>
#include "texture_utils.h"

@functions=
auto renderText(const std::string& s, TTF_Font* font, SDL_Renderer* renderer) -> std::shared_ptr<Texture>;

@define_functions=
auto renderText(const std::string& s, TTF_Font* font, SDL_Renderer* renderer) -> std::shared_ptr<Texture>
{
	@render_text
	@fill_size
	@create_texture
	@destroy_sdl_surface

	return tex;
}

@includes+=
#include <iostream>

@render_text=
static SDL_Color white = {255, 255, 255};
SDL_Surface* surf = TTF_RenderUTF8_Blended(font, s.c_str(), white);
if(!surf) {
	std::cerr << "ERROR(renderText): " << TTF_GetError() << std::endl;
	return nullptr;
}

@fill_size=
auto tex = std::make_shared<Texture>();
tex->w = surf->w;
tex->h = surf->h;

@create_texture=
tex->tex = SDL_CreateTextureFromSurface(renderer, surf);
if(!tex->tex) {
	std::cerr << "ERROR(renderText): " << SDL_GetError() << std::endl;
	return nullptr;
}

@destroy_sdl_surface=
SDL_FreeSurface(surf);

@includes+=
#include <array>

@functions+=
auto writeNumber(Vec2i pos, int num, const std::array<std::shared_ptr<Texture>, 10>& numbers, SDL_Renderer* renderer) -> void;

@define_functions+=
auto writeNumber(Vec2i pos, int num, const std::array<std::shared_ptr<Texture>, 10>& numbers, SDL_Renderer* renderer) -> void
{
	static std::array<int, 20> digits;
	int ni = 0;
	while(num > 0) {
		@save_digit
		num /= 10;
	}

	@if_ni_zero_add_zero

	for(int i=ni-1; i>=0; --i) {
		@draw_digit
		@advance_x
	}
}

@save_digit=
digits[ni++] = num%10;

@if_ni_zero_add_zero=
if(ni == 0) {
	digits[ni++] = 0;
}

@draw_digit=
auto t = numbers[digits[i]];

SDL_Rect dst;
dst.x = pos.x;
dst.y = pos.y;
dst.w = t->w;
dst.h = t->h;

SDL_RenderCopy(renderer, t->tex, nullptr, &dst);

@advance_x=
pos.x += t->w;

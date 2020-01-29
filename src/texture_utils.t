@texture_utils.h=
#pragma once
@includes

@tex_struct
@functions

@texture_utils.cpp=
#include "texture_utils.h"

@define_functions

@includes=
#include <string>
#include <SDL.h>

@tex_struct=
struct Texture
{
	int w, h;
	SDL_Texture* tex = nullptr;
	@texture_destructor
};

@texture_destructor=
~Texture();

@define_functions=
Texture::~Texture()
{
	if(tex) {
		SDL_DestroyTexture(tex);
	}
}

@includes+=
#include <memory>

@functions=
auto loadTexture(SDL_Renderer* renderer, const std::string& filename) -> std::shared_ptr<Texture>;

@includes+=
#include <SDL_image.h>
#include <iostream>

@define_functions+=
auto loadTexture(SDL_Renderer* renderer, const std::string& filename) -> std::shared_ptr<Texture>
{
	auto tex = std::make_shared<Texture>();
	tex->tex = IMG_LoadTexture(renderer, filename.c_str());
	if(!tex->tex) {
		std::cerr << "ERROR(loadTexture): Could not load " << filename << std::endl;
	}
	SDL_QueryTexture(tex->tex, NULL, NULL, &tex->w,  &tex->h);
	return tex;
}

@includes+=
#include "vec2.h"

@functions+=
auto drawTexture(SDL_Renderer* renderer, Vec2i pos, std::shared_ptr<Texture> tex) -> void;

@define_functions+=
auto drawTexture(SDL_Renderer* renderer, Vec2i pos, std::shared_ptr<Texture> tex) -> void
{
	SDL_Rect rc;
	rc.x = pos.x;
	rc.y = pos.y;
	rc.w = tex->w;
	rc.h = tex->h;

	SDL_RenderCopy(renderer, tex->tex, nullptr, &rc);
}

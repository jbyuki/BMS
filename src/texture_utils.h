#pragma once
#include <string>
#include <SDL.h>

#include <memory>

#include <SDL_image.h>

#include "vec2.h"


struct Texture
{
	int w, h;
	SDL_Texture* tex = nullptr;
	~Texture();
	
};

auto loadTexture(SDL_Renderer* renderer, const std::string& filename) -> std::shared_ptr<Texture>;

auto drawTexture(SDL_Renderer* renderer, Vec2i pos, std::shared_ptr<Texture> tex) -> void;



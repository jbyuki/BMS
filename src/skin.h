#pragma once
#include <string>
#include <memory>
#include <SDL.h>

#include <fstream>

#include "string_utils.h"
#include "file_utils.h"

#include <SDL_image.h>
#include <iostream>


struct Skin
{
	SDL_Texture* note = nullptr;
	
	~Skin();
	
};

auto loadSkin(const std::string& filename, SDL_Renderer* renderer, std::shared_ptr<Skin> s) -> bool;



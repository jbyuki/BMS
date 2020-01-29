#pragma once
#include <string>
#include <memory>
#include <SDL.h>

#include <fstream>

#include "string_utils.h"
#include "file_utils.h"

#include <SDL_image.h>
#include <iostream>
#include "texture_utils.h"


struct Skin
{
	std::shared_ptr<Texture> note = nullptr;
	
	std::shared_ptr<Texture> hit = nullptr;
	
	std::shared_ptr<Texture> scratch = nullptr;
	
	std::shared_ptr<Texture> hit_scratch = nullptr;
	
	std::shared_ptr<Texture> note_odd = nullptr;
	
	std::shared_ptr<Texture> judgment = nullptr;
	
};

auto loadSkin(const std::string& filename, SDL_Renderer* renderer, std::shared_ptr<Skin> s) -> bool;



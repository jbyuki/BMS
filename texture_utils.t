@texture_utils.h=
#pragma once
@includes

@functions

@texture_utils.cpp=
#include "texture_utils.h"

@define_functions

@includes=
#include <string>
#include <SDL.h>

@functions=
auto loadTexture(const std::string& filename) -> SDL_Texture*;

@define_functions=
auto loadTexture(const std::string& filename) -> SDL_Texture*
{
	
}

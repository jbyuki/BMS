#pragma once
#include <string>
#include <memory>
#include <SDL.h>
#include "vec2.h"
#include <SDL_ttf.h>
#include "texture_utils.h"

#include <iostream>

#include <array>


auto renderText(const std::string& s, TTF_Font* font, SDL_Renderer* renderer) -> std::shared_ptr<Texture>;

auto writeNumber(Vec2i pos, int num, const std::array<std::shared_ptr<Texture>, 10>& numbers, SDL_Renderer* renderer) -> void;



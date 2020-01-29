@skin.h=
#pragma once
@includes

struct Skin
{
	@skin_data
};

@functions

@skin.cpp=
#include "skin.h"

@define_functions

@includes=
#include <string>
#include <memory>
#include <SDL.h>

@functions=
auto loadSkin(const std::string& filename, SDL_Renderer* renderer, std::shared_ptr<Skin> s) -> bool;

@define_functions=
auto loadSkin(const std::string& filename, SDL_Renderer* renderer, std::shared_ptr<Skin> s) -> bool
{
	@open_file
	@read_line_by_line

	return true;
}

@includes+=
#include <fstream>

@open_file=
std::ifstream in(filename);
if(!in.is_open()) {
	std::cerr << "ERROR(loadSkin): Could not open " << filename << std::endl;
	return false;
}

@read_line_by_line=
std::string line;
while(std::getline(in, line)) {
	@skip_empty_line
	@parse_line
	@read_line
}

@skip_empty_line=
if(line.size() == 0 && line.find(':') == std::string::npos) {
	continue;
}


@includes+=
#include "string_utils.h"
#include "file_utils.h"

@parse_line=
int p = line.find(':');
if(p == std::string::npos) {
	std::cerr << "ERROR(loadSkin): Unrecognized line " << line << std::endl;
	continue;
}

std::string left = str_tolower(trim(line.substr(0, p)));
std::string right = trim(line.substr(p+1));
std::string fn = same_directory_as(right, filename);

@includes+=
#include <SDL_image.h>
#include <iostream>
#include "texture_utils.h"

@skin_data=
std::shared_ptr<Texture> note = nullptr;

@read_line=
if(left == "note") { s->note = loadTexture(renderer, fn); } 

@skin_data+=
std::shared_ptr<Texture> hit = nullptr;

@read_line+=
if(left == "hit") { s->hit = loadTexture(renderer, fn); }

@skin_data+=
std::shared_ptr<Texture> scratch = nullptr;

@read_line+=
if(left == "scratch") { s->scratch = loadTexture(renderer, fn); }

@skin_data+=
std::shared_ptr<Texture> hit_scratch = nullptr;

@read_line+=
if(left == "hit-scratch") { s->hit_scratch = loadTexture(renderer, fn); }

@skin_data+=
std::shared_ptr<Texture> note_odd = nullptr;

@read_line+=
if(left == "note-odd") { s->note_odd = loadTexture(renderer, fn); }

@skin_data+=
std::shared_ptr<Texture> judgment = nullptr;

@read_line+=
if(left == "judgment") { s->judgment = loadTexture(renderer, fn); }

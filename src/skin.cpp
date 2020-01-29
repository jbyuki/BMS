#include "skin.h"

auto loadSkin(const std::string& filename, SDL_Renderer* renderer, std::shared_ptr<Skin> s) -> bool
{
	std::ifstream in(filename);
	if(!in.is_open()) {
		std::cerr << "ERROR(loadSkin): Could not open " << filename << std::endl;
		return false;
	}
	
	std::string line;
	while(std::getline(in, line)) {
		if(line.size() == 0 && line.find(':') == std::string::npos) {
			continue;
		}
		
		
		int p = line.find(':');
		if(p == std::string::npos) {
			std::cerr << "ERROR(loadSkin): Unrecognized line " << line << std::endl;
			continue;
		}
		
		std::string left = str_tolower(trim(line.substr(0, p)));
		std::string right = trim(line.substr(p+1));
		std::string fn = same_directory_as(right, filename);
		
		if(left == "note") {
			if((s->note = IMG_LoadTexture(renderer, fn.c_str())) == nullptr) {
				std::cerr << "ERROR(loadSkin): Could not load " << fn << std::endl;
			}
		}
		
	}
	

	return true;
}

Skin::~Skin()
{
	if(note) {
		SDL_DestroyTexture(note);
	}
}



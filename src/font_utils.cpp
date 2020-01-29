#include "font_utils.h"

auto renderText(const std::string& s, TTF_Font* font, SDL_Renderer* renderer) -> std::shared_ptr<Texture>
{
	static SDL_Color white = {255, 255, 255};
	SDL_Surface* surf = TTF_RenderUTF8_Blended(font, s.c_str(), white);
	if(!surf) {
		std::cerr << "ERROR(renderText): " << TTF_GetError() << std::endl;
		return nullptr;
	}
	
	auto tex = std::make_shared<Texture>();
	tex->w = surf->w;
	tex->h = surf->h;
	
	tex->tex = SDL_CreateTextureFromSurface(renderer, surf);
	if(!tex->tex) {
		std::cerr << "ERROR(renderText): " << SDL_GetError() << std::endl;
		return nullptr;
	}
	
	SDL_FreeSurface(surf);
	

	return tex;
}

auto writeNumber(Vec2i pos, int num, const std::array<std::shared_ptr<Texture>, 10>& numbers, SDL_Renderer* renderer) -> void
{
	static std::array<int, 20> digits;
	int ni = 0;
	while(num > 0) {
		digits[ni++] = num%10;
		
		num /= 10;
	}

	if(ni == 0) {
		digits[ni++] = 0;
	}
	

	for(int i=ni-1; i>=0; --i) {
		auto t = numbers[digits[i]];
		
		SDL_Rect dst;
		dst.x = pos.x;
		dst.y = pos.y;
		dst.w = t->w;
		dst.h = t->h;
		
		SDL_RenderCopy(renderer, t->tex, nullptr, &dst);
		
		pos.x += t->w;
	}
}



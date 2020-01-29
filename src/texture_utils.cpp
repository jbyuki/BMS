#include "texture_utils.h"

Texture::~Texture()
{
	if(tex) {
		SDL_DestroyTexture(tex);
	}
}

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

auto drawTexture(SDL_Renderer* renderer, Vec2i pos, std::shared_ptr<Texture> tex) -> void
{
	SDL_Rect rc;
	rc.x = pos.x;
	rc.y = pos.y;
	rc.w = tex->w;
	rc.h = tex->h;

	SDL_RenderCopy(renderer, tex->tex, nullptr, &rc);
}


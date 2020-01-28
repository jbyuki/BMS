#include <SDL.h>

#include <iostream>

const int WIDTH=640, HEIGHT= 480;
SDL_Window* window;
SDL_Renderer* renderer;


auto main(int argc, char* argv[]) -> int
{
	SDL_Init(SDL_INIT_VIDEO);
	
	window = SDL_CreateWindow("BMS Player v0.1",
		SDL_WINDOWPOS_UNDEFINED, 
		SDL_WINDOWPOS_UNDEFINED, 
		WIDTH, HEIGHT, SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI);
	
	if(window == nullptr) {
		std::cerr << "ERROR(SDL_CreateWindow): " << SDL_GetError() << std::endl;
		return EXIT_FAILURE;
	}
	
	renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
	
	if(renderer == nullptr) {
		std::cerr << "ERROR(SDL_CreateRenderer): " << SDL_GetError() << std::endl;
		return EXIT_FAILURE;
	}
	

	while(true) {
		SDL_Event event;
		bool do_quit = false;
		while(SDL_PollEvent(&event)) {
			if(event.type == SDL_QUIT) {
				do_quit = true;
			}
		}
		
		if(do_quit) {
			break;
		}
	
	}
	

	SDL_Quit();
	
	SDL_DestroyWindow(window);
	
	SDL_DestroyRenderer(renderer);
	

	return 0;
}



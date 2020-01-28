#include <SDL.h>

#include <iostream>

#include "parser.h"
#include <memory>
#include <string>

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
	
	std::shared_ptr<Map> map = std::make_shared<Map>();
	std::string input = "C:\\Users\\i354324\\OneDrive - SAP SE\\Documents\\BMS Songs\\BMSSP2009\\Absurd Gaff - siromaru\\_abs07_00_bmssp7e.bme";
	if(!load(input, map)) {
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
	

	map.reset();
	SDL_Quit();
	
	SDL_DestroyWindow(window);
	
	SDL_DestroyRenderer(renderer);
	

	return 0;
}



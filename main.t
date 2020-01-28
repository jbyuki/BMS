@*=
@includes
@global_variables

auto main(int argc, char* argv[]) -> int
{
	@init_graphics
	@init_audio
	@read_beatmap

	@game_loop

	@release_beatmap
	@deinit_audio
	@deinit_graphics

	return 0;
}


@includes=
#include <SDL.h>

@init_graphics=
SDL_Init(SDL_INIT_VIDEO);

@deinit_graphics=
SDL_Quit();

@global_variables=
const int WIDTH=640, HEIGHT= 480;
SDL_Window* window;
SDL_Renderer* renderer;

@includes+=
#include <iostream>

@init_graphics+=
window = SDL_CreateWindow("BMS Player v0.1",
	SDL_WINDOWPOS_UNDEFINED, 
	SDL_WINDOWPOS_UNDEFINED, 
	WIDTH, HEIGHT, SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI);

if(window == nullptr) {
	std::cerr << "ERROR(SDL_CreateWindow): " << SDL_GetError() << std::endl;
	return EXIT_FAILURE;
}

@deinit_graphics+=
SDL_DestroyWindow(window);

@init_graphics+=
renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

if(renderer == nullptr) {
	std::cerr << "ERROR(SDL_CreateRenderer): " << SDL_GetError() << std::endl;
	return EXIT_FAILURE;
}

@deinit_graphics+=
SDL_DestroyRenderer(renderer);

@game_loop=
while(true) {
	@handle_events

	@clear_frame
	@draw_frame
	@flip_frame
}

@handle_events=
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

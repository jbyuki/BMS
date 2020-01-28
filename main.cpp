#include <SDL.h>

#include <iostream>

#include "parser.h"
#include <memory>
#include <string>

#include <SDL_mixer.h>

#include <array>

#include "file_utils.h"

#include <chrono>

const int WIDTH=640, HEIGHT= 480;
SDL_Window* window;
SDL_Renderer* renderer;

std::array<Mix_Chunk*, (26+10)*(26+10)> samples;

float t;
unsigned next;


auto main(int argc, char* argv[]) -> int
{
	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
	
	int flags=MIX_INIT_OGG;
	int initted=Mix_Init(flags);
	if((initted&flags) != flags) {
		std::cerr << "ERROR(Mix_Init): " << Mix_GetError() << std::endl;
		return EXIT_FAILURE;
	}
	
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
	
	if(Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 1024) == -1) {
		std::cerr << "ERROR(Mix_OpenAudio): " << Mix_GetError() << std::endl;
		return EXIT_FAILURE;
	}
	
	std::shared_ptr<Map> m = std::make_shared<Map>();
	std::string input = "C:\\Users\\i354324\\OneDrive - SAP SE\\Documents\\BMS Songs\\BMSSP2009\\Absurd Gaff - siromaru\\_abs07_00_bmssp7e.bme";
	if(!load(input, m)) {
		return EXIT_FAILURE;
	}
	
	for(unsigned i=0; i<samples.size(); ++i) {
		samples[i] = nullptr;
	
		if(m->wav[i] != "") {
			auto sample_path = same_directory_as(m->wav[i], input);
			auto wav_path = replace_extension(sample_path, ".wav");
			auto ogg_path = replace_extension(sample_path, ".ogg");
	
			if(file_exists(wav_path)) {
				samples[i] = Mix_LoadWAV(wav_path.c_str());
				if(!samples[i]) {
					std::cerr << "ERROR(Mix_LoadWAV): " << Mix_GetError() << std::endl;
				}
			}
			
			else if(file_exists(ogg_path)) {
				samples[i] = Mix_LoadWAV(ogg_path.c_str());
				if(!samples[i]) {
					std::cerr << "ERROR(Mix_LoadWAV): " << Mix_GetError() << std::endl;
				}
			}
			
			else {
				auto no_path = replace_extension(sample_path, "");
				std::cerr << "ERROR: Could not open " << sample_path << "(.wav|.ogg)" << std::endl;
			}
			
		}
	}
	
	t = 0.f;
	next = 0;
	auto t_m1 = std::chrono::high_resolution_clock::now();
	

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
		
	
		auto t_0 = std::chrono::high_resolution_clock::now();
		std::chrono::duration<double> elapsed = t_0 - t_m1;
		t_m1 = t_0;
		float dt = (float)elapsed.count();
		
		t += dt;
		
		unsigned before = next;
		for(;next < m->notes.size() && m->notes[next].time < t; ++next)
		{
		}
		
		if(before != next) {
			for(;before < next; ++before) {
				int wav_i = m->notes[before].wav;
				Mix_PlayChannel(-1, samples[wav_i], 0);
			}
		}
		
	
		SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
		SDL_RenderClear(renderer);
		
		SDL_RenderPresent(renderer);
	}
	

	for(unsigned i=0; i<samples.size(); ++i) {
		if(samples[i]) {
			Mix_FreeChunk(samples[i]);
		}
	}
	
	m.reset();
	
	Mix_CloseAudio();
	
	SDL_DestroyWindow(window);
	
	SDL_DestroyRenderer(renderer);
	
	SDL_Quit();
	
	// ensure that Mix_Quit is called enough times
	while(Mix_Init(0)) {
		Mix_Quit();
	}
	

	return 0;
}



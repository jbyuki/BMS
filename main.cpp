#include <SDL.h>

#include <iostream>

#include "parser.h"
#include <memory>
#include <string>

#include <SDL_mixer.h>

#include <array>

#include "file_utils.h"

#include <chrono>

#include <SDL_image.h>

#include "skin.h"

#include "vec2.h"

const int WIDTH=640, HEIGHT= 480;
SDL_Window* window;
SDL_Renderer* renderer;

std::array<Mix_Chunk*, (26+10)*(26+10)> samples;

float t;
unsigned next;

std::array<bool, (26+10)*(26+10)> playing;
std::array<int, (26+10)*(26+10)> channel_to_wav;
std::array<int, (26+10)*(26+10)> wav_to_channel;

float scroll_speed = 1.f; // screen/second


auto finishPlaying(int channel) -> void 
{
	playing[channel_to_wav[channel]] = false;
}


auto main(int argc, char* argv[]) -> int
{
	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
	
	int flags=MIX_INIT_OGG;
	int initted=Mix_Init(flags);
	if((initted&flags) != flags) {
		std::cerr << "ERROR(Mix_Init): " << Mix_GetError() << std::endl;
		return EXIT_FAILURE;
	}
	
	flags = IMG_INIT_JPG | IMG_INIT_PNG;
	initted = IMG_Init(flags);
	if((initted&flags) != flags) {
		std::cerr << "ERROR(IMG_Init): " << IMG_GetError() << std::endl;
		return false;
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
	
	for(bool& p : playing) { p = false; }
	
	Mix_ChannelFinished(finishPlaying);
	
	Mix_AllocateChannels(32);
	
	std::shared_ptr<Map> m = std::make_shared<Map>();
	std::string input = "C:\\data\\BMSSP2009\\Lapis - SHIKI\\lapis7key.bme";
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
	
	std::shared_ptr<Skin> s = std::make_shared<Skin>();
	if(!loadSkin("C:\\data\\skin\\skin.txt", renderer, s)) {
		return EXIT_FAILURE;
	}
	
	t = 0.f;
	next = 0;
	auto t0 = std::chrono::high_resolution_clock::now();
	

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
		
	
		auto tn = std::chrono::high_resolution_clock::now();
		std::chrono::duration<double> elapsed = tn - t0;
		t = (float)elapsed.count();
		
		unsigned before = next;
		for(;next < m->notes.size() && m->notes[next].time < t; ++next)
		{
		}
		
		if(before != next) {
			for(;before < next; ++before) {
				int wav_i = m->notes[before].wav;
		
				if(playing[wav_i]) {
					Mix_HaltChannel(wav_to_channel[wav_i]);
				}
		
				playing[wav_i] = true;
				int channel = Mix_PlayChannel(-1, samples[wav_i], 0);
				if(channel == -1) {
					std::cerr << "note drop" << std::endl;
					continue;
				}
		
				wav_to_channel[wav_i] = channel;
				channel_to_wav[channel] = wav_i;
			}
		}
		
	
		SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
		SDL_RenderClear(renderer);
		
		for(unsigned i=next; i<m->notes.size(); ++i) {
			auto& note = m->notes[i];
		
			if(note.col == 0) {
				continue;
			}
			
			Vec2f pos;
			pos.x = (float)note.col * 30.f + 100.f;
			pos.y = (float)HEIGHT - ((note.time - t)*scroll_speed*(float)HEIGHT);
			
			if(pos.y < 0.f) {
				continue;
			}
			
			SDL_Rect dst;
			dst.x = (int)(pos.x+0.5f);
			dst.y = (int)(pos.y+0.5f);
			dst.w = 30;
			dst.h = 15;
			SDL_RenderCopy(renderer, s->note, nullptr, &dst);
		}
		
		SDL_RenderPresent(renderer);
		
	}
	

	s.reset();
	
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
	
	IMG_Quit();
	

	return 0;
}



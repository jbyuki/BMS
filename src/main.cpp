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

#include <unordered_map>

#include <cmath>

#include <SDL_ttf.h>

#include "font_utils.h"
#include "texture_utils.h"

const int WIDTH=640, HEIGHT= 480;
SDL_Window* window;
SDL_Renderer* renderer;

std::array<Mix_Chunk*, (26+10)*(26+10)> samples;

float t;
std::vector<Map::Note> next, miss, bgm, toplay;

const float BAD_WINDOW = 0.15f;

std::array<bool, (26+10)*(26+10)> playing;
std::array<int, (26+10)*(26+10)> channel_to_wav;
std::array<int, (26+10)*(26+10)> wav_to_channel;

float scroll_speed = 1.f; // screen/second

int PLAY_AREA = 100;
int JUDGMENT_OFFSET = 50;

enum PLAYER_CONTROL
{
	P1_SCRATCH = 0,
	P1_COL1,
	P1_COL2,
	P1_COL3,
	P1_COL4,
	P1_COL5,
	P1_COL6,
	P1_COL7,

	PLAYER_CONTROL_NUM,
};

std::unordered_map<SDL_Keycode, PLAYER_CONTROL> keymapping {
	{ SDLK_a, P1_SCRATCH },
	{ SDLK_s, P1_COL1 },
	{ SDLK_d, P1_COL2 },
	{ SDLK_f, P1_COL3 },
	{ SDLK_SPACE, P1_COL4 },
	{ SDLK_j, P1_COL5 },
	{ SDLK_k, P1_COL6 },
	{ SDLK_l, P1_COL7 }
};

int perfect_count = 0;
int great_count = 0;
int good_count = 0;
int bad_count = 0;
int poor_count = 0;

const float PERFECT_WINDOW = 0.02f;
const float GREAT_WINDOW = 0.04f;
const float GOOD_WINDOW = 0.105f;

std::array<std::shared_ptr<Texture>, 10> numbers;

Vec2i ui_pos(450, 10);

std::array<bool, PLAYER_CONTROL_NUM> key_pressed;


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
	
	if(TTF_Init() == -1) {
		std::cerr << "ERROR(TTF_Init): " << TTF_GetError() << std::endl;
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
	
	for(bool& p : playing) { p = false; }
	
	Mix_ChannelFinished(finishPlaying);
	
	Mix_AllocateChannels(32);
	
	std::shared_ptr<Map> m = std::make_shared<Map>();
	std::string input = "C:\\data\\BMSSP2009\\Absurd Gaff - siromaru\\_abs07_00_bmssp7e.bme";
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
	
	SDL_SetTextureBlendMode(s->judgment->tex, SDL_BLENDMODE_BLEND);
	
	TTF_Font* font = TTF_OpenFont("C:\\data\\font\\NotoSansJP-Regular.otf", 14);
	if(!font) {
		std::cerr << "ERROR(TTF_OpenFont): " << TTF_GetError() << std::endl;
		return EXIT_FAILURE;
	}
	
	for(int c=0; c<=9; ++c) {
		numbers[c] = renderText(std::to_string(c), font, renderer);
	}
	
	auto perfect_text = renderText("PERFECT:", font, renderer);
	auto great_text   = renderText("GREAT:", font, renderer);
	auto good_text    = renderText("GOOD:", font, renderer);
	auto bad_text     = renderText("BAD:", font, renderer);
	auto poor_text    = renderText("POOR:", font, renderer);
	
	t = 0.f;
	auto t0 = std::chrono::high_resolution_clock::now();
	
	for(auto it=m->notes.rbegin(); it!=m->notes.rend(); ++it) {
		if(it->col == 0) {
			bgm.push_back(*it);
		} else {
			next.push_back(*it);
		}
	}
	
	key_pressed.fill(false);
	

	while(true) {
		std::array<bool, PLAYER_CONTROL_NUM> keys;
		keys.fill(false);
		
		SDL_Event event;
		bool do_quit = false;
		while(SDL_PollEvent(&event)) {
			switch(event.type) {
			case SDL_KEYDOWN: {
				auto kit = keymapping.find(event.key.keysym.sym);
				if(kit != keymapping.end()) {
					keys[kit->second] = true;
				}
				
				if(kit != keymapping.end()) {
					key_pressed[kit->second] = true;
				}
				
				break; }
			case SDL_KEYUP: {
				auto kit = keymapping.find(event.key.keysym.sym);
				if(kit != keymapping.end()) {
					key_pressed[kit->second] = false;
				}
				
				break; }
			case SDL_QUIT:
				do_quit = true;
				break;
			default:
				break;
			}
		}
		
		if(do_quit) {
			break;
		}
		
	
		auto tn = std::chrono::high_resolution_clock::now();
		std::chrono::duration<double> elapsed = tn - t0;
		t = (float)elapsed.count();
		
		while(next.size() > 0 && next.back().time + BAD_WINDOW < t)
		{
			miss.push_back(next.back());
			next.pop_back();
		}
		
		while(bgm.size() > 0 && bgm.back().time < t)
		{
			toplay.push_back(bgm.back());
			bgm.pop_back();
		}
		
		for(auto& note : toplay) {
			if(playing[note.wav]) {
				Mix_HaltChannel(wav_to_channel[note.wav]);
			}
			
			playing[note.wav] = true;
			int channel = Mix_PlayChannel(-1, samples[note.wav], 0);
			if(channel == -1) {
				std::cerr << "note drop" << std::endl;
				continue;
			}
			
			wav_to_channel[note.wav] = channel;
			channel_to_wav[channel] = note.wav;
			
		}
		toplay.clear();
		
		for(unsigned k=0; k<keys.size(); ++k) {
			if(keys[k]) {
				int found = -1;
				for(int i=(int)next.size()-1; i>=0 && next[i].time <= t+BAD_WINDOW; --i) {
					if(next[i].col == k+1 && 
					   (found == -1 || std::abs(next[i].time-t) < std::abs(next[found].time-t))) {
						found = i;
					}
				}
				if(found == -1) {
					continue;
				}
				
				auto note = next[found];
				next.erase(next.begin()+found);
				
				if(playing[note.wav]) {
					Mix_HaltChannel(wav_to_channel[note.wav]);
				}
				
				playing[note.wav] = true;
				int channel = Mix_PlayChannel(-1, samples[note.wav], 0);
				if(channel == -1) {
					std::cerr << "note drop" << std::endl;
					continue;
				}
				
				wav_to_channel[note.wav] = channel;
				channel_to_wav[channel] = note.wav;
				
				float dt = std::abs(note.time-t);
				if(dt <= PERFECT_WINDOW) { perfect_count++; }
				else if(dt <= GREAT_WINDOW) { great_count++; }
				else if(dt <= GOOD_WINDOW) { good_count++; }
				else if(dt <= BAD_WINDOW) { bad_count++; }
				else { poor_count++; }
				
			}
		}
		
	
		SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
		SDL_RenderClear(renderer);
		
		for(unsigned i=0; i<key_pressed.size(); ++i) {
			if(key_pressed[i]) {
				Vec2i p;
				p.x = i == 0 ? PLAY_AREA : (i-1)*s->hit->w + s->hit_scratch->w + (int)PLAY_AREA;
				p.y = HEIGHT - s->hit->h - JUDGMENT_OFFSET;
				
				
				drawTexture(renderer, p, i == 0 ? s->hit_scratch : s->hit);
				
			}
		}
		
		for(auto it=next.rbegin(); it!=next.rend(); ++it) {
			auto& note = *it;
			Vec2i pos;
			pos.x = note.col == 1 ? PLAY_AREA : (note.col-2)*s->note->w + s->scratch->w + PLAY_AREA;
			pos.y = (int)((float)HEIGHT - ((note.time - t)*scroll_speed*(float)HEIGHT) + 0.5f) - s->note->h/2 - JUDGMENT_OFFSET;
			
			if(pos.y < 0.f) {
				break;
			}
			
			drawTexture(renderer, pos, note.col == 1 ? s->scratch : ((note.col&1) == 0 ? s->note_odd : s->note));
			
		}
		
		{
		Vec2i pos(PLAY_AREA, HEIGHT - JUDGMENT_OFFSET - s->judgment->h);
		drawTexture(renderer, pos, s->judgment);
		}
		{
		Vec2i p = ui_pos;
		drawTexture(renderer, p, perfect_text); p.y += perfect_text->h;
		drawTexture(renderer, p, great_text); p.y += great_text->h;
		drawTexture(renderer, p, good_text); p.y += good_text->h;
		drawTexture(renderer, p, bad_text); p.y += bad_text->h;
		drawTexture(renderer, p, poor_text); /* p.y += poor_text->h; */
		}
		
		{
		Vec2i p = ui_pos;
		p.x += 100;
		writeNumber(p, perfect_count, numbers, renderer); p.y += perfect_text->h;
		writeNumber(p, great_count, numbers, renderer); p.y += great_text->h;
		writeNumber(p, good_count, numbers, renderer); p.y += good_text->h;
		writeNumber(p, bad_count, numbers, renderer); p.y += bad_text->h;
		writeNumber(p, (int)miss.size() + poor_count, numbers, renderer); /* p.y += poor_text->h;*/
		}
		
		
		SDL_RenderPresent(renderer);
		
	}
	

	TTF_CloseFont(font);
	
	numbers.fill(nullptr);
	
	perfect_text.reset();
	great_text.reset();
	good_text.reset();
	bad_text.reset();
	poor_text.reset();
	
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
	
	TTF_Quit();
	

	return 0;
}



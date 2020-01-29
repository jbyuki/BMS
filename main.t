@*=
@includes
@global_variables

@play_finish_callback

auto main(int argc, char* argv[]) -> int
{
	@init_sdl
	@init_graphics
	@init_audio
	@read_beatmap
	@load_all_audio
	@load_skin
	@init_time

	@game_loop

	@unload_skin
	@unload_all_audio
	@release_beatmap
	@deinit_audio
	@deinit_graphics
	@quit_sdl

	return 0;
}


@includes=
#include <SDL.h>

@init_sdl=
SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);

@quit_sdl=
SDL_Quit();

@global_variables=
const int WIDTH=640, HEIGHT= 480;
SDL_Window* window;
SDL_Renderer* renderer;

@includes+=
#include <iostream>

@init_graphics=
window = SDL_CreateWindow("BMS Player v0.1",
	SDL_WINDOWPOS_UNDEFINED, 
	SDL_WINDOWPOS_UNDEFINED, 
	WIDTH, HEIGHT, SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI);

if(window == nullptr) {
	std::cerr << "ERROR(SDL_CreateWindow): " << SDL_GetError() << std::endl;
	return EXIT_FAILURE;
}

@deinit_graphics=
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

	@move_frame

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

@includes+=
#include "parser.h"
#include <memory>
#include <string>

@read_beatmap=
std::shared_ptr<Map> m = std::make_shared<Map>();
std::string input = "C:\\data\\BMSSP2009\\Lapis - SHIKI\\lapis7key.bme";
if(!load(input, m)) {
	return EXIT_FAILURE;
}

@release_beatmap=
m.reset();

@includes+=
#include <SDL_mixer.h>

@init_sdl+=
int flags=MIX_INIT_OGG;
int initted=Mix_Init(flags);
if((initted&flags) != flags) {
	std::cerr << "ERROR(Mix_Init): " << Mix_GetError() << std::endl;
	return EXIT_FAILURE;
}

@quit_sdl+=
// ensure that Mix_Quit is called enough times
while(Mix_Init(0)) {
	Mix_Quit();
}

@init_audio=
if(Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 1024) == -1) {
	std::cerr << "ERROR(Mix_OpenAudio): " << Mix_GetError() << std::endl;
	return EXIT_FAILURE;
}

@deinit_audio=
Mix_CloseAudio();

@includes+=
#include <array>

@global_variables+=
std::array<Mix_Chunk*, (26+10)*(26+10)> samples;

@includes+=
#include "file_utils.h"

@load_all_audio=
for(unsigned i=0; i<samples.size(); ++i) {
	samples[i] = nullptr;

	if(m->wav[i] != "") {
		auto sample_path = same_directory_as(m->wav[i], input);
		auto wav_path = replace_extension(sample_path, ".wav");
		auto ogg_path = replace_extension(sample_path, ".ogg");

		@read_audio_file_once_wav
		@read_audio_file_once_ogg
		@otherwise_display_error
	}
}

@read_audio_file_once_wav=
if(file_exists(wav_path)) {
	samples[i] = Mix_LoadWAV(wav_path.c_str());
	if(!samples[i]) {
		std::cerr << "ERROR(Mix_LoadWAV): " << Mix_GetError() << std::endl;
	}
}

@read_audio_file_once_ogg=
else if(file_exists(ogg_path)) {
	samples[i] = Mix_LoadWAV(ogg_path.c_str());
	if(!samples[i]) {
		std::cerr << "ERROR(Mix_LoadWAV): " << Mix_GetError() << std::endl;
	}
}

@otherwise_display_error=
else {
	auto no_path = replace_extension(sample_path, "");
	std::cerr << "ERROR: Could not open " << sample_path << "(.wav|.ogg)" << std::endl;
}

@unload_all_audio=
for(unsigned i=0; i<samples.size(); ++i) {
	if(samples[i]) {
		Mix_FreeChunk(samples[i]);
	}
}

@global_variables+=
float t;
unsigned next;

@includes+=
#include <chrono>

@init_time=
t = 0.f;
next = 0;
auto t0 = std::chrono::high_resolution_clock::now();

@move_frame=
auto tn = std::chrono::high_resolution_clock::now();
std::chrono::duration<double> elapsed = tn - t0;
t = (float)elapsed.count();

@move_frame+=
unsigned before = next;
for(;next < m->notes.size() && m->notes[next].time < t; ++next)
{
}

@global_variables+=
std::array<bool, (26+10)*(26+10)> playing;
std::array<int, (26+10)*(26+10)> channel_to_wav;
std::array<int, (26+10)*(26+10)> wav_to_channel;

@init_audio+=
for(bool& p : playing) { p = false; }

@play_finish_callback=
auto finishPlaying(int channel) -> void 
{
	playing[channel_to_wav[channel]] = false;
}

@init_audio+=
Mix_ChannelFinished(finishPlaying);

@move_frame+=
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

@clear_frame=
SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
SDL_RenderClear(renderer);

@flip_frame=
SDL_RenderPresent(renderer);

@init_audio+=
Mix_AllocateChannels(32);

@includes+=
#include <SDL_image.h>

@init_sdl+=
flags = IMG_INIT_JPG | IMG_INIT_PNG;
initted = IMG_Init(flags);
if((initted&flags) != flags) {
	std::cerr << "ERROR(IMG_Init): " << IMG_GetError() << std::endl;
	return false;
}

@quit_sdl+=
IMG_Quit();

@includes+=
#include "skin.h"

@load_skin=
std::shared_ptr<Skin> s = std::make_shared<Skin>();
if(!loadSkin("C:\\data\\skin\\skin.txt", renderer, s)) {
	return EXIT_FAILURE;
}

@unload_skin=
s.reset();

@global_variables+=
float scroll_speed = 1.f; // screen/second

@draw_frame=
for(unsigned i=next; i<m->notes.size(); ++i) {
	auto& note = m->notes[i];

	@skip_if_bgm_note
	@compute_note_position_on_screen
	@skip_if_outside_screen
	@otherwise_draw_note
}

@skip_if_bgm_note=
if(note.col == 0) {
	continue;
}

@includes+=
#include "vec2.h"

@compute_note_position_on_screen=
Vec2f pos;
pos.x = (float)note.col * 30.f + 100.f;
pos.y = (float)HEIGHT - ((note.time - t)*scroll_speed*(float)HEIGHT);

@skip_if_outside_screen=
if(pos.y < 0.f) {
	continue;
}

@otherwise_draw_note=
SDL_Rect dst;
dst.x = (int)(pos.x+0.5f);
dst.y = (int)(pos.y+0.5f);
dst.w = 30;
dst.h = 15;
SDL_RenderCopy(renderer, s->note, nullptr, &dst);

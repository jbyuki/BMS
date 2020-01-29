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
	@load_text
	@init_time

	@game_loop

	@unload_text
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
	@init_keypress_states
	@handle_events

	@move_frame
	@handle_logic

	@clear_frame
	@draw_frame
	@flip_frame
}

@handle_events=
SDL_Event event;
bool do_quit = false;
while(SDL_PollEvent(&event)) {
	switch(event.type) {
	case SDL_KEYDOWN: {
		@handle_keydown
		break; }
	case SDL_KEYUP: {
		@handle_keyup
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

@includes+=
#include "parser.h"
#include <memory>
#include <string>

@read_beatmap=
std::shared_ptr<Map> m = std::make_shared<Map>();
std::string input = "C:\\data\\BMSSP2009\\Absurd Gaff - siromaru\\_abs07_00_bmssp7e.bme";
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
std::vector<Map::Note> next, miss, bgm, toplay;

@includes+=
#include <chrono>

@init_time=
t = 0.f;
auto t0 = std::chrono::high_resolution_clock::now();

for(auto it=m->notes.rbegin(); it!=m->notes.rend(); ++it) {
	if(it->col == 0) {
		bgm.push_back(*it);
	} else {
		next.push_back(*it);
	}
}

@move_frame=
auto tn = std::chrono::high_resolution_clock::now();
std::chrono::duration<double> elapsed = tn - t0;
t = (float)elapsed.count();

@global_variables+=
const float BAD_WINDOW = 0.15f;

@move_frame+=
while(next.size() > 0 && next.back().time + BAD_WINDOW < t)
{
	miss.push_back(next.back());
	next.pop_back();
}

@move_frame+=
while(bgm.size() > 0 && bgm.back().time < t)
{
	toplay.push_back(bgm.back());
	bgm.pop_back();
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
for(auto& note : toplay) {
	@play_note_sample
}
toplay.clear();

@play_note_sample=
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
@draw_background
@draw_notes
@draw_judgment_line
@draw_ui

@draw_notes=
for(auto it=next.rbegin(); it!=next.rend(); ++it) {
	auto& note = *it;
	@compute_note_position_on_screen
	@break_if_outside_screen
	@otherwise_draw_note
}

@includes+=
#include "vec2.h"

@global_variables+=
int PLAY_AREA = 100;
int JUDGMENT_OFFSET = 50;

@compute_note_position_on_screen=
Vec2i pos;
pos.x = note.col == 1 ? PLAY_AREA : (note.col-2)*s->note->w + s->scratch->w + PLAY_AREA;
pos.y = (int)((float)HEIGHT - ((note.time - t)*scroll_speed*(float)HEIGHT) + 0.5f) - s->note->h/2 - JUDGMENT_OFFSET;

@break_if_outside_screen=
if(pos.y < 0.f) {
	break;
}

@otherwise_draw_note=
drawTexture(renderer, pos, note.col == 1 ? s->scratch : ((note.col&1) == 0 ? s->note_odd : s->note));

@global_variables+=
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

@includes+=
#include <unordered_map>

@global_variables+=
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

@init_keypress_states=
std::array<bool, PLAYER_CONTROL_NUM> keys;
keys.fill(false);

@handle_keydown=
auto kit = keymapping.find(event.key.keysym.sym);
if(kit != keymapping.end()) {
	keys[kit->second] = true;
}

@handle_logic=
for(unsigned k=0; k<keys.size(); ++k) {
	if(keys[k]) {
		@pick_closest_note_or_skip_if_too_far
		@remove_note_from_next
		@play_note_sample
		@judge_note
	}
}

@includes+=
#include <cmath>

@pick_closest_note_or_skip_if_too_far=
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

@remove_note_from_next=
auto note = next[found];
next.erase(next.begin()+found);

@global_variables+=
int perfect_count = 0;
int great_count = 0;
int good_count = 0;
int bad_count = 0;
int poor_count = 0;

const float PERFECT_WINDOW = 0.02f;
const float GREAT_WINDOW = 0.04f;
const float GOOD_WINDOW = 0.105f;

@judge_note=
float dt = std::abs(note.time-t);
if(dt <= PERFECT_WINDOW) { perfect_count++; }
else if(dt <= GREAT_WINDOW) { great_count++; }
else if(dt <= GOOD_WINDOW) { good_count++; }
else if(dt <= BAD_WINDOW) { bad_count++; }
else { poor_count++; }

@includes+=
#include <SDL_ttf.h>

@init_sdl+=
if(TTF_Init() == -1) {
	std::cerr << "ERROR(TTF_Init): " << TTF_GetError() << std::endl;
	return EXIT_FAILURE;
}

@quit_sdl+=
TTF_Quit();

@load_text=
TTF_Font* font = TTF_OpenFont("C:\\data\\font\\NotoSansJP-Regular.otf", 14);
if(!font) {
	std::cerr << "ERROR(TTF_OpenFont): " << TTF_GetError() << std::endl;
	return EXIT_FAILURE;
}

@unload_text=
TTF_CloseFont(font);

@includes+=
#include "font_utils.h"
#include "texture_utils.h"

@global_variables+=
std::array<std::shared_ptr<Texture>, 10> numbers;

@load_text+=
for(int c=0; c<=9; ++c) {
	numbers[c] = renderText(std::to_string(c), font, renderer);
}

@unload_text+=
numbers.fill(nullptr);

@load_text+=
auto perfect_text = renderText("PERFECT:", font, renderer);
auto great_text   = renderText("GREAT:", font, renderer);
auto good_text    = renderText("GOOD:", font, renderer);
auto bad_text     = renderText("BAD:", font, renderer);
auto poor_text    = renderText("POOR:", font, renderer);

@unload_text+=
perfect_text.reset();
great_text.reset();
good_text.reset();
bad_text.reset();
poor_text.reset();

@global_variables+=
Vec2i ui_pos(450, 10);

@draw_ui=
{
Vec2i p = ui_pos;
drawTexture(renderer, p, perfect_text); p.y += perfect_text->h;
drawTexture(renderer, p, great_text); p.y += great_text->h;
drawTexture(renderer, p, good_text); p.y += good_text->h;
drawTexture(renderer, p, bad_text); p.y += bad_text->h;
drawTexture(renderer, p, poor_text); /* p.y += poor_text->h; */
}

@draw_ui+=
{
Vec2i p = ui_pos;
p.x += 100;
writeNumber(p, perfect_count, numbers, renderer); p.y += perfect_text->h;
writeNumber(p, great_count, numbers, renderer); p.y += great_text->h;
writeNumber(p, good_count, numbers, renderer); p.y += good_text->h;
writeNumber(p, bad_count, numbers, renderer); p.y += bad_text->h;
writeNumber(p, (int)miss.size() + poor_count, numbers, renderer); /* p.y += poor_text->h;*/
}

@global_variables+=
std::array<bool, PLAYER_CONTROL_NUM> key_pressed;

@init_time+=
key_pressed.fill(false);

@handle_keydown+=
if(kit != keymapping.end()) {
	key_pressed[kit->second] = true;
}

@handle_keyup=
auto kit = keymapping.find(event.key.keysym.sym);
if(kit != keymapping.end()) {
	key_pressed[kit->second] = false;
}

@draw_background=
for(unsigned i=0; i<key_pressed.size(); ++i) {
	if(key_pressed[i]) {
		@compute_hit_position
		@draw_hit_position
	}
}

@compute_hit_position=
Vec2i p;
p.x = i == 0 ? PLAY_AREA : (i-1)*s->hit->w + s->hit_scratch->w + (int)PLAY_AREA;
p.y = HEIGHT - s->hit->h - JUDGMENT_OFFSET;


@draw_hit_position=
drawTexture(renderer, p, i == 0 ? s->hit_scratch : s->hit);

@load_skin+=
SDL_SetTextureBlendMode(s->judgment->tex, SDL_BLENDMODE_BLEND);

@draw_judgment_line=
{
Vec2i pos(PLAY_AREA, HEIGHT - JUDGMENT_OFFSET - s->judgment->h);
drawTexture(renderer, pos, s->judgment);
}

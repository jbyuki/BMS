@description=
"Parser for BMS 'Be-Music Source' files."
"This file format was produced by Urao Yane and NBK in 1998."
"The technical file format name seems to be BM98."
"..."
"#random, #if is not supported yet"

@parser.h=
#pragma once
@includes

@data_struct
@functions

@parser.cpp=
#include "parser.h"

@define_functions

@includes=
#include <string>
#include <memory>

@data_struct=
struct Map
{
	@map_data
};

@functions=
auto load(const std::string& filename, std::shared_ptr<Map> m) -> bool;

@define_functions=
auto load(const std::string& filename, std::shared_ptr<Map> m) -> bool
{
	@open_file
	@read_line_by_line
	@output_read_data
	@sort_notes

	return true;
}

@includes+=
#include <fstream>
#include <iostream>

@open_file=
std::ifstream in(filename);
if(!in.is_open()) {
	std::cerr << "ERROR(load): Could not open " << filename << std::endl;
	return false;
}

@read_line_by_line=
std::string line;
while(std::getline(in, line)) {
	@skip_comment_line
	@extract_command_name
	@process_headers
	@process_messages
	@skip_other_commands
}

@skip_comment_line=
// skip empty line or non-commands lines (command must start with '#')
if(line.size() == 0 || line[0] != '#') {
	continue;
}

@includes+=
#include <vector>
#include <sstream>
#include "string_utils.h"

@extract_command_name=
std::vector<std::string> words;
std::istringstream iss(line.substr(1)); // remove leading '#'
std::string command;
iss >> command;
command = str_tolower(command);

@map_data=
int player;

@process_headers=
if(command == "player") { iss >> m->player; }

@output_read_data=
std::cout << "PLAYER: " << m->player << std::endl;

@map_data+=
std::string genre;

@process_headers+=
else if(command == "genre") { iss >> std::ws; std::getline(iss, m->genre); }

@output_read_data+=
std::cout << "GENRE: " << m->genre << std::endl;

@map_data+=
std::string title;

@process_headers+=
else if(command == "title") { iss >> std::ws; std::getline(iss, m->title); }

@output_read_data+=
std::cout << "TITLE: " << m->title << std::endl;

@map_data+=
std::string artist;

@process_headers+=
else if(command == "artist") { iss >> std::ws; std::getline(iss, m->artist); }

@output_read_data+=
std::cout << "ARTIST: " << m->artist << std::endl;

@map_data+=
std::string midi; // background music by MIDI

@process_headers+=
else if(command == "midifile") { iss >> m->midi; }

@output_read_data+=
std::cout << "MIDIFILE: " << m->midi << std::endl;

@map_data+=
int bpm = 130; // beat per minute at the top of music. default: 130

@process_headers+=
else if(command == "bpm") { iss >> m->bpm; }

@output_read_data+=
std::cout << "BPM: " << m->bpm << std::endl;

@map_data+=
int playlevel; // information of game level for player

@process_headers+=
else if(command == "playlevel") { iss >> m->playlevel; }

@output_read_data+=
std::cout << "PLAYLEVEL: " << m->playlevel << std::endl;

@map_data+=
int rank; // 0: very hard, 1: hard, 2: normal, 3: easy

@process_headers+=
else if(command == "rank") { iss >> m->rank; }

@output_read_data+=
std::cout << "RANK: " << m->rank << std::endl;

@map_data+=
int volwav; // relative volume control (percentage)

@process_headers+=
else if(command == "volwav") { iss >> m->volwav; }

@output_read_data+=
std::cout << "VOLWAV: " << m->volwav << std::endl;

@includes+=
#include <array>

@map_data+=
std::array<std::string, (10+26)*(10+26)> wav; // wave file name, 01 - ZZ

@process_headers+=
else if(command.substr(0, 3) == "wav") { 
	unsigned index = zz_tonum({line[4], line[5]});

	if(index >= m->wav.size()) {
		std::cerr << "WARNING(load): Incorrect WAV index " << line.substr(4, 2) << std::endl;
	} else {
		iss >> std::ws;
		std::getline(iss, m->wav[index]);
	}
}

@map_data+=
std::array<std::string, (10+26)*(10+26)> bmp; // bmp file name, 01 - ZZ
// #BMP00 is shown when the player plays poorly

@process_headers+=
else if(command.substr(0, 3) == "bmp") { 
	unsigned index = zz_tonum({line[4], line[5]});

	if(index >= m->bmp.size()) {
		std::cerr << "WARNING(load): Incorrect BMP index " << line.substr(4, 2) << std::endl;
	} else {
		iss >> std::ws;
		std::getline(iss, m->bmp[index]);
	}
}

@map_data+=
struct Note
{
	float time;
	unsigned col; // if col == 0, BGM
	unsigned wav;
};

std::vector<Note> notes;

@process_messages=
else if(command[0] >= '0' && command[0] <= '9') {
	@parse_message
	@save_if_note
}

@parse_message=
float measure;
std::istringstream parse_num(line.substr(1, 3));
parse_num >> measure;

std::string channel = line.substr(4, 2);
std::string message = line.substr(7);

@save_if_note=
@compute_measure_division
@traverse_message_and_create_notes

@compute_measure_division=
float div = 1.f/((float)message.size()/2.f);
float to_time = 1.f/((float)m->bpm / 60.f/4.f) ; // divide by 4 because one measure is 2 beats

@traverse_message_and_create_notes=
for(unsigned i=0; i<message.size(); i+=2) {
	Map::Note note;
	note.time = (measure + ((float)i/2.f)*div)*to_time;

	@get_note_wav
	@get_note_column

	m->notes.push_back(note);
}

@get_note_wav=
if(message[i] == '0' && message[i+1] == '0') {
	continue;
}
note.wav = zz_tonum({message[i], message[i+1]});

@get_note_column=
if(channel[0] == '0' && channel[1] == '1') { // BGM
	note.col = 0;
} else if(channel[0] == '1') {
	note.col = (unsigned)(channel[1] - '0');
} else {
	continue; // otherwise unknown channel, skip
}

@sort_notes=
std::sort(m->notes.begin(), m->notes.end(), 
	[](const Map::Note& n1, const Map::Note& n2) {
		return n1.time < n2.time;
});

@output_read_data+=
std::cout << "Number of notes: " << m->notes.size() << std::endl;

@skip_other_commands=
else {
	std::cerr << "WARNING(load): Unknown command " << line << std::endl;
}

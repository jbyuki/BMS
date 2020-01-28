#pragma once
#include <string>
#include <memory>

#include <fstream>
#include <iostream>

#include <vector>
#include <sstream>
#include "string_utils.h"

#include <array>


struct Map
{
	int player;
	
	std::string genre;
	
	std::string title;
	
	std::string artist;
	
	std::string midi; // background music by MIDI
	
	int bpm = 130; // beat per minute at the top of music. default: 130
	
	int playlevel; // information of game level for player
	
	int rank; // 0: very hard, 1: hard, 2: normal, 3: easy
	
	int volwav; // relative volume control (percentage)
	
	std::array<std::string, (10+26)*(10+26)> wav; // wave file name, 01 - ZZ
	
	std::array<std::string, (10+26)*(10+26)> bmp; // bmp file name, 01 - ZZ
	// #BMP00 is shown when the player plays poorly
	
	struct Message
	{
		unsigned track;
		unsigned channel;
		std::string message;
	};
	std::vector<Message> messages;
	
};

auto load(const std::string& filename, std::shared_ptr<Map> m) -> bool;



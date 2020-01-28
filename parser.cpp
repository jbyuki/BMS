#include "parser.h"

auto load(const std::string& filename, std::shared_ptr<Map> m) -> bool
{
	std::ifstream in(filename);
	if(!in.is_open()) {
		std::cerr << "ERROR(load): Could not open " << filename << std::endl;
		return false;
	}
	
	std::string line;
	while(std::getline(in, line)) {
		// skip empty line or non-commands lines (command must start with '#')
		if(line.size() == 0 || line[0] != '#') {
			continue;
		}
		
		std::vector<std::string> words;
		std::istringstream iss(line.substr(1)); // remove leading '#'
		std::string command;
		iss >> command;
		command = str_tolower(command);
		
		if(command == "player") { iss >> m->player; }
		
		else if(command == "genre") { iss >> std::ws; std::getline(iss, m->genre); }
		
		else if(command == "title") { iss >> std::ws; std::getline(iss, m->title); }
		
		else if(command == "artist") { iss >> std::ws; std::getline(iss, m->artist); }
		
		else if(command == "midifile") { iss >> m->midi; }
		
		else if(command == "bpm") { iss >> m->bpm; }
		
		else if(command == "playlevel") { iss >> m->playlevel; }
		
		else if(command == "rank") { iss >> m->rank; }
		
		else if(command == "volwav") { iss >> m->volwav; }
		
		else if(command.substr(0, 3) == "wav") { 
			unsigned index = zz_tonum({line[4], line[5]});
		
			if(index >= m->wav.size()) {
				std::cerr << "WARNING(load): Incorrect WAV index " << line.substr(4, 2) << std::endl;
			} else {
				iss >> std::ws;
				std::getline(iss, m->wav[index]);
			}
		}
		
		else if(command.substr(0, 3) == "bmp") { 
			unsigned index = zz_tonum({line[4], line[5]});
		
			if(index >= m->bmp.size()) {
				std::cerr << "WARNING(load): Incorrect BMP index " << line.substr(4, 2) << std::endl;
			} else {
				iss >> std::ws;
				std::getline(iss, m->bmp[index]);
			}
		}
		
		else {
			std::istringstream parse_num(line.substr(1, 3) + " " + line.substr(4, 2));
		
			Map::Message msg;
			parse_num >> msg.track;
			parse_num >> std::hex >> msg.channel;
		
			msg.message = line.substr(7);
			m->messages.push_back(msg);
		}
		
	}
	
	std::cout << "PLAYER: " << m->player << std::endl;
	
	std::cout << "GENRE: " << m->genre << std::endl;
	
	std::cout << "TITLE: " << m->title << std::endl;
	
	std::cout << "ARTIST: " << m->artist << std::endl;
	
	std::cout << "MIDIFILE: " << m->midi << std::endl;
	
	std::cout << "BPM: " << m->bpm << std::endl;
	
	std::cout << "PLAYLEVEL: " << m->playlevel << std::endl;
	
	std::cout << "RANK: " << m->rank << std::endl;
	
	std::cout << "VOLWAV: " << m->volwav << std::endl;
	
	std::cout << "Number of messages: " << m->messages.size() << std::endl;

	return true;
}



cmake_minimum_required(VERSION 3.1)
set(CMAKE_CXX_STANDARD 11)
project(bms)

set(SDL2 "SDL2-2.0.10")
set(SDL2_MIXER "SDL2_mixer-2.0.4")
set(SDL2_IMAGE "SDL2_image-2.0.5")

include_directories(
	"${SDL2}/include"
	"${SDL2_MIXER}/include"
	"${SDL2_IMAGE}/include"
)

link_directories(
	"${SDL2}/lib/x86"
	"${SDL2_MIXER}/lib/x86"
	"${SDL2_IMAGE}/lib/x86"
)

add_executable(bms
	parser.cpp
	parser.h
	string_utils.cpp
	string_utils.h
	file_utils.cpp
	file_utils.h
	skin.cpp
	skin.h
	vec2.h
	main.cpp
)

target_link_libraries(bms SDL2main SDL2 SDL2_image SDL2_mixer)

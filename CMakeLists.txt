cmake_minimum_required(VERSION 3.1)
set(CMAKE_CXX_STANDARD 11)
project(bms)

set(SDL2 "SDL2-2.0.10")
set(SDL2_MIXER "SDL2_mixer-2.0.4")
set(SDL2_IMAGE "SDL2_image-2.0.5")
set(SDL2_TTF "SDL2_ttf-2.0.15")

include_directories(
	"${SDL2}/include"
	"${SDL2_MIXER}/include"
	"${SDL2_IMAGE}/include"
	"${SDL2_TTF}/include"
)

link_directories(
	"${SDL2}/lib/x86"
	"${SDL2_MIXER}/lib/x86"
	"${SDL2_IMAGE}/lib/x86"
	"${SDL2_TTF}/lib/x86"
)

add_executable(bms
	src/parser.cpp
	src/parser.h
	src/string_utils.cpp
	src/string_utils.h
	src/file_utils.cpp
	src/file_utils.h
	src/texture_utils.cpp
	src/texture_utils.h
	src/skin.cpp
	src/skin.h
	src/vec2.h
	src/font_utils.cpp
	src/font_utils.h
	src/main.cpp
)

target_link_libraries(bms SDL2main SDL2 SDL2_image SDL2_mixer SDL2_ttf)

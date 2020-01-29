all: main.cpp parser.cpp parser.h string_utils.cpp string_utils.h file_utils.cpp file_utils.h skin.cpp skin.h vec2.h

main.cpp: main.t; letangle.py main.t > main.cpp
parser.cpp: parser.t; letangle.py parser.t parser.cpp > parser.cpp
parser.h: parser.t; letangle.py parser.t parser.h > parser.h
string_utils.cpp: string_utils.t; letangle.py string_utils.t string_utils.cpp > string_utils.cpp
string_utils.h: string_utils.t; letangle.py string_utils.t string_utils.h > string_utils.h
file_utils.cpp: file_utils.t; letangle.py file_utils.t file_utils.cpp > file_utils.cpp
file_utils.h: file_utils.t; letangle.py file_utils.t file_utils.h > file_utils.h
skin.cpp: skin.t; letangle.py skin.t skin.cpp > skin.cpp
skin.h: skin.t; letangle.py skin.t skin.h > skin.h
vec2.h: vec2.t; letangle.py vec2.t vec2.h > vec2.h

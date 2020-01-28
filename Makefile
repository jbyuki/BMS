all: main.cpp parser.cpp parser.h string_utils.cpp string_utils.h

main.cpp: main.t; letangle.py main.t > main.cpp
parser.cpp: parser.t; letangle.py parser.t parser.cpp > parser.cpp
parser.h: parser.t; letangle.py parser.t parser.h > parser.h
string_utils.cpp: string_utils.t; letangle.py string_utils.t string_utils.cpp > string_utils.cpp
string_utils.h: string_utils.t; letangle.py string_utils.t string_utils.h > string_utils.h

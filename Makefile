all: main.cpp

main.cpp: main.t; letangle.py main.t > main.cpp

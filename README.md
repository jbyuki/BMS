# BMS

A hobby project to play BMS also called "Be-Music Source" files.

Work-in-progress

## Build

### Requirements

For building this project you will need:

* a c++ compiler
* [cmake](https://cmake.org/install/)
* SDL2-2.0.10
Please download the "Runtime binairies on [libsdl.org](https://www.libsdl.org/download-2.0.php)
* SDL2-image-2.0.5
Please also download the "Runtime binairies on [libsdl.org/projects/SDL\_image](https://www.libsdl.org/projects/SDL_image/)
* SDL2-mixer-2.0.4
Same [libsdl.org/projects/SDL\_mixer](https://www.libsdl.org/projects/SDL_mixer/)

It is all you will need. Please also have a test BMS file to run the program.

### Instructions

* Clone this repository using:
```
git clone https://github.com/jbyuki/BMS.git
```
or the method you prefer using.

* Extract the libraries into the project folder

```
BMS\
	SDL2_image-2.0.5\
		include\
		lib\
	SDL2_mixer-2.0.4\
		include\
		lib\
	SDL2-2.0.10\
		docs\
		include\
		lib\
```

* Verify the CMakeLists.txt is correct. Check that the library paths are correct.
* Make a build directory in BMS/
```
cd BMS
mkdir build
```

* From within build/, cmake
```
cd build
cmake ..
```

* Before compiling, modify the following lines in main.cpp
```
std::string input = "YOUR BMS FILE PATH HERE".
...
if(!loadSkin"skin/skin.txt PATH HERE", renderer, s)) {
```
One skin is included in the project.

* Compile using your favorite c++ compiler
* Don't forget to put the library .dll in the output folder

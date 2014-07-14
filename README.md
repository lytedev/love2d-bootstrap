# love2d-bootstrap

This repository is meant to add a lot of basic functionality to your projects and is a great base to start a new project on.

# Features

* Flexible and powerful animation system
* In-game console and scripting engine with hooks for realtime development
* Server-client logic baked in from the get-go
* The incredible [hump][hump] library
* Simple assets manager

# Dependencies

## LOVE2D

[Website][love2d]

## Helper Utilities for More Productivity (HUMP)

[Website][hump]

The hump library files must be included in the project. You can quickly grab them with the following command:

`git clone https://github.com/vrld/hump.git lib/hump`

# Build

## Windows

To build your love project, simply run `build.bat`.

This will require that you have the LOVE executable and the necessary DLLs in `lib/love` and that the 7-Zip executable can be found in your PATH.

## Linux

Run `sh build.sh`. You will need to have the love and p7zip packages installed.

**NOTE**: Tested on Arch Linux only.

## OSX

Coming soon?

# TODO

* Sound/music/audio system
* Update client/server classes to use new ENet library in love
* Simple GUI system?

[love2d]: https://love2d.org
[hump]: http://vrld.github.io/hump

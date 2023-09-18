module game;

public import types;

version (SDL)
public import platform.sdl.game;
else
static assert( 0, "Unsupported platform" );

module game;

public import types;

version (SDL)
public import platform.sdl.game;
else
version (WINDOWS_NATIVE)
public import platform.windows.game;
else
static assert( 0, "Unsupported platform" );

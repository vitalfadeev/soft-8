module pool;

version (SDL)
public import platform.sdl.pool;
else
static assert( 0, "Unsupported platform" );

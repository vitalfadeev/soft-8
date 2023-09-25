module types;

version (SDL)
public import platform.sdl.types;
else
version (WINDOWS_NATIVE)
public import platform.windows.types;
else
static assert( 0, "Unsupported platform" );

module ui.window;

version (SDL)
public import platform.sdl.ui.window;
else
version (WINDOWS_NATIVE)
public import platform.windows.ui.window;
else
static assert( 0, "Unsupported platform" );

module ui.window;

version (SDL)
public import platform.sdl.ui.wubdiw;
else
static assert( 0, "Unsupported platform" );

module platform.sdl.ui.wubdiw;

version(SDL):
import bindbc.sdl;
import game;
import sensor;
import types;

class WindowSensor : ISensor
{
    SDL_Window* window;


    this( int w = 640, int h = 480, string name = "SDL2 Window" )
    {
        _create_window( w, h, name );
    }


    void sense( D d )
    {
        switch ( d.t )                           // sensor
        {
            case DT_MOUSEBUTTONDOWN: on_DT_MOUSEBUTTONDOWN( d ); break;
            default: return;
        }

        //
        game.pool ~= DT_MOUSE_LEFT_PRESSED;  // action

        // ANY CODE
        //   check d.m
        //   pool.put( d(sid,m) )
        //   direct action
    }


    pragma( inline, true )
    void on_DT_MOUSEBUTTONDOWN( D d )
    {
        if ( d.button.button == SDL_BUTTON_LEFT )    //
            game.pool ~= DT_MOUSE_LEFT_PRESSED;      // action
    }


    private
    void _create_window(W,H)( W w, H h, string name )
    {
        import std.string;

        // Window
        window = 
            SDL_CreateWindow(
                name.toStringz,
                SDL_WINDOWPOS_CENTERED,
                SDL_WINDOWPOS_CENTERED,
                w, h,
                0
            );

        if ( !window )
            throw new SDLException( "create_window" );

        // Update
        SDL_UpdateWindowSurface( window );    
    }
}

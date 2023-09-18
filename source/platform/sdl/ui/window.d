module platform.sdl.ui.wubdiw;

version(SDL):
import bindbc.sdl;
import game;
import sensor;
import types;

class WindowSensor : ISensor
{
    SDL_Window*   window;
    SDL_Renderer* renderer;


    this( int w = 640, int h = 480, string name = "SDL2 Window" )
    {
        _create_window( w, h, name );
        _create_renderer();
    }


    void sense( D d )
    {
        switch ( d.t )                           // sensor
        {
            case DT_MOUSEBUTTONDOWN: on_DT_MOUSEBUTTONDOWN( d ); break;
            case DT_LA:              on_DT_LA( d ); break;
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
        if ( d.button.button == SDL_BUTTON_LEFT )    // sub sensor
        {
            game.pool ~= DT_MOUSE_LEFT_PRESSED;      // action
            game.pool ~= send_la();                  // action
        }
    }


    auto send_la()
    {
        SDL_Event e;
        e.type = DT_LA;
        e.user.data1 = rect.toVoidPtr(); // rect x,y,w,h
        //e.user.data2 = ...;
        return D(e);
    }

    //
    pragma( inline, true )
    void on_DT_LA( D d )
    {
        auto rect = Rect( d.m );
        import std.stdio;
        writeln( rect );

        la();
    }


    void la_borders()
    {
        la_cola( 0xFF_FF_FF_FF );
        la_rect( 0, 0, size );
    }

    void la_cola( uint rgba )
    {
        ubyte r = ( rgba & 0xFF000000 ) >> 24;
        ubyte g = ( rgba & 0x00FF0000 ) >> 16;
        ubyte b = ( rgba & 0x0000FF00 ) >> 8;
        ubyte a = ( rgba & 0x000000FF );
        SDL_SetRenderDrawColor( renderer, r, g, b, a );
    }

    void la_rect( M16 x, M16 y, Size size )
    {
        // inner rect
        //   0,10 = line 0..9 including 9

        SDL_Rect r;
        r.x = x;
        r.y = y;
        r.w = size.w;
        r.h = size.h;

        SDL_RenderDrawRect( renderer, &r );
    }


    auto size()
    {
        int iw,ih;

        SDL_GetWindowSizeInPixels( window, &iw, &ih );

        import std.conv;
        M16 x,y,w,h;
        w = iw.to!M16;
        h = ih.to!M16;

        return Size( w, h ); // M16,M16
    }

    auto rect()
    {
        int ix,iy,iw,ih;

        SDL_GetWindowPosition( window, &ix, &iy );
        SDL_GetWindowSizeInPixels( window, &iw, &ih );

        import std.conv;
        M16 x,y,w,h;
        x = ix.to!M16;
        y = iy.to!M16;
        w = iw.to!M16;
        h = ih.to!M16;

        return Rect( x, y, w, h ); // M16,M16,M16,M16
    }


    // LIGHT
    // la( xy )               // point  xy
    // la( xy[] )             // points xy[] = ( xy.length, xy.ptr )
    //
    // GO LIGHT
    // la( xy, _xy )        // line  xy to _xy
    // la( xy, _xy, __xy )  // line  xy to _xy to __xy
    // la( xy[] )           // lines xy[] = ( xy.length, xy.ptr )
    void la()
    {
        la_borders();
        SDL_RenderPresent( renderer );
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

    private
    void _create_renderer()
    {
        renderer = SDL_CreateRenderer( window, -1, SDL_RENDERER_SOFTWARE );
    }
}

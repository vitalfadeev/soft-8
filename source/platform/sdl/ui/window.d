module platform.sdl.ui.wubdiw;

version(SDL):
import bindbc.sdl;
import game;
import types;
import cls.o : O;
import cls.o : IVAble, ILaAble, ISenseAble, IStateAble;
import cls.o : VAble,  LaAble,  SenseAble,  StateAble;


class WindowSensor : ISenseAble, IVAble, ILaAble
{
    alias T = typeof(this);

    mixin SenseAble!T;
    mixin LaAble!T;
    mixin VAble!(T,O);

    // Custom memory
    SDL_Window*   window;
    SDL_Renderer* renderer;


    this( PXSize size=PXSize(640,480), string name="SDL2 Window" )
    {
        _create_window( size, name );
        _create_renderer();
    }


    // ISenseAble
    void sense( D d )
    {
        switch ( d.t )                           // sensor
        {
            case DT_MOUSEBUTTONDOWN: on_DT_MOUSEBUTTONDOWN( d ); break;
            case DT_LA:              on_DT_LA( d ); break;
            default: return;
        }
    }


    pragma( inline, true )
    void on_DT_MOUSEBUTTONDOWN( D d )
    {
        if ( d.button.button == SDL_BUTTON_LEFT )  // sub sensor
        {
            game.pool ~= DT_MOUSE_LEFT_PRESSED;    // action
            game.pool ~= D_LA( rect );             // action
        }
    }


    //
    pragma( inline, true )
    void on_DT_LA( D d )
    {
        auto rect = LXRect( d.m );
        import std.stdio;
        writeln( "  ", rect );

        la();
    }


    // ILaAble
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

    void la_rect( M16 x, M16 y, LXSize size )
    {
        // inner rect
        //   0,10 = line 0..9 including 9

        SDL_Rect r;
        r.x = x;
        r.y = y;
        auto px_size = size.to!PX;
        r.w = px_size.x;
        r.h = px_size.y;

        SDL_RenderDrawRect( renderer, &r );
    }


    auto pos()
    {
        PX px_pos;

        SDL_GetWindowPosition( window, &px_pos.x, &px_pos.y );

        return px_pos.to!LX; // M16,M16,M16,M16
    }


    auto size()
    {
        PX px_size;

        SDL_GetWindowSizeInPixels( window, &px_size.x, &px_size.y );

        return px_size.to!LX; // M32,M32 -> F16.16,F16.16
    }

    auto rect()
    {
        return LXRect( pos, size ); // M16,M16,M16,M16
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


    // private
    private
    void _create_window( PXSize size, string name )
    {
        import std.string;

        // Window
        window = 
            SDL_CreateWindow(
                name.toStringz,
                SDL_WINDOWPOS_CENTERED,
                SDL_WINDOWPOS_CENTERED,
                size.x, size.y,
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
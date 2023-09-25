module platform.windows.ui.window;

version(WINDOWS_NATIVE):
import core.sys.windows.windows;
import game;
import types;
import cls.o : O;
import cls.o : IVAble, ILaAble, ISenseAble, IStateAble;
import cls.o : VAble,  LaAble,  SenseAble,  StateAble;


alias Window = WindowSensor;

class WindowSensor : ISenseAble, IVAble, ILaAble
{
    alias T = typeof(this);

    mixin SenseAble!T;
    mixin LaAble!T;
    mixin VAble!T;

    // Custom memory
    HWND hwnd;


    this( PX size=PX(640,480), string name="SDL2 Window" )
    {
        _create_window( size, name );
        _create_renderer();
    }


    // ISenseAble
    pragma( inline, true )
    void on_DT_MOUSEBUTTONDOWN( D d )
    {
        if ( d.button.button == SDL_BUTTON_LEFT )  // sub sensor
        {
            game.pool ~= DT_MOUSE_LEFT_PRESSED;    // action
            game.pool ~= D_LA( pxpx );             // action
        }
    }

    pragma( inline, true )
    void on_DT_LA( D d )
    {
        auto pxpx = d.to!PXPX;
        la();
    }


    // ILaAble
    void la( Renderer renderer ) 
    {
        //
    }

    void la_borders()
    {
        la_cola( 0xFF_FF_FF_FF );
        la_rect( 0, 0, _px );
    }

    void la_cola( uint rgba )
    {
        ubyte r = ( rgba & 0xFF000000 ) >> 24;
        ubyte g = ( rgba & 0x00FF0000 ) >> 16;
        ubyte b = ( rgba & 0x0000FF00 ) >> 8;
        ubyte a = ( rgba & 0x000000FF );
        SDL_SetRenderDrawColor( renderer, r, g, b, a );
    }

    void la_rect( M16 x, M16 y, PX size )
    {
        // inner rect
        //   0,10 = line 0..9 including 9

        SDL_Rect r;
        r.x = x;
        r.y = y;
        r.w = size.x;
        r.h = size.y;

        SDL_RenderDrawRect( renderer, &r );
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
        la_v();
        SDL_RenderPresent( renderer );
    }

    void la_v()
    {
        foreach( o; this.v )
            o.la( Renderer( renderer ) );
    }

    // oxox, px_, _px, pxpx
    auto oxox()
    {
        return OXOX( ox_, _ox ); // M16,M16,M16,M16
    }

    auto ox_()
    {
        return px_.to!OX; 
    }

    auto _ox()
    {
        return _px.to!OX; 
    }

    auto px_()
    {
        PX px;

        SDL_GetWindowPosition( window, &px.x, &px.y );

        return px; // M16,M16,M16,M16
    }


    auto _px()
    {
        PX px;

        SDL_GetWindowSizeInPixels( window, &px.x, &px.y );

        return px; // M32,M32 -> F16.16,F16.16
    }

    auto pxpx()
    {
        return PXPX( px_, _px ); // M16,M16,M16,M16
    }


    // private
    private
    void _create_window( PX size, string name )
    {
        import std.utf : toUTF16z;

        HINSTANCE hInstance = GetModuleHandle(NULL);
        int       iCmdShow = 0;
        
        auto className = toUTF16z( "Window" );
        WNDCLASS wndClass;

        // Window
        wndClass.style         = CS_HREDRAW | CS_VREDRAW;
        wndClass.lpfnWndProc   = &WindowProc;
        wndClass.cbClsExtra    = 0;
        wndClass.cbWndExtra    = 0;
        wndClass.hInstance     = hInstance;
        wndClass.hIcon         = LoadIcon( null, IDI_EXCLAMATION );
        wndClass.hCursor       = LoadCursor( null, IDC_CROSS );
        wndClass.hbrBackground = GetStockObject( DKGRAY_BRUSH );
        wndClass.lpszMenuName  = null;
        wndClass.lpszClassName = className;

        // Register
        if ( !RegisterClass( &wndClass ) ) 
            throw new WindowsException(); //  "Unable to register class" 

        // Create
        hwnd = CreateWindow(
            className,                        //Window class used.
            "The program".toUTF16z,           //Window caption.
            WS_OVERLAPPEDWINDOW,              //Window style.
            CW_USEDEFAULT,                    //Initial x position.
            CW_USEDEFAULT,                    //Initial y position.
            CW_USEDEFAULT,                    //Initial x size.
            CW_USEDEFAULT,                    //Initial y size.
            null,                             //Parent window handle.
            null,                             //Window menu handle.
            hInstance,                        //Program instance handle.
            null                              //Creation parameters.
        );                           

        if ( hwnd == NULL )
            throw new WindowsException();  // "Unable to create window" 

        // Show
        ShowWindow( hwnd, iCmdShow );
        UpdateWindow( hwnd ); 
    }


    private
    void _create_renderer()
    {
        //
    }

    static
    extern( Windows ) nothrow 
    LRESULT WindowProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) 
    {
        switch( message )
        {
            case WM_CREATE : { return WM_CREATE(  hwnd, message, wParam, lParam ); }
            case WM_PAINT  : { return WM_PAINT(   hwnd, message, wParam, lParam ); }
            case WM_DESTROY: { return WM_DESTROY( hwnd, message, wParam, lParam ); }
            default:
                return DefWindowProc( hwnd, message, wParam, lParam );
        }
    }

    static
    auto WM_CREATE( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
    {
        return 0;
    }

    static
    auto WM_PAINT( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
    {
        HDC         hdc;
        PAINTSTRUCT ps; 
        //RECT        crect;
        hdc = BeginPaint( hwnd, &ps );
        //GetClientRect( hwnd, &crect );
        EndPaint( hwnd, &ps ) ;

        return 0;
    }

    static
    auto WM_DESTROY( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam )
    {
        return 0;
    }
}

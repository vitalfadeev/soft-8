module platform.sdl.game;

// Linux
//   pool <- evdev <- device 
//     D( time, type, code, value )
//        M32   M16   M16   M32
// my version
//        M32   M16   M16   M64
//        R64               R64  // on x86_64
//        R32   R32         R32  // on x86
//
// Windows
//   pool <- GetMessage <- device 
//     D( hwnd, message, wParam, lParam, time, pt,  lPrivate )
//        M64   M32      M64     M64     M32   M128 M32  // on x86_64
//        M32   M32      M32     M32     M32   M128 M32  // on x86
// my version
//              M64      M64     M64     M64  // 64
//              R64      R64     R64     R64
//              M32      M32     M32     M32  // 32
//              R32      R32     R32     R32

// OS
// pool
// sensors
// go
//   for d in pool
//     for s in sensors
//       s( d )

version(SDL):
import std.container.dlist : DList;
import std.stdio : writeln;
import std.functional : toDelegate;
import bindbc.sdl;
import pool;
import sensor;
import types;

Game game;  // for each CPU core
            //   pool 1 for all CPU cores

struct Game
{
    static
    Pool    pool;
    Sensors sensors;

    //
    void go()
    {
        foreach( d; pool )
            sensors.sense( d );
    }
}


struct Sensors
{
    SENSOR[] sensors;
    alias sensors this;

    void sense( D d )  // 2 argumnts: ( t, m ):       ( CPU reg1, CPU reg2 )
    {                  //   + this  : ( this, t, m ): ( CPU reg1, CPU reg2, CPU reg3 )
        foreach( s; sensors )
            s( d );
    }

    void opOpAssign( string op : "~" )( SENSOR b )
    {
        this.sensors ~= b;
    }

    void opOpAssign( string op : "~" )( SENSORF b )
    {
        this.sensors ~= toDelegate( b );
    }

    void opOpAssign( string op : "~" )( ISensor b )
    {
        this.sensors ~= &(b.sense);
    }
}




unittest
{
    // function
    // sensor, no-brain, action
    void KeyASensor( D d )
    {
        if ( d.t == DT.KEY_PRESSED )                      // sensor
        if ( d.m == cast(MPTR)'A' )                       //
            game.pool.put( D(DT.KEY_A_PRESSED) );         // action
    }

    // struct.function
    // sensor, no-brain, action
    struct KeyCTRLSensor
    {
        static
        void sense( D d )
        {
            if ( d.t == DT.KEY_PRESSED )                  // sensor
            if ( d.m == cast(MPTR)'!' )                   // 
                game.pool.put( D(DT.KEY_CTRL_PRESSED) );  // action
        }
    }

    // class
    // sensor, brain, action
    class KeysCTRLASensor : ISensor
    {
        bool ctrl;                                           // brain memory
        bool a;

        //
        void sense( D d )
        {
            switch ( d.t )                                   // sensor
            {
                case DT.KEY_CTRL_PRESSED: on_KEY_CTRL_PRESSED( d ); break;
                case DT.KEY_A_PRESSED:    on_KEY_A_PRESSED( d ); break;
                default: return;
            }

            //
            if ( ctrl && a )                                 // brain login
                game.pool.put( D(DT.KEYS_CTRL_A_PRESSED) );  // action

            // ANY CODE
            //   check d.m
            //   pool.put( d(sid,m) )
            //   direct action
        }


        pragma( inline, true )
        void on_KEY_CTRL_PRESSED( D d )
        {
            ctrl = true;                                     // action
        }

        pragma( inline, true )
        void on_KEY_A_PRESSED( D d )
        {
            a = true;                                        // action
        }
    }

    // no-sensor, no-brain, action
    void EachSensor( D d )
    {
        writeln( d );                                        // action
    }

    //
    game.sensors ~= &KeyASensor;
    game.sensors ~= &KeyCTRLSensor.sense;
    game.sensors ~= new KeysCTRLASensor();
    game.sensors ~= &EachSensor;

    //
    game.pool ~= D(DT.KEY_PRESSED, cast(MPTR)'!');
    game.pool ~= D(DT.KEY_PRESSED, cast(MPTR)'A');

    //
    game.go();

    //
    assert( game.pool.empty );
    //assert( a.length == 5 );
    //assert( a == [
    //        D(DT.KEY_PRESSED, cast(MPTR)'!'), 
    //        D(DT.KEY_PRESSED, cast(MPTR)'A'), 
    //        D(DT.KEY_CTRL_PRESSED, null), 
    //        D(DT.KEY_A_PRESSED, null), 
    //        D(DT.KEYS_CTRL_A_PRESSED, null)
    //    ] );
}


unittest
{
    void ClipboardCopy()
    {
        // direct
        // via pool
    }
}


//abstract
//class OClass : SensorClass
//{
//    alias T = typeof(this);

//    DList!T v;
//}


// game.go
pragma( inline, true )
void go()
{
    .game.go();
}

// game.sensors
pragma( inline, true )
ref auto sensors()
{
    return .game.sensors;
}


//
void init_sdl()
{
    SDLSupport ret = loadSDL();

    if ( ret != sdlSupport ) 
    {
        if ( ret == SDLSupport.noLibrary ) 
            throw new Exception( "The SDL shared library failed to load" );
        else 
        if ( ret == SDLSupport.badLibrary ) 
            throw new Exception( "One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-sdl was configured to load (via SDL_204, GLFW_2010 etc.)" );
    }

    loadSDL( "sdl2.dll" );
}


//
void create_window(W,H)( ref SDL_Window* window, W w, H h )
{
    // Window
    window = 
        SDL_CreateWindow(
            "SDL2 Window",
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

//
static
this()
{
    init_sdl();

    // on Windows SDL Window must be created for using event loop
    //   because events going from window &WindowProc
    SDL_Window*  window;
    create_window( window, 640, 480 );
}


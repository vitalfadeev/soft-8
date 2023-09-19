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
import pool : Pool;
import sensor;
import types;
import cls.o : IVAble, ILaAble, ISenseAble, IStateAble;
public import ui.window;

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

    void opOpAssign( string op : "~" )( ISenseAble b )
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
        if ( d.t == DT_KEY_PRESSED )               // sensor
        if ( d.m == cast(MPTR)'A' )                //
            game.pool ~= DT_KEY_A_PRESSED;         // action
    }

    // struct.function
    // sensor, no-brain, action
    struct KeyCTRLSensor
    {
        static
        void sense( D d )
        {
            if ( d.t == DT_KEY_PRESSED )           // sensor
            if ( d.m == cast(MPTR)'!' )            // 
                game.pool ~= DT_KEY_CTRL_PRESSED;  // action
        }
    }

    // class
    // sensor, brain, action
    class KeysCTRLASensor : ISenseAble
    {
        bool ctrl;                                 // brain memory
        bool a;

        //
        void sense( D d )
        {
            switch ( d.t )                         // sensor
            {
                case DT_KEY_CTRL_PRESSED: on_KEY_CTRL_PRESSED( d ); break;
                case DT_KEY_A_PRESSED:    on_KEY_A_PRESSED( d ); break;
                default: return;
            }

            //
            if ( ctrl && a )                          // brain login
                game.pool ~= DT_KEYS_CTRL_A_PRESSED;  // action

            // ANY CODE
            //   check d.m
            //   pool ~= d(sid,m)
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

    //
    game.sensors ~= &KeyASensor;           // func
    game.sensors ~= &KeyCTRLSensor.sense;  // struct 
    game.sensors ~= new KeysCTRLASensor(); // class
    game.sensors ~= function ( D d ) { import std.stdio; writeln( "Lambda Sensor: ", d ); };

    //// SDL require Window for events
    //import ui.window : WindowSensor;
    //auto window_sensor = new WindowSensor();

    //
    game.pool ~= D_KEY_PRESSED( '!' );
    game.pool ~= D_KEY_PRESSED( 'A' );

    ////
    //game.go();
    //
    //
    //assert( game.pool.empty );
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

// game.pool
pragma( inline, true )
ref auto pool()
{
    return .game.pool;
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


void send_la( PX xy )
{
    auto d = xy.to!D;  // rect.xy_
    d.t = DT_LA;
    game.pool ~= d;
}

void send_la( PXPX xyxy )
{
    auto d = xyxy.to!D;  // rect.xy_
    d.t = DT_LA;
    game.pool ~= d;
}


//
static
this()
{
    init_sdl();

    // PS
    // on Windows SDL Window must be created for using event loop
    //   because events going from window &WindowProc
}


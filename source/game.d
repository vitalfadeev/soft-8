module game;

import std.container.dlist : DList;
import std.stdio : writeln;
import std.functional : toDelegate;

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


alias M8      = ubyte;
alias M16     = ushort;
alias M32     = uint;
alias M64     = ulong;
alias MPTR    = void*;
alias SENSOR  = void delegate( D d );
alias SENSORF = void function( D d );


enum DT : M16
{
    _,
    KEY_PRESSED,
    KEY_A_PRESSED,
    KEY_CTRL_PRESSED,
    KEYS_CTRL_A_PRESSED,
}

struct D
{
    DT   t;  // CPU register 1
    MPTR m;  // CPU register 2
}


alias Pool = FIFO!D;


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


interface ISensor
{
    void sense( D d );
}


abstract
class SensorClass
{
    void sense( D d ) {};
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


// SLIST
struct FIFO(T)
{
    struct TLISTITEM
    {
        T a;
        TLISTITEM* next;
    }

    TLISTITEM* f;  // f ........ b
    TLISTITEM* b;  // first      last

    pragma( inline, true )
    bool empty()
    {
        return ( this.f is null );
    }


    pragma( inline, true )
    T front()
    {
        return *( cast( T* )( this.f ) );
    }

    
    pragma( inline, true )
    T back()
    {
        return *( cast( T* )( this.b ) );
    }

    
    pragma( inline, true )
    void popFront()
    {
        if ( this.f is null )
            throw new Exception( "empty fifo" );

        auto next = this.f.next;

        this.f.destroy();

        if ( next is null )
        {
            this.b = null;
            this.f = null;
        }
        else
            this.f = next;
    }


    pragma( inline, true )
    void put( T a )
    {
        auto listitem = new TLISTITEM( a );
        
        if ( this.empty )
        {
            this.f = listitem;
            this.b = listitem;
        }
        else
        {
            this.b.next = listitem;
            this.b      = listitem;
        }
    }


    void opOpAssign( string op : "~" )( T b )
    {
        this.put( b );
    }


    pragma( inline, true )
    auto copy()
    {
        return this;
    }
}

module game;

import std.container.dlist : DList;
import std.stdio : writeln;
import std.functional : toDelegate;


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
    DT   t;
    MPTR m;
}


alias Pool = FIFO!D;


struct Sensors
{
    SENSOR[] sensors;
    alias sensors this;

    void sense( D d )
    {
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
    void KeyASensor( D d )
    {
        if ( d.t == DT.KEY_PRESSED )
        if ( d.m == cast(MPTR)'A' )
            game.pool.put( D(DT.KEY_A_PRESSED) );
    }

    // struct.function
    struct KeyCTRLSensor
    {
        static
        void sense( D d )
        {
            if ( d.t == DT.KEY_PRESSED )
            if ( d.m == cast(MPTR)'!' )
                game.pool.put( D(DT.KEY_CTRL_PRESSED) );
        }
    }

    // class
    class KeysCTRLASensor : ISensor
    {
        bool ctrl;
        bool a;

        void sense( D d )
        {
            switch ( d.t )
            {
                case DT.KEY_CTRL_PRESSED: on_KEY_CTRL_PRESSED( d ); break;
                case DT.KEY_A_PRESSED:    on_KEY_A_PRESSED( d ); break;
                default: return;
            }

            if ( ctrl && a )
                game.pool.put( D(DT.KEYS_CTRL_A_PRESSED) );

            // ANY CODE
            //   check d.m
            //   pool.put( d(sid,m) )
            //   direct action
        }


        pragma( inline, true )
        void on_KEY_CTRL_PRESSED( D d )
        {
            ctrl = true;
        }

        pragma( inline, true )
        void on_KEY_A_PRESSED( D d )
        {
            a = true;
        }
    }

    void EachSensor( D d )
    {
        writeln( d );
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

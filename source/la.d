module la;

import std.stdio;
import types;


alias Cola = Cola32;
alias LA   = M8;

struct Cola32
{
    this( LA r, LA g, LA b, LA a )
    {
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }

    union 
    {
        M32    m32;
        LA[4]  la; 
        struct
        {
            // The Intel x86 CPUs are little endian meaning 
            // that the value 
            // 0x0A0B0C0D 
            // is stored in memory as
            // 0D 0C 0B 0A.
            LA a;
            LA b;
            LA g;
            LA r;
        }
    }
}


struct Map(alias T, M16 X, M16 Y)
{
    T[X][Y] _map;
    alias _map this;

    alias x_size = X;
    alias y_size = Y;
    alias t      = T;
}


struct ColaMap(size_t X, size_t Y)
{
    ColaMap!(Cola,X,Y) _map;
    alias _map this;
}
struct ColaMap(alias T, size_t X, size_t Y)
{
    Map!(T,X,Y) _map;
    alias _map this;
}

unittest
{
    auto map = new ColaMap!(Cola, 1366, 768);
}


class Laer
{
    M*   map;
    M16  x_size;
    M16  y_size;
    M8   cola_size;

    OpStore opstore;


    this(T)( T* map )
    {
        this.map       = map;
        this.x_size    = T.x_size;
        this.y_size    = T.y_size;
        this.cola_size = T.t.sizeof;
    }


    //void La( Loc loc, Cola cola )
    void La( XY xy, Cola cola )
    {
        opstore ~= cast( Op* )( new Op.La( xy, cola ) );
    }


    void Rasterize()
    {
        Rasterizer( this ).Go();
    }
}

unittest
{
    auto map = new ColaMap!(Cola, 640, 480);
    auto laer = new Laer( map );
    laer.La( XY(0,0), Cola( 255, 255, 255, 255 ) );
    //laer.ToXPM();
}

//class SDLLaer : Laer
//{
//    //
//}

// Laer
//   la
//   lai
//   hla
//   polyla
//   round
//   quad
//   roundedQuad
//
// Rasterizer
//   la
//   hla
//   polyla
//   ola
//   qla
//   oQla
//
// Laer
//   la( type.la, data )

struct Op
{
    union
    {
        Opcode opcode;
        La     la;
        Lai    lai;
        Ola    ola;
    }

    Op* next;

    //
    struct La
    {
        Opcode opcode = Opcode.LA;
        //Loc loc;
        XY   xy;
        Cola cola;

        this( XY xy, Cola cola )
        {
            this.xy = xy;
            this.cola = cola;
        }
    }

    struct Lai
    {
        Opcode opcode = Opcode.LAI;
        Loc loc;
        L   l;
    }

    struct Ola
    {
        Opcode opcode = Opcode.OLA;
        Loc c;
        L   r;
    }
}

enum Opcode
{
    _,
    LA,
    LAI,
    OLA,
}


struct OpStore
{
    Op* f;
    Op* l;

    // opstore ~= new Op.La();
    typeof(this) opOpAssign( string op : "~")( Op* b )
    {
        if ( this.f is null )
        {
            this.f = b;
            this.l = b;
        }
        else
        {
            this.l.next = b;
            this.l = b;
        }

        return this;
    }

    void Rotate()
    {
        //
    }

    void Scale()
    {
        //
    }

    void VShift()
    {
        //
    }

    void HShift()
    {
        //
    }

    void Shift()
    {
        //
    }

    void Crop()
    {
        //
    }
}

struct Rasterizer
{
    Laer laer;

    void Go()
    {
        Op* op_;

        if ( laer.opstore.f !is null )
        for( auto op = laer.opstore.f; op !is null;  )
        {
            final
            switch ( op.opcode )
            {
                case Opcode.LA:  { Rasterize_La( op.la ); break; }
                case Opcode.LAI: { break; }
                case Opcode.OLA: { break; }
                case Opcode._:   { break; }
            }

            op_ = op;
            op = op.next;
            op_.destroy();
        }
    }

    void Rasterize_La( Op.La la )
    {
        // La
        //auto xy = loc.ToXY();
        auto xy = la.xy;
        writeln( xy.x );
        writeln( xy.y );
        writeln( laer.x_size );
        writeln( laer.y_size );
        writeln( laer.cola_size );
        //( cast(  COLA** )map )[xy.y][xy.x] = cola;
        M8* m = cast(  M8* )( laer.map );
        auto p = m + (xy.y * laer.x_size + xy.x) * laer.cola_size;
        *p = 0;
        Cola* p_cola = cast( Cola* )p;
        *p_cola = la.cola;
    }
}

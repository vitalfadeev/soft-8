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
            // 0x0A_0B_0C_0D 
            // is stored in memory as
            // 0D 0C 0B 0A.
            LA a;
            LA b;
            LA g;
            LA r;
        }
    }

    enum RMASK = 0x000000FF;
    enum GMASK = 0x0000FF00;
    enum BMASK = 0x00FF0000;
    enum AMASK = 0xFF000000;
}

version(SDL)
import bindbc.sdl;

version(SDL)
struct XYcola
{   // rasterizer
    SDL_Surface* _super;
    alias _super this;

    alias T = typeof(this);

    static
    XYcola ma( XY _xy )
    {
        return 
            T(
                SDL_CreateRGBSurface(
                    0,
                    _xy.x, _xy.y,
                    Cola.sizeof * 8,
                    Cola.RMASK,
                    Cola.GMASK,
                    Cola.BMASK,
                    Cola.AMASK,
                )
            );
    }

    void opAssign( Cola b )
    {
        // overloads a = b

        SDL_Rect rect;
        rect.x = 0;
        rect.y = 0;
        rect.w = _super.w;
        rect.h = _super.h;
        SDL_FillRect( _super, &rect, b.m32 );
    }

    Cola opIndexAssign( Cola b )  
    {
        // overloads a[] = b

        SDL_Rect rect;
        rect.x = 0;
        rect.y = 0;
        rect.w = _super.w;
        rect.h = _super.h;
        SDL_FillRect( _super, &rect, b.m32 );

        return b;
    }


    Cola opIndexAssign( Cola b, XY xy )
    {
        // overloads a[xy] = b
        size_t i = xy.y * _super.pitch + xy.x;
        ( cast(Cola*)( _super.pixels ) )[i] = b;

        return b;
    }
}


void la( ref XYcola xycola, XY xy, Cola cola )
{
    xycola[xy] = cola;
}

void laa( ref XYcola xycola, XY xy, XY _xy,  Cola cola )
{
    if ( xy.y == _xy.y )  // -
        H_laa( xycola, xy, _xy, cola );
    else
    if ( xy.x == _xy.x )  // |
        I_laa( xycola, xy, _xy, cola );
    else
        X_laa( xycola, xy, _xy, cola );
}

void H_laa( ref XYcola xycola, XY xy, XY _xy,  Cola cola )
{
    Cola cola_ptr = cast(Cola*)xycola.pixels;               // EDI
    cola_ptr += xy.y * _super.pitch + xy.x;

    for ( auto CX=_xy.x - xy.x; CX !=0; CX--, cola_ptr++ )  // STOSD
        *cola_ptr = cola;
}
void I_laa( ref XYcola xycola, XY xy, XY _xy,  Cola cola )
{
    //
}
void X_laa( ref XYcola xycola, XY xy, XY _xy,  Cola cola )
{
    //
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

//class SDLLaer : Laer
//{
//    //
//}

// Laer
//   la
//   laa
//   laas
//   round
//   quad
//   roundedQuad
//
// Rasterizer
//   la
//   laa
//   laas
//   ola
//   qla
//   oqla
//
// Laer
//   la( type.la, data )

// G pipeline
//   points, paths
//     add operations, points  // la[], laa[], laam[]
//     zoom
//     rotate
//     brash                   // new lines, remove control line
//     ...detalization         // 1 la -> 2 la
//     crop                    // 
//   rasterize
//     ox -> px
//     cola                    // 
//     mix bg fg               //
//     pixels                  //

// lawana


struct Op
{
    union
    {
        Opcode opcode;
        La     la;
        Laa    laa;
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

    struct Laa
    {
        Opcode opcode = Opcode.LAA;
        //Loc loc;
        //L   l;
    }

    struct Ola
    {
        Opcode opcode = Opcode.OLA;
        //Loc c;
        //L   r;
    }
}

enum Opcode
{
    _,
    LA,
    LAA,
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
                case Opcode.LAA: { break; }
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

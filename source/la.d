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
struct UCcola
{   // rasterizer
    SDL_Surface* _super;
    alias _super this;

    alias T = typeof(this);

    static
    UCcola ma( EA _ea )
    {
        return 
            T(
                SDL_CreateRGBSurface(
                    0,
                    _ea.u, _ea.c,
                    Cola.sizeof * 8,
                    Cola.RMASK,
                    Cola.GMASK,
                    Cola.BMASK,
                    Cola.AMASK,
                )
            );
    }

    void opAssign( Cola cola )
    {
        // overloads a = cola

        SDL_Rect rect;
        rect.x = 0;
        rect.y = 0;
        rect.w = _super.w;
        rect.h = _super.h;
        SDL_FillRect( _super, &rect, cola.m32 );
    }

    Cola opIndexAssign( Cola cola )  
    {
        // overloads a[] = cola

        SDL_Rect rect;
        rect.x = 0;
        rect.y = 0;
        rect.w = _super.w;
        rect.h = _super.h;
        SDL_FillRect( _super, &rect, cola.m32 );

        return cola;
    }


    Cola opIndexAssign( Cola cola, EA e )
    {
        // overloads a[e] = cola
        size_t i = e.c * _super.pitch + e.u;
        ( cast(Cola*)( _super.pixels ) )[i] = cola;

        return cola;
    }
}


void la( ref UCcola uccola, EA e, Cola cola )
{
    uccola[e] = cola;
}

void laa( ref UCcola uccola, EA e, EA _e,  Cola cola )
{
    if ( e == _e )
        {}
    else
    if ( e.c == _e.c )                 // -
        U_laa( uccola, e, _e, cola );
    else
    if ( e.u == _e.u )                 // |
        C_laa( uccola, e, _e, cola );
    else
    if ( ABS(_e.u - e.u) == ABS(_e.c - e.c) ) 
        X_laa( uccola, e, _e, cola );  // 45 degress /
    else
        X_laa( uccola, e, _e, cola );  // /
}

void U_laa( ref UCcola uccola, EA e, EA _e,  Cola cola )
{
    // -
    Cola* cola_ptr = cast(Cola*)uccola.pixels;               // EDI
    cola_ptr += e.c * uccola.pitch + ea.u;

    for ( auto CX=_e.u - e.u; CX; CX--, cola_ptr++ )         // STOSD
        *cola_ptr = cola;
}
void C_laa( ref UCcola uccola, EA e, EA _e,  Cola cola )
{
    // |
    Cola* cola_ptr = cast(Cola*)uccola.pixels;               // EDI
    cola_ptr += e.c * uccola.pitch + e.u;
    auto pitch = uccola.pitch;

    for ( auto CX=_e.c - e.c; CX; CX--, cola_ptr+=pitch )
        *cola_ptr = cola;
}
void X_laa( ref uccola uccola, EA e, EA _e, Cola cola )
{
    //                                                          c
    // 0                       1                        2    // _y - y = 1
    // #########################                             // 0
    //                          #########################    // 1
    //
    //
    // 0               1                2               3_   // _y - y = 2
    // #################                                     // 0
    //                  #################                    // 1
    //                                   ################    // 2
    //
    // 0      1                2                3       4    // _y - y = 2
    // ########                                              // 2_
    //         #################                             // 0
    //                          #################            // 1
    //                                           ########    // _2
    //
    //
    // 0          1            2            3           4    // _y - y = 3
    // ############                                          // 0
    //             #############                             // 1
    //                          #############                // 2
    //                                       ############    // 3
    //                                                          c
    // |<-------->|
    //      eu      = ( _x - x ) / ( _y - y )
    //
    auto w = uccola.w;
    Cola* cola_ptr = 
        ( cast(Cola*)uccola.pixels ) + e.c * w + e.u;

    auto u  = ( _e.u - e.u );
    auto c  = ( _e.c - e.c );

    if ( u > c )  //  0..45 degress
        {}
    else          // 45..90 degress
        swap( u, c );

    auto eu = u / c;
    auto _  = u % c;

    if ( _ == 0 )
    {
        auto u1  = eu;
        auto u2  = eu;
        auto u2n = c;
        auto u3  = eu;
    }
    else
    {        
        auto u1  = _ / 2;
        auto _   = _ % 2;
        auto u2  = eu;
        auto u2n = c;
        auto u3  = u1 - _;
    }


    // -,-   |   +,-
    //       |     
    // ------+-----> u
    //       |      
    // -,+   v   +,+
    //       c

    auto dc = _e.c - e.c;
    auto du = _e.u - e.u;

    // ↙↘
    if ( dc > 0 )
    {
        // ↘
        if ( du > 0 )
        {
            template_inst( cola_ptr, u1, u2, u2n, u3, "+", "+" );
        }
        else
        // ↙
        {
            template_inst( cola_ptr, u1, u2, u2n, u3, "-", "+" );
        }
    }
    else
    // ↖↗
    {
        // ↗
        if ( du > 0 )
        {
            template_inst( cola_ptr, u1, u2, u2n, u3, "+", "-" );
        }
        else
        // ↖
        {
            template_inst( cola_ptr, u1, u2, u2n, u3, "-", "-" );
        }
    }


    // ↘
    template template_inst( alias u1, alias u2, alias u2n, alias u3, string cola_ptr_u_op, string cola_ptr_c_op )
        if ( ( us == "+" || us == "-" ) &&
             ( cs == "+" || cs == "-" ) )
    {
        // 0..1
        if (u1) 
            for ( auto ecx=u1; ecx; ecx--, mixin("cola_ptr"~us~us) )
                *cola_ptr = cola;

            // if 1..5
            //   mov [ptr], cola
            //   mov [ptr], cola
            //   mov [ptr], cola
            //   mov [ptr], cola
            //   mov [ptr], cola
            // if 16 | 32 bytes
            //   MOVDQA [RCX],XMM0
            // else
            //   core.stdc.string
            //   void* memset(return scope void* s, int c, size_t n);
            //   cola_ptr = memset( cola_ptr, cola, n );  
            //     call..ret overhead

        // 1..2..3
        if (u2) 
            for ( auto ecy=u2n; ecy; ecy--, mixin("cola_ptr"~cs~"=w") )  // +=w | -=w
                for ( auto ecx=u2; ecx; ecx--, mixin("cola_ptr"~us~us) )
                    *cola_ptr = cola;

        // 3..4
        if (u3) 
            for ( auto ecx=u3; ecx; ecx--, mixin("cola_ptr"~us~us) )
                *cola_ptr = cola;
            
    }
}


auto ABS(T)(T a)
{
    return 
        ( a < 0) ? 
            (-a):
            ( a);
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
    void La( EA ea, Cola cola )
    {
        opstore ~= cast( Op* )( new Op.La( ea, cola ) );
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
        EA   ea;
        Cola cola;

        this( EA ea, Cola cola )
        {
            this.ea = ea;
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
        //auto ea = loc.ToEA();
        auto ea = la.ea;
        writeln( ea.x );
        writeln( ea.y );
        writeln( laer.x_size );
        writeln( laer.y_size );
        writeln( laer.cola_size );
        //( cast(  COLA** )map )[ea.y][ea.x] = cola;
        M8* m = cast(  M8* )( laer.map );
        auto p = m + (ea.y * laer.x_size + ea.x) * laer.cola_size;
        *p = 0;
        Cola* p_cola = cast( Cola* )p;
        *p_cola = la.cola;
    }
}

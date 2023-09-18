module types;

//import std.conv;
//import std.format;
import std.stdio;
import fixed_16_16;


alias M       = void;
alias M1      = bool;
alias M8      = ubyte;
alias M16     = ushort;
alias M32     = uint;
alias M64     = ulong;
alias MPTR    = void*;
alias SENSOR  = void delegate( D d );
alias SENSORF = void function( D d );


struct CS
{
    C c; // a
    S s; // R

    XY ToXY()
    {
        // L = 65536/4 = 16384
        // l = 1/L = 1/16384
        // R = 0..65536 (0..65536/6 = 0..10922)  // S
        // a = 0..16384/16384                    // C
        // x = (     ( l * a ) ) * R
        // y = ( 1 - ( l * a ) ) * R

        auto L = 65536/4; // = 16384
        auto R = s;
        auto a = c;

        auto x = (a * R) / L;
        auto y = R - x;

        return XY( X(x), Y(y) );
    }
}

unittest
{
    auto cs = CS( 
        C( 65536/4/2 ), // 45 deg = 8192
        S( 4 )
    );
    auto xy = cs.ToXY();
    writeln( xy );
}

struct XY
{
    X x;
    Y y;

    this( M16 x, M16 y )
    {
        this.x = x;
        this.y = y;
    }

    CS ToCS()
    {
        // L = 65536/4 = 16384
        // l = 1/L = 1/16384
        // s = y + x
        // c = x/(l(y + x))

        auto L = 65536/4; // = 16384
        auto s = y + x;
        auto c = x * L / s;

        return CS( C(c), S(s) );
    }
}

unittest
{
    auto xy = XY( 
        X( 2 ),
        Y( 2 )
    );
    auto cs = xy.ToCS();
    writeln( cs );
}

struct C
{
    //Fixed_16_16 a;
    M16 a;
    alias a this;

    this( M32 a )
    {
        this.a = cast(M16)a;
    }
}

struct S
{
    //Fixed_16_16 a;
    M16 a;
    alias a this;

    this( M32 a )
    {
        this.a = cast(M16)a;
    }
}

struct X
{
    //Fixed_16_16 a;
    M16 a;
    alias a this;

    this( M32 a )
    {
        this.a = cast(M16)a;
    }
}

struct Y
{
    //Fixed_16_16 a;
    M16 a;
    alias a this;

    this( M32 a )
    {
        this.a = cast(M16)a;
    }
}

struct L
{
    M16 a;
    alias a this;

    this( M32 a )
    {
        this.a = cast(M16)a;
    }
}


class Renderer
{
    //
}

struct Ars
{
    M16 a;
    alias a this;    
}


struct Loc
{
    CS cs;
    alias cs this;

    this( CS cs )
    {
        this.cs = cs;
    }

    this( M16 c, M16 s )
    {
        this.cs = CS( C(c), S(s) );
    }
}


version(SDL)
{
    import bindbc.sdl;
    alias DT = SDL_EventType;
}
else
{
    alias DT = M16;
}
enum: DT
{
    _,
    // SDL
    KEY_PRESSED,
    KEY_A_PRESSED,
    KEY_CTRL_PRESSED,
    KEYS_CTRL_A_PRESSED,
    //
    DT_MOUSEBUTTONDOWN = SDL_MOUSEBUTTONDOWN,
    // game
    DT_USER_ = 0x8000,
    DT_MOUSE_LEFT_PRESSED,
    DT_LA,
}


version(SDL)
{
    import bindbc.sdl;

    struct D
    {
        SDL_Event _e;
        alias _e this;

        pragma( inline, true )
        auto t()
        {
            return _e.type;
        }

        pragma( inline, true )
        auto m()
        {
            return _e.user.data1;
        }

        string toString()
        {
            import std.format;
            return 
                format!"%s( %s:%d )"(
                    typeof(this).stringof,
                    _e.type.toString,
                    _e.type
                );
        }
    }

    string toString( SDL_EventType t )
    {
        import std.traits;
        import std.string;
        import sdl.events;

        static foreach( name; __traits(allMembers, sdl.events) )
        static if ( name.startsWith( "SDL_") )
            static if ( is( typeof( __traits( getMember, types, name ) ) == SDL_EventType ) )
                if ( t == __traits( getMember, sdl.events, name ) ) return name;

        import std.format;
        return format!"UserEvent_0x%X"( t );
    }
}
else
{
    struct D
    {
        M16  t;  // CPU register 1
        MPTR m;  // CPU register 2
    }
}

version(SDL)
{
    import bindbc.sdl;

    class SDLException : Exception
    {
        this( string msg )
        {
            import std.format;
            super( format!"%s: %s"( SDL_GetError(), msg ) );
        }
    }
}


struct LXRect
{
    union
    {    
        struct
        {    
            LX p;  // pos
            LX s;  // size
        }
        MPTR mptr;
    }

    this( LX lx_pos, LX lx_size )
    {
        this.p = lx_pos;
        this.s = lx_size;
    }

    this( MPTR mptr )
    {
        this.mptr = mptr;
    }

    MPTR to(T:MPTR)()
    {
        return mptr;
    }
}

struct PXRect
{
    union
    {
        struct
        {
            PX p;  // pos
            PX s;  // size
        }
        MPTR mptr;
    };

    this( M16 x, M16 y, M16 w, M16 h )
    {
        this.p = PX(x,y);
        this.s = PX(w,h);
    }

    this( MPTR mptr )
    {
        this.mptr = mptr;
    }


    MPTR to(T:MPTR)()
    {
        return mptr;
    }
}


// SX
// LX
// PX
//
// Sense element 
//   sensel 
//   sx
// Location element
//   locxel
//   lx
// picture element
//   pixel
//   px

// sx -> lx -> px
//
// px -> lx -> sx
//
// px
//   640 x 480                      m16 x m16
// lx 
//   640.00 x 480.00  fixed 16.16   m32 x m32
// sx
//   640 x 480                      m16 x m16

version(SDL)
{
    alias PX_X = int;
    alias PX_Y = int;  // PX_TX
}
else
{
    alias PX_X = M16;
    alias PX_Y = M16;  // PX_TX
}

struct PX
{
    PX_X x; 
    PX_Y y;

    LX to(T:LX)()
    {
        return LX( x, y );
    }

    SX to(T:SX)()
    {
        return SX();
    }
}

struct LX
{
    // (x,y) or can be (c,s)
    Fixed_16_16 x;
    Fixed_16_16 y;

    this( M16 x, M16 y )
    {
        this.x = x;
        this.y = y;
    }

    this( PX_X x, PX_Y y )
    {
        import std.conv;
        this.x.h = x.to!(typeof(Fixed_16_16.h));
        this.y.h = y.to!(typeof(Fixed_16_16.h));
    }

    PX to(T:PX)()
    {
        return 
            PX(
                // px         lx
                // ------ = k ------
                // px.max     lx.max
                //
                // px = k * lx * px.max / lx.max
                //
                // sx = 3x3
                //      touch 3x3
                // lx = 65536x65536
                //      map 16368 x 16368
                // px = 640x480
                //      window 640x480

                this.x.to!(typeof(PX.x)),
                this.y.to!(typeof(PX.y))
            );
    }

    SX to(T:SX)()
    {
        return SX();
    }
}

struct SX
{
    M16 x;
    M16 y;

    LX to(T:LX)()
    {
        return LX();
    }

    PX to(T:PX)()
    {
        return PX();
    }
}


alias LXSize = LX;

module types;

//import std.conv;
//import std.format;
import std.stdio;
import std.traits;
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
    //_,
    // SDL
    // ...
    //
    DT_MOUSEBUTTONDOWN = SDL_MOUSEBUTTONDOWN,
    // game
    DT_USER_ = 0x8000,
    DT_MOUSE_LEFT_PRESSED,
    DT_LA,
    DT_KEY_PRESSED,
    DT_KEY_A_PRESSED,
    DT_KEY_CTRL_PRESSED,
    DT_KEYS_CTRL_A_PRESSED,
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

    struct D_LA
    {
        SDL_UserEvent e;
        alias e this;

        this( LXRect rect )
        {        
            e.type  = DT_LA;
            e.data1 = rect.to!MPTR();
        }
    }

    struct D_KEY_PRESSED
    {
        SDL_UserEvent e;
        alias e this;

        this( char a )
        {        
            e.type  = DT_KEY_PRESSED;
            e.data1 = cast(MPTR)a;
        }
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

// Big
//   small
//     loca
//
// 1 big = 3 small
// 1 big = 3x3 small
// 
// 2 big = 3 small
//   k = (2,3)
//   k = K(2,3)
//   k = (2,3).k
//
// loca
//   i
//   xy
//   cs

// Picture
//   640x480
//   PX

// World > Picture
// World = Picture
// World < Picture
//
// World > Picture
//   65536x65536 > 640x480
//     desize World to 640x480  // dec size  // reduce  // desize
//     crop   World to 640x480
//     -> 65536x65536 is loxels (location elements). lx. is oxels (o elemets). ox
//     -> 640x480 is wixels (window elements). wx. is pixel (picture element). px
// World = Picture
//   65536x65536 = 640x480
//     ok
// World < Picture
//   65536x65536 < 640x480
//     ok

// ox
// px

// ox  // max     detalization
// px  // picture detalization
// sx  // sensor  detalization

// sensor -> sx->ox 
//   kasx 
//     1 kasx = 100 ox
//     1 касание = 100 элементов мира
//
// sensor.kasx
//   sx -> ox
//   .to!OX

// sensor - touch - (x,y).sx
//   sx -> ox
//     .to!OX
//       ox = ka * sx  // ka = 1..255
//   (100x100).ox

// sensor element location
//   depends from sensor detalization
// is:
//   touch-screen matrix
//   mouse move position
//   mouse position
struct SX_(X,Y)
{
    alias TXY = Largest!(X,Y);

    union
    {
        struct
        {
            X x;
            Y y;
        }
        TXY xy;
    }

    auto to(T:OX)()
    {
        return OX();
    }

    auto to(T:MPTR)()
    {
        static assert( TXY.sizeof <= MPTR.sizeof, "Expect TXY <= MPTR" );
        return cast(MPTR)xy;
    }
}


// O element location
//   depends from o detalization
// is: 
//   world matrix
struct OX_(X,Y)
{
    alias TXY = Largest!(X,Y);

    union
    {
        struct
        {
            X x;
            Y y;
        }
        TXY xy;
    }

    auto to(T:PX)()
    {
        return PX();
    }

    auto to(T:MPTR)()
    {
        static assert( TXY.sizeof <= MPTR.sizeof, "Expect TXY <= MPTR" );
        return cast(MPTR)xy;
    }
}


// picture element location
//   depends from picture detalization
// is: 
//   display matrix
//   picture im memory
struct PX_(X,Y)
{
    enum X_MAX = 640;
    enum Y_MAX = 480;
    alias TXY = Detect8bitAlignedType!(X,Y);  // M8, M16, M32, M64

    union
    {
        struct
        {
            X x;
            Y y;
        }
        TXY xy;
    }

    auto to(T:OX)()
    {
        return OX();
    }

    auto to(T:IX)()
    {
        return IX( ( y * X_MAX ) + x );
    }

    // x,y to R1
    // x,y to R1, R2
    // x,y to e.user.data1
    // x,y to e.user.data1, e.user.data2
    auto to(T:MPTR)()
    {
        static assert( TXY.sizeof <= MPTR.sizeof, "Expect TXY <= MPTR" );
        return cast(MPTR)xy;
    }

    auto to(T:D)()
    {
        SDL_UserEvent d;

        if ( TXY.sizeof <= MPTR.sizeof )
            d.user.data1 = cast(MPTR)xy;
        else
        {
            d.user.data1 = cast(MPTR)x;
            d.user.data2 = cast(MPTR)y;
        }

        return d;
    }
}


// index of element
//   10.ix
//   (3,3).px = (9).ix = 9
// is:
//   unique index
//   UUID
//   size_t
//   int
//   ubyte
struct IX_(T)
{
    T i;

    auto to(T:PX)()
    {
        auto y = i / PX.X_MAX;  // integer part
        auto x = i % PX.X_MAX;  // frac part

        return PX( x, y );
    }
}


version(SDL)
{
    alias SX = SX_!( typeof( SDL_MouseMotionEvent.x ), typeof( SDL_MouseMotionEvent.x ) );
    alias OX = OX_!( Fixed_16_16, Fixed_16_16 );
    alias PX = PX_!( typeof( SDL_Point.x ), typeof( SDL_Point.y ) );
    alias IX = IX_!size_t;
}
else
{
    alias SX = SX_!( M16, M16 );
    alias OX = OX_!( Fixed_16_16, Fixed_16_16 );
    alias PX = PX_!( M16, M16 );
    alias IX = IX_!size_t;
}


struct PXPX
{
    PX px_;
    PX _px;
    alias TPXPX = Detect8bitAlignedType!(PX,PX);

    // x,y to R1
    // x,y to R1, R2
    // x,y to e.user.data1
    // x,y to e.user.data1, e.user.data2
    auto to(T:MPTR)()
    {
        static assert( (TLARGEST.sizeof + TLARGEST.sizeof) <= MPTR.sizeof, "Expect TXY <= MPTR" );
        return cast(MPTR)xy;
    }

    auto to(T:D)()
    {
        SDL_UserEvent d;

        if ( TXY.sizeof <= MPTR.sizeof )
            d.user.data1 = cast(MPTR)xy;
        else
        {
            d.user.data1 = cast(MPTR)x;
            d.user.data2 = cast(MPTR)y;
        }

        return d;
    }
}

void send_la( PX xy )
{
    auto d = xy.to!D;  // rect.xy_
    d.type = D_LA;
    //e.user.data1 = xy.to!D();
    //e.user.data2 = null;
    game.pool ~= d;
}

void send_la( PXPX xyxy )
{
    auto d = xyxy.to!D;  // rect.xy_
    d.type = D_LA;
    //e.user.data1 = xyxy.xy_.to!D();
    //e.user.data2 = xyxy._xy.to!D();
    game.pool ~= d;
}

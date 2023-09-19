module types;

//import std.conv;
//import std.format;
import std.container.dlist : DList;
import std.traits;
import traits;
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


struct Renderer
{
    SDL_Renderer* renderer;

    void la()
    {
        la( center );
    }

    void la( PX px )
    {
        SDL_RenderDrawPoint( renderer, px.x, px.y );
    }

    void la( OX ox )
    {
        la( ox.to!PX + center );
    }

    void la( PX px, PX _px )
    {
        import std.stdio : writeln;
        writeln( "la: PX: ", px, ", ", _px );
        SDL_RenderDrawLine( renderer, px.x, px.y, _px.x, _px.y );
    }

    void la( OX ox, OX _ox )
    {
        la( ox.to!PX + center, _ox.to!PX + center );
    }

    void la( OX ox, OX[] _oxs )
    {
        auto px_ = ox.to!PX + center;
        PX   _px;

        foreach( _ox; _oxs )
        {
            _px = _ox.to!PX + center;
            
            la( px_, _px );

            px_ = _px;
        }
    }

    PX center()
    {
        return PX( 640/2, 480/2 );
    }
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


        auto to(T:PXPX)()
        {
            PX px_ = PX.fromMPTR( _e.user.data1 );
            PX _px = PX.fromMPTR( _e.user.data2 );
            return PXPX( px_, _px );
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

        this( PXPX rect )
        {        
            e = rect.to!D();
            e.type  = DT_LA;
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
    alias TXY = Detect8bitAlignedType!(X,Y);

    union
    {
        struct
        {
            X x;
            Y y;
        }
        TXY xy;
    }

    void opAssign( PX px )
    {
        x.h = cast(ushort)px.x;
        x.l = 0;
        y.h = cast(ushort)px.y;
        y.l = 0;
    }

    auto to(T:PX)()
    {
        return PX( x.h, y.h );
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
    alias T = typeof(this);

    union
    {
        struct
        {
            X x;
            Y y;
        }
        TXY xy;
    }
    alias TXY = Detect8bitAlignedType!(X,Y);  // M8, M16, M32, M64

    static
    T fromMPTR( MPTR mptr )
    {
        T px;
        px.xy = cast(TXY)mptr;
        return px;
    }

    auto to(T:PX)()
    {
        return this;
    }

    auto to(T:OX)()
    {
        OX ox;
        ox.x.h = cast(ushort)this.x;
        ox.x.l = 0;
        ox.y.h = cast(ushort)this.y;
        ox.y.l = 0;
        return ox;
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
        alias TDATA1 = typeof( d.data1 );
        alias TDATA2 = typeof( d.data2 );

        if ( TXY.sizeof <= TDATA1.sizeof )
            d.data1 = cast(TDATA1)xy;
        else
        {
            d.data1 = cast(TDATA1)x;
            d.data2 = cast(TDATA2)y;
        }

        return d;
    }

    // + - * /
    T opBinary( string op : "+" )( T b )
    {
        return T( x + b.x, y + b.y );
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
    union
    {
        struct
        {
            PX px_;
            PX _px;
        }
        TPXPX pxpx;
    }    
    alias TPXPX = Detect8bitAlignedType!(PX,PX);

    // x,y to R1
    // x,y to R1, R2
    // x,y to e.user.data1
    // x,y to e.user.data1, e.user.data2
    auto to(T:MPTR)()
    {
        static assert( TPXPX.sizeof <= MPTR.sizeof, "Expect PXPX <= MPTR" );
        return cast(MPTR)xy;
    }

    auto to(T:PXPX)()
    {
        return this;
    }

    auto to(T:D)()
    {
        SDL_UserEvent d;
        alias TDATA1 = typeof( d.data1 );
        alias TDATA2 = typeof( d.data2 );

        if ( TPXPX.sizeof <= TDATA1.sizeof )
            d.data1 = cast(TDATA1)pxpx;
        else
        {
            d.data1 = px_.to!TDATA1;
            d.data2 = _px.to!TDATA2;
        }

        return d;
    }
}


// O
//   v o
// IVAble
import cls.o : O;
alias V = DList!O;

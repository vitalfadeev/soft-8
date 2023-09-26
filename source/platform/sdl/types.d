module platform.sdl.types;

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

    import std.stdio : writeln;
    writeln( xy );
}

// struct XY     
// struct UC
// struct ↦↥
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

    C to(C)()
    {
        return x / y;
    }

    XY opBinary(string op:"+")( XY b )
    {
        return XY( X(x + b.x), Y(y + b.y) );
    }

    XY opBinary(string op:"-")( XY b )
    {
        return XY( X(x - b.x), Y(y - b.y) );
    }
}

alias A = size_t;

unittest
{
    auto xy = XY( 
        X( 2 ),
        Y( 2 )
    );
    auto cs = xy.ToCS();

    import std.stdio : writeln;
    writeln( cs );
}

struct C
{
    //Fixed_16_16 a;
    M16 a;  // 1/65536 part of round
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

    C opBinary(string op : "/")( Y y )
    {
        // C = X / Y
        return C( a / y );
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

    void la( EA ea )
    {
        SDL_RenderDrawPoint( renderer, ea.x, ea.y );
    }

    void la( EO eo )
    {
        la( eo.to!EA + center );
    }

    void la( EA ea, EA _ea )
    {
        SDL_RenderDrawLine( renderer, ea.x, ea.y, _ea.x, _ea.y );
    }

    void la( EO eo, EO _eo )
    {
        la( eo.to!EA + center, _eo.to!EA + center );
    }

    void la( EO eo, EO[] _eos )
    {
        auto ea_ = eo.to!EA + center;
        EA   _ea;

        foreach( _eo; _eos )
        {
            _ea = _eo.to!EA + center;
            
            la( ea_, _ea );

            ea_ = _ea;
        }
    }

    EA center()
    {
        return EA( 640/2, 480/2 );
    }
}

struct Ars
{
    M16 a;
    alias a this;    
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
    DT_FIRSTEVENT               = SDL_FIRSTEVENT,
    DT_QUIT                     = SDL_QUIT,
    DT_APP_TERMINATING          = SDL_APP_TERMINATING,
    DT_APP_LOWMEMORY            = SDL_APP_LOWMEMORY,
    DT_APP_WILLENTERBACKGROUND  = SDL_APP_WILLENTERBACKGROUND,
    DT_APP_DIDENTERBACKGROUND   = SDL_APP_DIDENTERBACKGROUND,
    DT_APP_WILLENTERFOREGROUND  = SDL_APP_WILLENTERFOREGROUND,
    DT_APP_DIDENTERFOREGROUND   = SDL_APP_DIDENTERFOREGROUND,
    DT_WINDOWEVENT              = SDL_WINDOWEVENT,
    DT_SYSWMEVENT               = SDL_SYSWMEVENT,
    DT_KEYDOWN                  = SDL_KEYDOWN,
    DT_KEYUP                    = SDL_KEYUP,
    DT_TEXTEDITING              = SDL_TEXTEDITING,
    DT_TEXTINPUT                = SDL_TEXTINPUT,
    DT_MOUSEMOTION              = SDL_MOUSEMOTION,
    DT_MOUSEBUTTONDOWN          = SDL_MOUSEBUTTONDOWN,
    DT_MOUSEBUTTONUP            = SDL_MOUSEBUTTONUP,
    DT_MOUSEWHEEL               = SDL_MOUSEWHEEL,
    DT_JOYAXISMOTION            = SDL_JOYAXISMOTION,
    DT_JOYBALLMOTION            = SDL_JOYBALLMOTION,
    DT_JOYHATMOTION             = SDL_JOYHATMOTION,
    DT_JOYBUTTONDOWN            = SDL_JOYBUTTONDOWN,
    DT_JOYBUTTONUP              = SDL_JOYBUTTONUP,
    DT_JOYDEVICEADDED           = SDL_JOYDEVICEADDED,
    DT_JOYDEVICEREMOVED         = SDL_JOYDEVICEREMOVED,
    DT_CONTROLLERAXISMOTION     = SDL_CONTROLLERAXISMOTION,
    DT_CONTROLLERBUTTONDOWN     = SDL_CONTROLLERBUTTONDOWN,
    DT_CONTROLLERBUTTONUP       = SDL_CONTROLLERBUTTONUP,
    DT_CONTROLLERDEVICEADDED    = SDL_CONTROLLERDEVICEADDED,
    DT_CONTROLLERDEVICEREMOVED  = SDL_CONTROLLERDEVICEREMOVED,
    DT_CONTROLLERDEVICEREMAPPED = SDL_CONTROLLERDEVICEREMAPPED,
    DT_FINGERDOWN               = SDL_FINGERDOWN,
    DT_FINGERUP                 = SDL_FINGERUP,
    DT_FINGERMOTION             = SDL_FINGERMOTION,
    DT_DOLLARGESTURE            = SDL_DOLLARGESTURE,
    DT_DOLLARRECORD             = SDL_DOLLARRECORD,
    DT_MULTIGESTURE             = SDL_MULTIGESTURE,
    DT_CLIPBOARDUPDATE          = SDL_CLIPBOARDUPDATE,
    DT_DROPFILE                 = SDL_DROPFILE,
    // game
    DT_USER_                    = SDL_USEREVENT,
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
        auto ref t()
        {
            return _e.type;
        }

        pragma( inline, true )
        auto ref m()
        {
            return _e.user.data1;
        }


        auto to(T:EAEA)()
        {
            EA ea_ = EA.fromMPTR( _e.user.data1 );
            EA _ea = EA.fromMPTR( _e.user.data2 );
            return EAEA( ea_, _ea );
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
        D d;
        alias d this;

        this( EAEA rect )
        {        
            d = rect.to!D();
            d.t = DT_LA;
        }
    }

    struct D_KEY_PRESSED
    {
        D d;
        alias d this;

        this( char a )
        {        
            d.t  = DT_KEY_PRESSED;
            d.m = cast(MPTR)a;
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

version(WINDOWS_NATIVE)
{
    import core.sys.windows.windows;
    import std.windows.syserror : WindowsException;
}




// ES
// EO
// EA
//
// Sense element 
//   sensel 
//   es
// Location element
//   locxel
//   lx
// picture element
//   pixel
//   ea

// es -> lx -> ea
//
// ea -> lx -> es
//
// ea
//   640 x 480                      m16 x m16
// lx 
//   640.00 x 480.00  fixed 16.16   m32 x m32
// es
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
//   EA

// World > Picture
// World = Picture
// World < Picture
//
// World > Picture
//   65536x65536 > 640x480
//     desize World to 640x480  // dec size  // reduce  // desize
//     crop   World to 640x480
//     -> 65536x65536 is leoels (location elements). lx. is eoels (o elemets). eo
//     -> 640x480 is wixels (window elements). wx. is pixel (picture element). ea
// World = Picture
//   65536x65536 = 640x480
//     ok
// World < Picture
//   65536x65536 < 640x480
//     ok

// eo
// ea

// eo  // max     detalization
// ea  // picture detalization
// es  // sensor  detalization

// sensor -> es->eo 
//   kaes 
//     1 kaes = 100 eo
//     1 касание = 100 элементов мира
//
// sensor.kaes
//   es -> eo
//   .to!EO

// sensor - touch - (x,y).es
//   es -> eo
//     .to!EO
//       eo = ka * es  // ka = 1..255
//   (100x100).eo

// sensor element location
//   depends from sensor detalization
// is:
//   touch-screen matrix
//   mouse move position
//   mouse position
struct ES_(X,Y)
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

    auto to(T:EO)()
    {
        EO eo;
        eo.x.h = cast(short)this.x;
        eo.x.l = 0;
        eo.y.h = cast(short)this.y;
        eo.y.l = 0;
        return eo;
    }


    auto to(T:MPTR)()
    {
        static assert( TXY.sizeof <= MPTR.sizeof, "Expect TXY <= MPTR" );
        return cast(MPTR)xy;
    }


    string toString()
    {
        import std.format;
        return 
            format!"%s( %d,%d )"(
                typeof(this).stringof,
                x,
                y
            );
    }
}


// O element location
//   depends from o detalization
// is: 
//   world matrix
struct EO_(X,Y)
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

    void opAssign( EA ea )
    {
        // convert EA -> EO
        x.h = cast(short)ea.x;
        x.l = 0;
        y.h = cast(short)ea.y;
        y.l = 0;
    }

    auto to(T:EA)()
    {
        return EA( x.h, y.h );
    }

    auto to(T:MPTR)()
    {
        static assert( TXY.sizeof <= MPTR.sizeof, "Expect TXY <= MPTR" );
        return cast(MPTR)xy;
    }

    string toString()
    {
        import std.format;
        return 
            format!"%s( %d,%d )"(
                typeof(this).stringof,
                x.h,
                y.h
            );
    }
}


// picture element location
//   depends from picture detalization
// is: 
//   display matrix
//   picture im memory
struct EA_(X,Y)
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
        T ea;
        ea.xy = cast(TXY)mptr;
        return ea;
    }

    auto to(T:EA)()
    {
        return this;
    }

    auto to(T:EO)()
    {
        EO eo;
        eo.x.h = cast(short)this.x;
        eo.x.l = 0;
        eo.y.h = cast(short)this.y;
        eo.y.l = 0;
        return eo;
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
        D d;
        alias TDATA1 = typeof( d.user.data1 );
        alias TDATA2 = typeof( d.user.data2 );

        if ( TXY.sizeof <= TDATA1.sizeof )
            d.user.data1 = cast(TDATA1)xy;
        else
        {
            d.user.data1 = cast(TDATA1)x;
            d.user.data2 = cast(TDATA2)y;
        }

        return d;
    }

    // + - * /
    T opBinary( string op : "+" )( T b )
    {
        return T( x + b.x, y + b.y );
    }

    string toString()
    {
        import std.format;
        return 
            format!"%s( %d,%d )"(
                typeof(this).stringof,
                x,
                y
            );
    }
}


// index of element
//   10.ix
//   (3,3).ea = (9).ix = 9
// is:
//   unique index
//   UUID
//   size_t
//   int
//   ubyte
struct IX_(T)
{
    T i;

    auto to(T:EA)()
    {
        auto y = i / EA.X_MAX;  // integer part
        auto x = i % EA.X_MAX;  // frac part

        return EA( x, y );
    }
}


version(SDL)
{
    alias ES = ES_!( typeof( SDL_MouseMotionEvent.x ), typeof( SDL_MouseMotionEvent.x ) );
    alias EO = EO_!( Fixed_16_16, Fixed_16_16 );
    alias EA = EA_!( typeof( SDL_Point.x ), typeof( SDL_Point.y ) );
    alias IX = IX_!size_t;
}
else
{
    alias ES = ES_!( M16, M16 );
    alias EO = EO_!( Fixed_16_16, Fixed_16_16 );
    alias EA = EA_!( M16, M16 );
    alias IX = IX_!size_t;
}


struct EAEA
{
    union
    {
        struct
        {
            EA ea_;
            EA _ea;
        }
        TEAEA eaea;
    }    
    alias TEAEA = Detect8bitAlignedType!(EA,EA);

    // x,y to R1
    // x,y to R1, R2
    // x,y to e.user.data1
    // x,y to e.user.data1, e.user.data2
    auto to(T:MPTR)()
    {
        static assert( TEAEA.sizeof <= MPTR.sizeof, "Expect EAEA <= MPTR" );
        return cast(MPTR)xy;
    }

    auto to(T:EAEA)()
    {
        return this;
    }

    auto to(T:D)()
    {
        D d;
        alias TDATA1 = typeof( d.user.data1 );
        alias TDATA2 = typeof( d.user.data2 );

        if ( TEAEA.sizeof <= TDATA1.sizeof )
            d.user.data1 = cast(TDATA1)eaea;
        else
        {
            d.user.data1 = ea_.to!TDATA1;
            d.user.data2 = _ea.to!TDATA2;
        }

        return d;
    }
}


struct EOEO
{
    union
    {
        struct
        {
            EO eo_;
            EO _eo;
        }
        TEOEO eoeo;
    }    
    alias TEOEO = Detect8bitAlignedType!(EO,EO);

    // x,y to R1
    // x,y to R1, R2
    // x,y to e.user.data1
    // x,y to e.user.data1, e.user.data2
    auto to(T:MPTR)()
    {
        static assert( TEOEO.sizeof <= MPTR.sizeof, "Expect EOEO <= MPTR" );
        return cast(MPTR)xy;
    }

    auto to(T:EOEO)()
    {
        return this;
    }

    auto to(T:D)()
    {
        D d;
        alias TDATA1 = typeof( d.user.data1 );
        alias TDATA2 = typeof( d.user.data2 );

        if ( TEOEO.sizeof <= TDATA1.sizeof )
            d.user.data1 = cast(TDATA1)eoeo;
        else
        {
            d.user.data1 = eo_.to!TDATA1;
            d.user.data2 = _eo.to!TDATA2;
        }

        return d;
    }


    bool has( EO eo )
    {
        return 
            (
                (eo.x >= eo_.x) &&
                (eo.y >= eo_.y) &&
                (eo.x  < _eo.x) &&
                (eo.y  < _eo.y)
            );
    }
}


// O
//   v o
// IVAble
import cls.o : O;
struct V
{
    DList!O v;
    alias v this;

    auto ma(TCHILD,ARGS...)( ARGS args )
        // if ( TC derrived from O )
    {
        // ma child of class T
        // ma!T
        // ma!T()
        // ma!T( T_args )
        //   new T
        //   add in to this.v
        auto b = new TCHILD( args );

        this.v ~= b;

        return b;
    }
}

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


enum DT : M16
{
    _,
    KEY_PRESSED,
    KEY_A_PRESSED,
    KEY_CTRL_PRESSED,
    KEYS_CTRL_A_PRESSED,
}

version(SDL)
{
    import bindbc.sdl;

    struct D
    {
        SDL_Event _e;
        alias _e this;

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

        import std.conv;
        return t.to!string;
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

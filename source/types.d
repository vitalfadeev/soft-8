module types;

//import std.conv;
//import std.format;
import std.stdio;
import bindbc.sdl;
import fixed_16_16;


alias M   = void;
alias M1  = bool;
alias M8  = ubyte;
alias M16 = ushort;
alias M32 = uint;
alias M64 = ulong;

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

struct D
{
    M16 a;
    alias a this;    
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

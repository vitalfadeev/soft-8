module fixed_16_16;

import std.stdio;
import types;


// 16.16 Fixed Point Binary Type. 1.1 = 1 + 1/65536
// fix16_t
// fix16_16_t
struct Fixed_16_16
{
    union
    {
        M32 a;
        struct 
        {
            // The Intel x86 CPUs are little endian 
            //   meaning that the value 
            //   0x0A0B0C0D is stored in memory as: 
            //   0D 0C 0B 0A.
            M16 l;
            M16 h;
        }
    }

    alias T = typeof(this);


    this( M32 a )
    {
        this.a = a;
    }

    this( M16 h )
    {
        this.h = h;
        this.l = 0;
    }

    this( M32 h, M16 l )
    {
        this.h = cast(M16)h;
        this.l = l;
    }

    this( float a )
    {
        import std.conv;
        import std.math;

        //  1      ?      1 * 65536      ? * 100  
        // --- = ----- = ----------- = -----------
        // 100   65536   65536 * 100   65536 * 100
        //
        //     1 * 65536
        // ? = ---------
        //        100

        real frac;
        real intpart;
        frac = modf( a, intpart );
        this.h = intpart.to!M16;
        this.l = 
            ( 
                ( nearbyint(frac * 1_000) * (1<<16) ) / 
                1_000
            ).to!M16;
    }

    this( Fixed_16_16 fxd )
    {
        this.a = fxd.a;
    }

    //void opAssign( typeof(this) b )
    //{
    //    a = b.a;
    //}

    //void opAssign( int b )
    //{
    //    a = b;
    //}

    //void opAssign( M16 b )
    //{
    //    h = b;
    //    l = 0;
    //}

    T opBinary( string op : "+" )( T b )
    {
        return T( this.a + b.a );
    }


    T opBinary( string op : "-" )( T b )
    {
        return T( this.a + b.a );
    }


    T opBinary( string op : "*" )( T b )
    { // SHR, IMUL
        return 
            T( cast(M32)(
                (
                    ( cast(long)this.a ) * 
                    ( cast(long)   b.a )
                ) >> 16
            ) );
    }


    T opBinary( string op : "*" )( M32 b )
    {
        return T( this.a * b );
    }


    T opBinary( string op : "/" )( T b )
    { // SHL, IDIV
        return 
            T( 
                cast(M32)( 
                    ( ( cast(long)(this.a) ) << 16 ) / b.a
                ) 
            );
    }


    T opBinary( string op : "/" )( M32 b )
    {
        return T( this.a / b );
    }


    string toString()
    {
        import std.format;
        return format!"%s( %d . %d/%d )"( typeof(this).stringof, this.h, this.l, 1<<16 );
    }
}

unittest
{
    auto a = Fixed_16_16( 1, 0 );
    auto b = Fixed_16_16( 1, 0 );
    auto c = a * b;

    assert( a     == Fixed_16_16( 1, 0 ) );
    assert( a * a == Fixed_16_16( 1, 0 ) );
    assert( a * b == Fixed_16_16( 1, 0 ) );
    assert( c     == Fixed_16_16( 1, 0 ) );
    assert( a.h   == 1 );
    assert( a.l   == 0 );
    assert( b.h   == 1 );
    assert( b.l   == 0 );
    assert( c.h   == 1 );
    assert( c.l   == 0 );
}

unittest
{
    auto a = Fixed_16_16( 1, 0 );
    auto b = Fixed_16_16( 2, 0 );
    auto c = a * b;

    assert( a * b == Fixed_16_16( 2, 0 ) );
    assert( c     == Fixed_16_16( 2, 0 ) );
    assert( a.h   == 1 );
    assert( a.l   == 0 );
    assert( b.h   == 2 );
    assert( b.l   == 0 );
    assert( c.h   == 2 );
    assert( c.l   == 0 );
}

unittest
{
    auto a = Fixed_16_16( 2, 0 );
    auto b = Fixed_16_16( 2, 0 );
    auto c = a * b;

    assert( a * b == Fixed_16_16( 4, 0 ) );
    assert( c     == Fixed_16_16( 4, 0 ) );
    assert( a.h   == 2 );
    assert( a.l   == 0 );
    assert( b.h   == 2 );
    assert( b.l   == 0 );
    assert( c.h   == 4 );
    assert( c.l   == 0 );
}

unittest
{
    auto a = Fixed_16_16( 0, 1 );
    auto b = Fixed_16_16( 0, 1 );
    auto c = a + b;

    assert( a + b == Fixed_16_16( 0, 2 ) );
    assert( c     == Fixed_16_16( 0, 2 ) );
    assert( a.h   == 0 );
    assert( a.l   == 1 );
    assert( b.h   == 0 );
    assert( b.l   == 1 );
    assert( c.h   == 0 );
    assert( c.l   == 2 );
}

unittest
{
    auto a = Fixed_16_16( 0, 1 ); // 0 + 1/65536
    auto b = Fixed_16_16( 1, 0 ); // 1
    auto c = a * b;               // 1 * 1/65536

    assert( a * b == Fixed_16_16( 0, 1 ) );
    assert( c     == Fixed_16_16( 0, 1 ) );
    assert( a.h   == 0 );
    assert( a.l   == 1 );
    assert( b.h   == 1 );
    assert( b.l   == 0 );
    assert( c.h   == 0 );
    assert( c.l   == 1 );
}

unittest
{
    auto a = Fixed_16_16( 1, 0 );
    auto b = Fixed_16_16( 1, 0 );
    auto c = a / b;

    assert( a / b == Fixed_16_16( 1, 0 ) );
    assert( c     == Fixed_16_16( 1, 0 ) );
    assert( a.h   == 1 );
    assert( a.l   == 0 );
    assert( b.h   == 1 );
    assert( b.l   == 0 );
    assert( c.h   == 1 );
    assert( c.l   == 0 );
}

unittest
{
    auto a = Fixed_16_16( 1, 0 );
    auto b = Fixed_16_16( 2, 0 );
    auto c = a / b;

    assert( a / b == Fixed_16_16( 0, 1<<15 ) );
    assert( c     == Fixed_16_16( 0, 1<<15 ) );
    assert( a.h   == 1 );
    assert( a.l   == 0 );
    assert( b.h   == 2 );
    assert( b.l   == 0 );
    assert( c.h   == 0 );
    assert( c.l   == (1<<15) );
}

unittest
{
    //auto a = Fixed_16_16( -1, 0 );
    //auto b = Fixed_16_16(  1, 0 );
    //auto c = a * b;

    //assert( a * b == Fixed_16_16( -1, 0 ) );
    //assert( c     == Fixed_16_16( -1, 0 ) );
    //assert( a.h   == -1 );
    //assert( a.l   ==  0 );
    //assert( b.h   ==  1 );
    //assert( b.l   ==  0 );
    //assert( c.h   == -1 );
    //assert( c.l   ==  0 );
}


const 
Fixed_16_16 PI = Fixed_16_16( 3.14159265 );

// angle     circle
//   0     = top
//   1     = 1/49152
//   2     = 1/24576
//   4     = 1/12288
//   8     = 1/6144
//   16    = 1/3072
//   32    = 1/1536
//   64    = 1/768
//   128   = 1/384
//   256   = 1/192
//   512   = 1/96
//   1024  = 1/48
//   2048  = 1/32
//   4096  = 1/16
//   8192  = 1/8          = 65536/8
//   16386 = 1/4 right    = 65536/4
//   32768 = 1/2 bottom   = 65536/2
//   65536 = 1   top
Fixed_16_16 cos( M16 a )
{
    return Fixed_16_16( 0, (M16.max)/a );
}

// 
Fixed_16_16 sin( M16 a )
{
    return Fixed_16_16( 0, (M16.max)/a );
}


struct CosSin
{
    Fixed_16_16 c;
    Fixed_16_16 s;

    alias T = typeof(this);


    static 
    T FromAngle( M16 h, M16 l )
    {
        auto c = .cos( l );
        auto s = .sin( l );

        return T( c, s );
    }
}

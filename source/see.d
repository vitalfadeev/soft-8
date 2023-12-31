module see;

// ma

//          A
//         / \        ma
//        i   b
//       /     \
//    see   ->  see_able
//    see  <-   see_able

//    wa    ->   
//         <-    na

// i wa o
//   wa.o -> wana
//
// wana -> wa
//   .o
//     ma o
//     na -> wana  // (o)
//
// wana
//   .na           // (o)
//

// I                            // : able
//   ( able )?
// B                            // : able
//   ( able )?

// I
//   see
//     wa -> wana               // wa: wa_see,i
//
// Go                           // : wana_able
//   wana
//     wa
//       .wa_see
//         each b
//           .see( wa_see )
//
// B                            // : wa_able, see_wa_able
//   ( wa )?
//     wa_see
//       .wa_see
//         ma SEE()
//         wana <- na           // na: wa_see,b,SEE
//
// I                            // : na_able, see_na_able
//   ( na )?
//     na <- wana
//     na_see
//   na_see
//     wa_see,b,SEE

// Able
// Able
//   able
//
// A                            // : always able
//   able
//     true
//
// I                            // : Able
//   able
//     if () then true else false
//
// B                            // : Able
//   able
//     if () then true else false

class Able
{
    bool able()
    {
        return true;
    }
}

class MaAble : Able
{
    A _next;  // foreach( a; _v )...
    static __gshared
    V _v;

    auto ma(T,ARGS...)( ARGS args )
    {
        return _v.ma!T( args );
    }
}

auto ma(T, ARGS...)( ARGS args )
    if ( is( T == class ) )
{
    return new T( args );
}


class WaAble : MaAble
{
    static __gshared
    Wana _wana;

    static
    auto wa(T,ARGS...)( ARGS args )
        // if ( T derived from WA )
    {
        return _wana.ma!T( args );
    }

    void on_na( Na na )
    {
        //
    }
}

auto ma(T,ARGS...)( ARGS args )
    if ( is( T == struct ) )
{
    return new T( args );
}

class NaAble : WaAble
{
    void on_wa( Wa na )
    {
        //
    }

    static
    auto na(T,ARGS...)( ARGS args )
        // if ( T derived from NA )
    {
        return _wana.ma!T( args );
    }
}

class WaNaAble : NaAble
{
    void on_wana( WaNa* wn )
    {
        if ( wn.is_wa )
            on_wa( wn.wa );
        else
            on_na( wn.na );
    }

    void go()
    {
        foreach( wn; _wana )
            foreach( a; _v )
                if ( a.able )
                    a.on_wana( wn );
    }
}

// Send!SeeNa( NA.SEE, wa.i, this );
//auto wa(T,ARGS...)( ARGS args )
//{
//    return WaAble.wa!T( args );
//}
//auto na(T,ARGS...)( ARGS args )
//{
//    return NaAble.na!T( args );
//}


class A : WaNaAble
{
}


alias I = A;
alias B = A;


class ISee : I
{
    override 
    bool able()
    {
        return 
            (1) ? true : false;
    }

    // sync
    void see( SeeAble b )
    {
        b.see_able( this );
    }

    // wana-see
    void wa_see( SeeAble b )
    {
        auto w = wa!SeeWa();
        w.i = this;
    }

    override
    void on_na( Na na )
    {
        import std.stdio : writeln;
        switch ( na.t )
        {
            case NA._   : { NA_( na );        break; }
            case NA.SEE : { NA_SEE( na.see ); break; }
            default: break;
        }
    }

    void NA_( Na na )
    {
        import std.stdio : writeln;
        writeln( "  _: from: ", na.b );
    }

    void NA_SEE( SeeNa na )
    {
        import std.stdio : writeln;
        writeln( "  SEE: from: ", na.b );
    }
}

class BSeeAble: A, SeeAble
{
    override 
    bool able()
    {
        return 
            (1) ? true : false;
    }

    // sync
    void see_able( ISee i )
    {
        import std.stdio : writeln;
        writeln( "      sync SEE: for: ", i );
    }

    // async
    override
    void on_wa( Wa wa )
    {
        import std.stdio : writeln;
        writeln( "    async wa: ", wa.t, ": for: ", wa.i );
        switch ( wa.t )
        {
            case WA._   : { WA_( wa );        break; }
            case WA.SEE : { WA_SEE( wa.see ); break; }
            default: break;
        }
    }

    // async -> sync()
    void WA_( Wa wa )
    {
        import std.stdio : writeln;
        writeln( "    async ro: ", wa.t, ": for: ", wa.i );
    }

    void WA_SEE( SeeWa wa )
    {
        import std.stdio : writeln;
        writeln( "    async ro: ", wa.t, ": for: ", wa.i );

        // sync call
        see_able( wa.i );

        // async return
        na!SeeNa( wa.i, this );
    }
}

interface SeeAble
{
    void see_able( ISee i );
}

unittest
{
    // ma
    auto a = ma!A();
    auto i = a.ma!I();
}

unittest
{
    // sync
    auto a = ma!A();

    auto i = a.ma!ISee();
    auto b = a.ma!BSeeAble();

    i.see( b ); // sync call
}

unittest
{
    // async
    auto a = ma!A();

    auto i = a.ma!ISee();
    auto b = a.ma!BSeeAble();

    i.wa_see( b );  // wana-call
                    // b.see( i )
    
    import std.stdio : writeln;
    writeln( "A_SEE: " );

    a.go();

    writeln( "A_SEE: ." );
}

unittest
{
    // async
    auto a = ma!A();

    auto window = a.ma!ISee();
    auto b = a.ma!BSeeAble();

    window.wa_see( b );  // wana-call
                         // b.see( window )
    
    import std.stdio : writeln;
    writeln( "A_SEE: " );

    a.go();

    writeln( "A_SEE: ." );
}



alias V = _V!A;

// SList
struct _V(T)
    if ( is( T == class ) && __traits(hasMember,T,"_next") )
{
    T front;
    T back;

    bool empty()
    {
        return (front is null);
    }

    void popFront()
    {
        assert( front !is null );

        if ( front._next is null )
        {
            front = null;
            back = null;
        }
        else
            front = front._next;
    }

    auto save()
    {
        return typeof(this)(front,back);  // copy
    }

    auto ma(SUBT : T,ARGS...)( ARGS args )
        // if ( SUBT is subtype of T )
    {
        auto ov = .ma!SUBT( args );

        // put at back
        if ( empty )
        {
            front = ov;
            back  = ov;
        }
        else
        {
            back._next = ov;
            back       = ov;
        }

        return ov;
    }
}


// wa <- wana <- wa
alias Wana = _Wana!WaNa;

// FIFO
struct _Wana(T)
    if ( is( T == struct ))
{
    _E* f;
    _E* b;

    T* front()
    {
        if ( f is null )
            return null;
        else
            return &f._super;
    }

    T* back()
    {
        if ( f is null )
            return null;
        else
            return &b._super;
    }

    bool empty()
    {
        return (f is null);
    }

    void popFront()
    {
        assert( f !is null );

        auto for_free = f;

        if ( f._next is null )
        {
            f = null;
            b = null;
        }
        else
            f = f._next;

        for_free.destroy();
    }

    auto save()
    {
        return this;  // non-copy
    }

    struct _E
    {
        _E* _next;
        T   _super;
    }

    auto ma(SUBT,ARGS...)( ARGS args )
        // if ( SUBT inherited from T )
        // if ( SUBT inherited from ( Wa || NA || WaNa ) )
    {
        struct __E
        {
            _E*  _next;
            SUBT _super;
        }

        auto ov = .ma!__E( null, SUBT(SUBT.init.t, args) );

        // put at back
        if ( empty )
        {
            f = cast(_E*)ov;
            b = cast(_E*)ov;
        }
        else
        {
            b._next = cast(_E*)ov;
            b       = cast(_E*)ov;
        }

        return &ov._super;
    }
}


enum WA
{        // odd bit = 0 is WA
    _     = 0x0000 << 1,
    ASYNC = 0x0001 << 1,
    SEE   = 0x0002 << 1,
}

struct _Wa
{
    WA t;
    I  i;
}

struct Wa
{
    union
    {
        struct
        {
            WA t = WA._;
            I  i;
        }
        _Wa   _;
        SeeWa see;
    }
}

struct SeeWa
{
    const
    WA   t = WA.SEE;
    ISee i;
}


//
enum NA
{        // odd bit = 1 is NA
    _     = WA._     | 1,
    ASYNC = WA.ASYNC | 1,
    SEE   = WA.SEE   | 1,
}

struct Na
{
    union
    {
        struct
        {
            NA t = NA._;
            I  i;
            B  b;
        };
        AsyncNa async;
        SeeNa   see;
    }
}

class AsyncWaCLass
{
    //
}

alias THEN = void delegate( /*AsyncWaCLass async_wa*/ );
struct AsyncNa
{
    const
    NA           t = NA.ASYNC;
    I            i;
    THEN         then_;
    /*AsyncWaCLass wa;*/
}

struct SeeNa
{
    const
    NA t = NA.SEE;
    I  i;
    B  b;
}

//
struct WaNa
{
    union
    {
        Wa wa;
        Na na;
    }

    auto is_wa()
    {
        return wa.t & 1;
    }

    auto is_na()
    {
        return ( na.t & 1 ) != 0;
    }
}

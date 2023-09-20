module see;


//   o
//  / \
// i   o

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

class WaAble : Able
{
    void wa( Wa wa )
    {
        //
    }
}

class WaNaAble : WaAble
{
    void na( Na na )
    {
        //
    }
}

class A : WaNaAble
{
    V v;

    auto ma(T,ARGS...)( ARGS args )
    {
        return v.ma!T( args );
    }
}

alias B = A;


class I : A
{
    auto wa(T,ARGS...)( ARGS args )
    {
        return ma!T( args );
    }
}


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
        //
    }

    // async
    void a_see( Wana wana, SeeAble b )
    {
        auto wa = wana.ma!SeeWa();
    }

    override
    void na( Na na )
    {
        switch ( na.t )
        {
            case NAT._   : { NAT_( na );        break; }
            case NAT.SEE : { NAT_SEE( na.see ); break; }
            default: break;
        }
    }

    void NAT_( Na na )
    {
        import std.stdio : writeln;
        writeln( "_: from: ", na.b );
    }

    void NAT_SEE( SeeNa na )
    {
        import std.stdio : writeln;
        writeln( "SEE: from: ", na.b );
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
        writeln( "SEE: for: ", i );
    }

    // async
    override
    void wa( Wa wa )
    {
        switch ( wa.t )
        {
            case WAT._   : { WAT_( wa );        break; }
            case WAT.SEE : { WAT_SEE( wa.see ); break; }
            default: break;
        }
    }

    // async -> sync()
    void WAT_( Wa wa )
    {
        import std.stdio : writeln;
        writeln( "_: for: ", wa.i );
    }

    void WAT_SEE( SeeWa wa )
    {
        see_able( wa.i );
    }


}

interface SeeAble
{
    void see_able( ISee i );
}

unittest
{
    // ma
    auto a = new A();
    auto i = a.ma!I();
}

unittest
{
    // sync
    auto a = new A();

    auto i = a.ma!ISee();
    auto b = a.ma!BSeeAble();

    i.see( b ); // via wana
}

unittest
{
    // async
    Wana wana;

    auto a = new A();

    auto i = a.ma!ISee();
    auto b = a.ma!BSeeAble();

    i.a_see( wana, b ); // via wana
}



alias V = V_!A;
// SList
struct V_(T)
    if ( is( T == class ) )
{
    _EVT f;
    _EVT b;


    T front()
    {
        return cast(T)f;
    }

    T back()
    {
        return cast(T)b;
    }

    bool empty()
    {
        return (f is null);
    }

    void popFront()
    {
        assert( f !is null );
        f = f._next;
    }

    auto save()
    {
        return this;
    }

    class _EVT : T
    {
        _EVT _next;
    }

    //auto ma(SUBT,ARGS...)( ARGS args )
    auto ma(SUBT : T,ARGS...)( ARGS args )
        // if ( SUBT is subtype of T )
    {
        class __EVT : SUBT
        {
            _EVT _next;
        }

        auto ov = new __EVT( args );

        // put at back
        if ( empty )
        {
            f = cast( _EVT )ov;
            b = cast( _EVT )ov;
        }
        else
        {
            b._next = cast( _EVT )ov;
            b       = cast( _EVT )ov;
        }

        return ov;
    }
}


// wa <- wana <- wa
alias Wana = Wana_!AWaNa;
// FIFO
struct Wana_(T)
    if ( is( T == struct ))
{
    _ET* f;
    _ET* b;

    T front()
    {
        return f._super;
    }

    T back()
    {
        return b._super;
    }

    bool empty()
    {
        return (f is null);
    }

    void popFront()
    {
        assert( f !is null );

        auto _f = f;

        f = f._next;

        _f.destroy();
    }

    auto save()
    {
        return this;
    }

    //void opOpAssign( string op : "~" )( T b )
    //{
    //    //
    //}
    struct _ET
    {
        T    _super;
        _ET* _next;
    }

    auto ma(SUBT,ARGS...)( ARGS args )
        // if ( SUBT inherited from T )
    {
        struct __ET
        {
            SUBT _super;
            _ET* _next;
        }

        auto ov = new __ET( args );

        // put at back
        if ( empty )
        {
            f = cast(_ET*)ov;
            b = cast(_ET*)ov;
        }
        else
        {
            b._next = cast(_ET*)ov;
            b       = cast(_ET*)ov;
        }

        return &ov._super;
    }
}


enum WAT
{
    _,
    SEE,
}

struct _Wa
{
    WAT t;
    I   i;
}

struct Wa
{
    union
    {
        struct
        {
            WAT t = WAT._;
            I   i;
        }
        _Wa   _;
        SeeWa see;
    }
}

struct SeeWa
{
    WAT  t = WAT.SEE;
    ISee i;
}


//
enum NAT
{
    _,
    SEE,
}

struct Na
{
    union
    {
        struct
        {
            NAT t = NAT._;
            B   b;
        };
        SeeNa see;
    }
}

struct SeeNa
{
    NAT t = NAT.SEE;
    B   b;
}

//
struct AWaNa
{
    union
    {
        Wa wa;
        Na na;
    }
}

bool is_wa( AWaNa )
{
    return true;
}

bool is_na( AWaNa )
{
    return true;
}


//
struct Go
{
    static
    Wana wana;

    void go( V v )
    {
        foreach( wn; wana )
            foreach( a; v )
                if ( a.able )
                {
                    if ( wn.is_wa )
                        a.wa( wn.wa );
                    else
                    if ( wn.is_na )
                        a.na( wn.na );
                }
    }
}


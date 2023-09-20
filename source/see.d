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

auto ma(T, ARGS...)( ARGS args )
{
    return new T( args );
}


class A : WaNaAble
{
    V v;
    A _next;

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
    void a_see( ref Wana wana, SeeAble b )
    {
        auto wa = wana.ma!SeeWa();
        wa.i = this;
    }

    override
    void na( Na na )
    {
        import std.stdio : writeln;
        writeln( "    async na: ", na.t, ": for: ", na.i, ": from: ", na.b );
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
    void wa( Wa wa )
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
        see_able( wa.i );

        // async return
        // wana <- na NA_SEE,i,this
        auto na = SeeNa( NA.SEE, wa.i, this );
        //writeln( "     sync bk: ", na.t, ": for: ", wa.i );
        //wa.i.na( cast(Na)na );  // direct sync call

        writeln( "    async bk: ", na.t, ": for: ", wa.i );
        Send!SeeNa( NA.SEE, wa.i, this );
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
    //Wana wana;

    auto a = ma!A();
    import std.stdio : writeln;
    writeln( a.v.f );

    auto i = a.ma!ISee();
    auto b = a.ma!BSeeAble();

    i.a_see( wana, b ); // async call via wana
    import std.stdio : writeln;
    writeln( "A_SEE: " );
    writeln( "A_SEE front: ", wana.f );
    writeln( a.v.f );

    // go
    foreach( wn; wana )
        foreach( _a; a.v )
            if ( _a.able )
            {
                writeln( "  able: ", _a );
                if ( wn.is_wa )
                    _a.wa( wn.wa );
                else
                if ( wn.is_na )
                    _a.na( wn.na );
            }
    writeln( "A_SEE: ." );
}

static
Wana wana;

// Send!SeeNa( NA.SEE, wa.i, this );  // async call
void Send(T,ARGS...)( ARGS args )
{
    wana.ma!T( args );  // async call
}



alias V = V_!A;

// SList
struct V_(T)
    if ( is( T == class ) && __traits(hasMember,T,"_next") )
{
    T f;
    T b;


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

        import std.stdio : writeln;
        writeln( __FUNCTION__ );

        auto for_free = f;

        if ( f._next is null )
        {
            f = null;
            b = null;
        }
        else
            f = f._next;

        //for_free.destroy();
    }

    auto save()
    {
        return typeof(this)(f,b);  // copy
    }

    auto ma(SUBT : T,ARGS...)( ARGS args )
        // if ( SUBT is subtype of T )
    {
        auto ov = new SUBT( args );

        // put at back
        if ( empty )
        {
            f = ov;
            b = ov;
        }
        else
        {
            b._next = ov;
            b       = ov;
        }

        return cast(SUBT)ov;
    }
}


// wa <- wana <- wa
alias Wana = Wana_!AWaNa;
// FIFO
struct Wana_(T)
    if ( is( T == struct ))
{
    _E* f;
    _E* b;

    T* front()
    {
        import std.stdio : writeln;
        writeln( __FUNCTION__ );
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

        import std.stdio : writeln;
        writeln( __FUNCTION__ );

        auto for_free = f;

        if ( f._next is null )
        {
            f = null;
            b = null;
        }
        else
            f = f._next;


        import std.stdio : writeln;
        writeln( __FUNCTION__ );
        //for_free.destroy();
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
    {
        struct __E
        {
            _E*  _next;
            SUBT _super;
        }

        auto ov = new __E( null, SUBT(args) );

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
{
    _,
    SEE,
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
    WA   t = WA.SEE;
    ISee i;
}


//
enum NA
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
            NA t = NA._;
            I  i;
            B  b;
        };
        SeeNa see;
    }
}

struct SeeNa
{
    NA t = NA.SEE;
    I  i;
    B  b;
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

bool is_wa( AWaNa* )
{
    return true;
}

bool is_na( AWaNa* )
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


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
    if ( is( T == class ) )
{
    return new T( args );
}
auto ma(T, ARGS...)( ARGS args )
    if ( is( T == struct ) )
{
    return new T( args );
}


class A : WaNaAble
{
    //A _next;
    static __gshared
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

    auto i = a.ma!ISee();
    auto b = a.ma!BSeeAble();

    i.a_see( wana, b ); // async call via wana
    
    import std.stdio : writeln;
    writeln( "A_SEE: " );

    // go
    foreach( wn; wana )
        foreach( _a; a.v )
            if ( _a.able )
            {
                writeln( "  able: ", _a );
                if ( wn.is_wa )
                    _a.wa( wn.wa );
                else
                    _a.na( wn.na );
            }
    writeln( "A_SEE: ." );
}

// Send!SeeNa( NA.SEE, wa.i, this );  // wana call
void Send(T,ARGS...)( ARGS args )
{
    Game.wana.ma!T( args );  // wana call
}



import std.container.dlist : DList;
struct V
{
    DList!A _super;
    alias _super this;

    auto ma(T,ARGS...)( ARGS args )
    {
        auto a = .ma!T( args );
        _super ~= a;
        return a;
    }
}

//alias V = V_!A;

// SList
struct V_(T)
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
alias Wana = Wana_!WaNa;

// FIFO
struct Wana_(T)
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

    //void opAssign( string op : "~", ARGS... )( ARGS args )
    //{
    //    this.ma!T( args );
    //}

    auto ma(SUBT,ARGS...)( ARGS args )
        // if ( SUBT inherited from T )
    {
        struct __E
        {
            _E*  _next;
            SUBT _super;
        }

        auto ov = .ma!__E( null, SUBT(args) );

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

alias THEN = void delegate();
struct AsyncNa
{
    NA   t = NA.SEE;
    I    i;
    B    b;
    THEN then_;
}

struct SeeNa
{
    NA t = NA.SEE;
    I  i;
    B  b;
}

//
struct WaNa
{
    union
    {
        typeof(Wa.t) t;
        Wa wa;
        Na na;
    }
}

bool is_wa(T)( T wa )
    if ( is( T : Wa ) || is( T : Wa* ) || is( T : WaNa ) || is( T : WaNa* ) )
{
    return ( wa.t & 1 ) == 0;
}
bool is_na(T)( T na )
    if ( is( T : Na ) || is( T : Na* ) || is( T : WaNa ) || is( T : WaNa* ) )
{
    return ( na.t & 1 ) != 0;
}

//
struct Game
{
    static __gshared
    Wana wana;

    void go()
    {
        foreach( wn; wana )
        {
            import std.stdio : writeln;
            if (wn.is_wa) 
                writeln( "wn: ", wn.wa.t );
            else
                writeln( "wn: ", wn.na.t ); 
            foreach( a; A.v )
                if ( a.able )
                {
                    if ( wn.is_wa )
                        a.wa( wn.wa );
                    else
                        a.na( wn.na );
                }
        }
    }
}


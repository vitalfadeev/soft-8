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

class A : WaAble
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
    void na( Na na )
    {
        switch ( na.t )
        {
            case NAT._   : { break; }
            case NAT.SEE : { NAT_SEE( na.see ); break; }
            default: break;
        }
    }

    void NAT_SEE( SeeNa na )
    {
        //
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
        //
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
        //
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
    Wana wana;

    auto a = new A();

    auto i = a.ma!I();
}

unittest
{
    Wana wana;

    auto a = new A();

    auto i = a.ma!ISee();
    auto b = a.ma!BSeeAble();

    i.see( b );
}

unittest
{
    Wana wana;

    auto a = new A();

    auto i = a.ma!ISee();
    auto b = a.ma!BSeeAble();

    i.see( b ); // via wana
}



alias V = V_!A;
// SList
struct V_(T)
{
    TV* f;
    TV* b;

    auto ma(T,ARGS...)( ARGS args )
    {
        auto o  = new T( args );
        auto ov = new TV( o, b );

        // put at back
        if ( empty )
        {
            f = ov;
            b = ov;
        }
        else
            b = ov;

        return o;
    }

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
        f = f.next;
    }

    auto save()
    {
        return this;
    }

    struct TV
    {
        T   o;
        TV* next;

        auto opCast( T )()
        {
            return o;
        }
    }
}


// wa <- wana <- wa
alias Wana = Wana_!Wa;
// FIFO
struct Wana_(T)
{
    TV* f;
    TV* b;

    T front()
    {
        return cast(T)f.o;
    }

    T back()
    {
        return cast(T)b.o;
    }

    bool empty()
    {
        return (f is null);
    }

    void popFront()
    {
        assert( f !is null );
        f = f.next;
    }

    auto save()
    {
        return this;
    }

    struct TV
    {
        T   o;
        TV* next;

        auto opCast( T )()
        {
            return o;
        }
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
            WAT t;
            I   i;
        }
        _Wa   _;
        SeeWa see;
    }
}

struct SeeWa
{
    WAT  t;
    ISee i;
}


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
            NAT t;
            B   b;
        };
        SeeNa see;
    }
}

struct SeeNa
{
    NAT t;
    B   b;
}


struct Go
{
    static
    Wana wana;

    void go( V v )
    {
        foreach( wa; wana )
            foreach( a; v )
                if ( a.able )
                    a.wa( wa );
    }
}


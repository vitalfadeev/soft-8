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


class I : A
{
    auto wa(T,ARGS...)( ARGS args )
    {
        return ma!T( args );
    }
}


class ISee : I
{
    void see( SeeAble b )
    {
        //
    }

    override 
    bool able()
    {
        return 
            (1) ? true : false;
    }
}

class BSeeAble: A, SeeAble
{
    override
    void wa( Wa wa )
    {
        switch ( wa.t )
        {
            case WAT._: { WAT_( wa ); break; }
            default: break;
        }
    }

    void WAT_( Wa wa )
    {
        //
    }

    void see_able( ISee i )
    {
        //
    }

    override 
    bool able()
    {
        return 
            (1) ? true : false;
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
}

struct Wa
{
    WAT t;
}

struct SeeWa
{
    Wa _super;
    alias _super this;
}

struct Na
{
    //
}

struct SeeNa
{
    Na _super;
    alias _super this;
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


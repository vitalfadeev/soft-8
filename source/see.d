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
// wana -> na
//   .na           // (o)

class A
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
}

class BSeeAble: A, SeeAble
{
    void see_able( ISee i )
    {
        //
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


struct Wa
{
    //
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

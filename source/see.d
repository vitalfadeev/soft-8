module see;

//   o
//  / \
// i   o

//          o
//         / \
//        i   o
//       /     \
// sensor   ->  sense_able
// sensor  <-   sense_able

//    wa         ma

// i wa o
//   wa.o -> pool
//
// pool -> wa
//   .o
//     ma o
//     done -> pool  // (o)
//
// pool -> done
//   .done           // (o)

class O
{
    V v;

    auto ma(T,ARGS...)( ARGS args )
    {
        return v.ma!T( args );
    }

}


class I : O
{
    auto wa(T,ARGS...)( ARGS args )
    {
        return ma!T( args );
    }
}

unittest
{
    Pool pool;
    auto o = new O();
    o.ma!I();
}



alias V = V_!O;
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


// <- wa
// -> wa
alias Pool = Pool_!O;
// FIFO
struct Pool_(T)
{
    TV* f;
    TV* b;

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


struct Wa
{
    //
}

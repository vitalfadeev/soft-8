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
        auto o = new T( args );
        v ~= o;
        return o;
    }
}


class I : O
{
    auto wa(T,ARGS...)( ARGS args )
    {
        return ma!T( args );
    }
}


// FIFO
struct V
{
    OV front;
    OV back;

    auto ma(T,ARGS...)( ARGS args )
    {
        auto o  = new T( args );
        auto ov = new OV( o, back );

        // put at back
        if ( front is null )
        {
            front = ov;
            back = ov;
        }
        else
            back = ov;

        return o;
    }

    struct OV
    {
        O  o;
        OV next;
    }
}


struct Wa
{
    //
}

struct Pool
{
    // <- wa
    // -> wa
}

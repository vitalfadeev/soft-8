module process;

import types;

// Device   -> la ops[] -> Device
//                           action  rasterize

// Object   -> o ops[]  -> Object
//                           action

// Keyboard -> kd ops[] -> OS
//                           action

// Device   -> d ops[] -> OS
//                           action

// OS       -> os ops[] -> Object
//                           action

// op
//   opcode
//   data1
//   data2
//   data3

// pool -> main loop -> op -> object -> sensor
//                                        action

// device -> op -> os pool -> process pool
//                            process
//                              main loop -> op -> object -> sensor
//                                                             action

// dev -> int -> driver
//                 op -> os pool
//                       os
//                         main loop
//                           process1
//                           process2
//                           process3
//                           op -> process pool
//                                   process
//                                     main loop
//                                       op
//                                         sensor
//                                           action

// process
//   main loop
//     op -> object -> sensor
//                       action

// process
//   main loop
//     op -> object -> sensor
//                       process op data

// process pool
// process
//   main loop
//     action1
//     action2
//     action3
//     op -> object -> sensor
//                       process op data

// process pool --+
// process        |
//   main loop    |
//     op <-------+
//       sensor <----- brain. logic. links. op-*-action
//         process

// PROCESS
// pool ----------+
//   main loop    |
//     op <-------+
//       sensor <----- brain. logic. links. op-:::-action
//         action
//           new op -> pool
//           new op -> pool2

// dev -> data transfered
//          op.data_transfered (ptr,len)
//            os pool
//            os
//              main loop
//                op
//                  case data_transfered
//                    each process
//                      pool <- op.data_transfered (ptr,len)
//            os processes
//              time 10.ms
//                process

// PROCESS
// pool
//   main loop
//     op
//       sensor
//         logic
//           action
//           processes each
//             process put in pool op
//             process direct call action
//     time 10 ms
//       processes each
//         PROCESS
// processes

// PROCESS
// pool
// go 
//   main loop
//     op
//       sensor
//         logic
//           action
//           processes each
//             process put in pool op
//             process direct call action
//     time 10 ms
//       processes each
//         PROCESS
// processes

enum OpCode : M16
{
    _,
    ONE,
    FINISH,
}

struct Op
{
    M16 code;
    M16 data1;
    M16 data2;
    M16 data3;
}


class Process
{    
    Pool      pool; // First In First Out
    Processes processes;
    bool      live = true;


    void go( alias TIME_LIMIT=void )()
    {
        Op op;

        while ( live )
        {
            static if ( !is( TIME_LIMIT == void ) )
            if ( Timer.now < TIME_LIMIT )
                break;

            if ( pool.empty )
                break;

            // on op
            op = pool.pop();

            // sense logic
            sense( op ); // logic
                         // op 
                         //   direct action
                         //   processes put op

            // recursive
            processes.go();
        }
    }

    pragma( inline, true )
    void sense( Op op )
    {
        // sensor logic
        //   switch..case -> BRAIN -> action
        //
        // BRAIN
        //   c1 c2 c3 c4 c5
        //    1  1  1  0  0   action1
        //    0  1  1  1  0   action2
        //    0  0  1  1  1   action3
        switch ( op.code )
        {
            case OpCode._:      { break; }
            case OpCode.ONE:    { OP_ONE( op ); break; }
            case OpCode.FINISH: { OP_FINISH( op ); break; }
            default:
        }

        //try_to( op ); // go to new state
    }


    pragma( inline, true )
    void put( Op op ) // M64 or M16,M16,M16,M16 or M16,M16,M32
    {
        pool.put( op );
    }


    //
    pragma( inline, true )
    void OP_ONE( Op op )
    {
        // direct or put

        // 1.
        // direct
        this.action1( op );

        // or
        // process direct
        processes[0].action1( op );

        // 2.
        // put in each process
        foreach ( p; processes )
            p.put( op );

        // or
        // put in filtered process
        foreach ( p; processes )
            if ( p.live )
                p.put( op );

        // or
        // direct put
        processes[0].put( op );
    }

    pragma( inline, true )
    void OP_FINISH( Op op )
    {
        live = false;
    }

    //
    void action1( Op op )
    {
        //
    }
}


// SLIST
struct FIFO(T)
{
    struct TLISTITEM
    {
        T a;
        TLISTITEM* next;
    }

    TLISTITEM* f;
    TLISTITEM* l;

    
    T pop()
    {
        if ( this.f is null )
            throw new Exception( "empty fifo" );

        auto a = this.f.a;

        auto next = this.f.next;

        this.f.destroy();

        if ( next is null )
            this.l = null;
        else
            this.f = next;

        return a;
    }


    void put( ref T a )
    {
        auto listitem = new TLISTITEM( a );
        
        if ( this.l is null )
        {
            this.l = listitem;
            this.f = listitem;
        }
        else
        {
            this.l.next = listitem;
        }
    }

    pragma( inline, true )
    bool empty()
    {
        return ( this.f is null );
    }
}


alias Pool = FIFO!Op;


struct Processes
{
    Process[] processes;
    alias processes this;


    pragma( inline, true )
    void go()
    {
        // on 10 ms
        foreach( p; processes )
            p.go(); // 10 ms
                    // 1 time = process time = 10 ms
                    // ( (1 time)/processes.count ) ms
                    //   each 1/count time
    }
}


struct Timer
{
    alias T_TICK = ulong;

    static
    T_TICK now()
    {
        return 0;
    }
}



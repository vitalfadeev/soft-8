import std.stdio;

// class
//   fn
//   -> to delegate
//     to Thread
//  on Thread
//   call done()

//  A
//  |
//  I
//   DO

//                A
//               / \
//              I   B
//             /     \
//            /       \
//           /         \
//          /           \
//         /   Go        \
//    async  -> pool ->   msg_loop
//                          able
//                            wa
//                              DO
// msg_loop  <- pool <-         na
//   able
//     na
//            delegate
//       DONE
//       FAIL


//                A
//               / \
//              I   B
//             /     \
//            /       \
//           /         \
//          /           \
//  AsyncA /             \
//    async  -> thread -> DO
//              pool <-     na ASYNC
// msg_loop  <-                
//   able
//     na
//            delegate
//       DONE
//       FAIL

import see;


class AsyncAble : I
{
	void async(DG,THEN,ARGS...)( DG dg, THEN then_, ARGS args )
	{
	    writeln( "async:" );

	    import std.parallelism;
	    auto async_task = task!wrapped_dg( this, dg, then_, args );
	    async_task.executeInNewThread();

	    writeln( "async: ." );
	}

	override
    void go()
    {
        foreach( wn; _wana )
            if ( wn.is_na )
                switch ( wn.na.t )
                {
                    case NA.ASYNC: {if ( wn.na.async.i.able ) wn.na.async.then_(); break;}
                    default:
                }                
            else
                foreach( a; _v )
                    if ( a.able )
                        a.on_wana( wn );
    }
}

void wrapped_dg(THIS,DG,THEN,ARGS...)( THIS This, DG dg, THEN then_, ARGS args )
{
	dg( args );
	This.na!AsyncNa( This, then_ );
}





alias RSTRING = shared(string);

class DownloadI : AsyncAble
{
	string download( string url, RSTRING ret )
	{
		//import requests;
		//auto content = getContent( url );
		////writeln(content.splitter('\n').count);
		// ubyte[] data = content.data;
    	//writeln( data );
    	ret = "OK!";

		return "DONE: " ~ url;
	}

	void then_()
	{
		writeln( "THEN" );
	}


	void async_download( string url, RSTRING ret )
	{
		writeln( "async_download:" );

		async( &download, &then_, url, ret );

		writeln( "async_download: ." );
	}
}


void test()
{
	writeln( "test:" );

    auto a = ma!A();
	auto i = a.ma!DownloadI();

	string url = "https://raw.githubusercontent.com/vitalfadeev/Templates/master/win_window/source/main.d";
	RSTRING ret;
	i.async_download( url, ret );

	writeln( "DELAY" );
	writeln( "DELAY" );
	writeln( "DELAY" ); 
	// wait for end all threads
    import std.parallelism;
	taskPool.finish(true);

	writeln( "game.go:" );
	// take ASYNC callback from wana
	i.go();
	writeln( "game.go: ." );

	writeln( "test: ." );
}

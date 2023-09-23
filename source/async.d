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

import std.container.dlist;
import see;


alias RSTRING = shared(string);

class DownloadI : I
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
}


void fn()
{
	//
}


void async(DG,THEN,ARGS...)( DG dg, THEN then_, ARGS args )
{
    import std.parallelism;


    writeln( "async:" );

    auto async_task = task!wrapped_dg( dg, then_, args );
    async_task.executeInNewThread();

    writeln( "async: ." );
}

void wrapped_dg(DG,THEN,ARGS...)( DG dg, THEN then_, ARGS args )
{
	dg( args );
	na!AsyncNa( then_ );
}



void i_wa_download( string url )
{
	writeln( "i_wa_download:" );

    auto a = ma!A();
	auto i = a.ma!DownloadI();
	RSTRING ret;

	async( &i.download, &i.then_, url, ret );
	  // .then is DownloadA.NA_ASYNC()

	writeln( "i_wa_download: ." );
}


void test()
{
	writeln( "test:" );

	string url = "https://raw.githubusercontent.com/vitalfadeev/Templates/master/win_window/source/main.d";
	i_wa_download( url );

	writeln( "DELAY" );
	writeln( "DELAY" );
	writeln( "DELAY" ); 
    //import std.parallelism;
	//taskPool.finish(true);

	writeln( "game.go:" );
	A.go();
	writeln( "game.go: ." );
	// wait for end all threads

	writeln( "test: ." );
}

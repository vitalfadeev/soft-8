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

	override
	void na( Na na )
	{
		//writeln( "na(): ", na );

		if ( na.t == NA.ASYNC ) 
			NA_ASYNC( na.async );
	}

	void NA_ASYNC( AsyncNa async_ )
	{
		if ( async_.i is this )
		{
			writeln( "NA_ASYNC: THEN!" );
			async_.then_();
			writeln( "NA_ASYNC: ." );
		}
	}
}


void fn()
{
	//
}


void async(DG,I,B,THEN,ARGS...)( DG dg, I i, B b, THEN then_, ARGS args )
{
    import std.parallelism;


    writeln( "async:" );

    auto async_task = task!wrapped_dg( dg, i, b, then_, args );
    async_task.executeInNewThread();

    writeln( "async: ." );
}

void wrapped_dg(DG,I,B,THEN,ARGS...)( DG dg, I i, B b, THEN then_, ARGS args )
{
	dg( args );
	Send!AsyncNa( NA.ASYNC, i, b, then_ );
}


class AParallel : A
{
	//
}


void i_wa_download( string url )
{
	writeln( "i_wa_download:" );

    auto a = ma!A();
	auto i = a.ma!DownloadI();
	auto b = a.ma!DownloadI();
	RSTRING ret;

	async( &i.download, i, b, &i.then_, url, ret );
	  // .then is DownloadA.NA_ASYNC()

	writeln( "i_wa_download: ." );
}

Game game;
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
	game.go();
	writeln( "game.go: ." );
	// wait for end all threads

	writeln( "test: ." );
}

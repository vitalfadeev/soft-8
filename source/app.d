import game;


void main()
{
	// window is part of world
	// w is o
	//        o
	//        o
	//        o
	// give to o ables of window

	// o is o
	// o <- window
	//   Window(o)
	//
	// Window(o)
	//   ox = o.ox
	//   o  = o
	//
	// windows from position
	// windows from O
	//
	// Window(ox)
	//   ox = ox
	//
	// Window(o)
	//   o  = o
	//
	// Window
	//   size = 640x480  // from center (320,240)
	//
	// events from window in to world
	//
	// Window
	//   key -> focused
	//   key -> each
	//   key -> each recursive
	//   mouse_over -> each
	//   mouse_over -> each recursive
	//   mouse_click -> focused
	//   mouse_click -> each
	//   mouse_click -> each recursive
    auto window = new Window();
    auto la1 = window.ma!LA1();
    auto la2 = window.ma!LA2();
    auto lax = window.ma!LAX();
    la2._ox   = PX( 100, 0 );  // (int,int) -> Fixed_16_16
    lax. ox   = PX( 100, 0 );  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX( 100, 100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX(-100, 100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX(-100,-100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX( 100,-100 ).to!OX;  // (int,int) -> Fixed_16_16

    //
    game.sensors ~= window;
    game.sensors ~= 
    	function ( D d ) { 
    		import std.stdio; writeln( "EachSensor: ", d ); 
    	};

    //
    game.go();	
}


import cls.o;
class LA1 : O
{
    mixin OMixin!();

    OX ox;

    pragma( inline, true )
    void on_DT_MOUSEBUTTONDOWN( D d )
    {
    	//
    }

    void la( Renderer renderer )
    {
    	renderer.la( ox );
    }
}

class LA2 : O
{
    mixin OMixin!();

    OX ox;
    OX _ox;

    void la( Renderer renderer )
    {
    	renderer.la( ox, _ox );
    }
}

class LAX : O
{
    mixin OMixin!();

    OX ox;
    OX[] _oxs;

    void la( Renderer renderer )
    {
    	renderer.la( ox, _oxs );
    }
}


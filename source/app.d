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
    V world;
    auto la1 = world.ma!LA1();
    auto la2 = world.ma!LA2();
    auto lax = world.ma!LAX();
    auto art = world.ma!Art();
    la2._ox   = PX( 100, 0 );  // (int,int) -> Fixed_16_16
    lax. ox   = PX( 100, 0 );  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX( 100, 100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX(-100, 100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX(-100,-100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX( 100,-100 ).to!OX;  // (int,int) -> Fixed_16_16

    auto window = new Window();
    window.v = world;

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

    override
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

    override
    void la( Renderer renderer )
    {
    	renderer.la( ox, _ox );
    }
}

class LAX : O
{
    mixin OMixin!();

    OX   ox;
    OX[] _oxs;

    override
    void la( Renderer renderer )
    {
    	renderer.la( ox, _oxs );
    }
}

class Art : O
{
    mixin OMixin!();

    void on_DT_MOUSEBUTTONDOWN( D d )
    {
		import bindbc.sdl;

        if ( d.button.button == SDL_BUTTON_LEFT )  // sub sensor
        {
        	if ( hit_test( PX( d.button.x, d.button.y ).to!OX ) )
        	{
				import std.stdio : writeln;
        		writeln("OK");
        	}
        }
    }

    bool hit_test( OX ox )
    {
    	return oxox.has( ox );
    }
}


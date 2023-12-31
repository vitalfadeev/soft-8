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
    la2._ox   = PX( 100, 0 );  // (int,int) -> Fixed_16_16
    auto lax = world.ma!LAX();
    lax. ox   = PX( 100, 0 );  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX( 100, 100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX(-100, 100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX(-100,-100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX( 100,-100 ).to!OX;  // (int,int) -> Fixed_16_16
    auto art = world.ma!Art();
    art._ox = PX(640,480);

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

enum CurTool
{
	_,
	LA1,
	LA2,
	LAX,
}

class Art : O
{
    mixin OMixin!();
    
    LA1[] la1s;
    LA2[] la2s;
    LAX[] laxs;

    CurTool cur_tool;

    void on_DT_KEYDOWN( D d )
    {
		import bindbc.sdl;

    	if ( d.key.keysym.scancode == SDL_SCANCODE_F1 )
    	{
    		cur_tool = CurTool.LA1;
	    	import std.stdio : writeln;
	    	writeln(cur_tool);
	    }

    	if ( d.key.keysym.scancode == SDL_SCANCODE_F2 )
    	{
    		cur_tool = CurTool.LA2;
	    	import std.stdio : writeln;
	    	writeln(cur_tool);
	    }

    	if ( d.key.keysym.scancode == SDL_SCANCODE_F3 )
    	{
    		cur_tool = CurTool.LAX;
	    	import std.stdio : writeln;
	    	writeln(cur_tool);
	    }
    }

    void on_DT_MOUSEBUTTONDOWN( D d )
    {
		import bindbc.sdl;

        if ( d.button.button == SDL_BUTTON_LEFT )  // sub sensor
    	if ( has( SX( d.button.x, d.button.y ).to!OX ) )
    	{
			import std.stdio : writeln;
    		writeln( "OK: at ", SX( d.button.x, d.button.y ) );
    	}
    }

    bool has( OX ox )
    {
    	return oxox.has( ox );
    }
}


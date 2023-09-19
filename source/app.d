import game;


void main()
{
    auto window = new Window();
    auto la1 = window.ma!LA1();
    auto la2 = window.ma!LA2();
    auto lax = window.ma!LAX();
    la2._ox = PX( 100, 0 );  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX( 100, 100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX( 100, 100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX( 200, 100 ).to!OX;  // (int,int) -> Fixed_16_16
    lax._oxs ~= PX( 200, 200 ).to!OX;  // (int,int) -> Fixed_16_16

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


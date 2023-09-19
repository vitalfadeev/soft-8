import game;


void main()
{
    auto window = new Window();
    auto la1 = window.ma!LA1();
    auto la2 = window.ma!LA2();
    la2._ox = PX( 100, 0 );  // (int,int) -> Fixed_16_16

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


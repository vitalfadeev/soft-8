import game;


void main()
{
    auto window = new Window();
    auto la1 = window.ma!LA1();
    la1.ox = PX( 0, 0 );  // (int,int) -> Fixed_16_16
    //la1.size = OX( 100,100 );

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
}


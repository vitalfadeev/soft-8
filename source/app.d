import game;


void main()
{
    auto window = new Window();
    auto box = window.ma!Box();
    //box.pos  = OX( 0,0 );
    //box.size = OX( 100,100 );

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
class Box : O
{
    mixin OMixin!();
}

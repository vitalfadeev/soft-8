import game;


void main()
{
    void EachSensor( D d )
    {
		import std.stdio;
        writeln( "EachSensor: ", d );                                        // action
    }

    import ui.window : WindowSensor;
    auto window_sensor = new WindowSensor();
    auto box = new Box();
    box.go( 0, 0 );
    window_sensor ~= box;

    //
    game.sensors ~= window_sensor;
    game.sensors ~= &EachSensor;
    //game.sensors ~= function ( D d ) { import std.stdio; writeln( "EachLambdaSensor: ", d ); };

    //
    game.go();	
}


import cls.o;
class Box : O
{
	// rect 
	// la
}

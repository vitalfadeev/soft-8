import game;


void main()
{
    void EachSensor( D d )
    {
		import std.stdio;
        writeln( "EachSensor: ", d );                                        // action
    }

    import ui.window : WindowSensor;

    //
    game.sensors ~= new WindowSensor();
    game.sensors ~= &EachSensor;
    //game.sensors ~= function ( D d ) { import std.stdio; writeln( "EachLambdaSensor: ", d ); };

    //
    game.go();	
}


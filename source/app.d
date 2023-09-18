import game;


void main()
{
    // no-sensor, no-brain, action
    void EachSensor( D d )
    {
		import std.stdio;
        writeln( "EachSensor: ", d );                                        // action
    }

    //
    game.sensors ~= &EachSensor;

    //
    game.go();	
}

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
    auto box = window_sensor.ma!Box();
    box.pos  = LX( 0,0 );
    box.size = LX( 100,100 );

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
    mixin OMixin!();

	@property LX     pos;
	@property LX     size;
	@property LXRect rect;

	void go( LX pos )
	{
		this.pos = pos;
		this.la();
	}

	void la()
	{
		//
	}
}

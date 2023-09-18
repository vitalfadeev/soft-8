import game;


void main()
{
    void EachSensor( D d )
    {
		import std.stdio;
        writeln( "EachSensor: ", d );                                        // action
    }

    auto window = new Window();
    auto box = window.ma!Box();
    box.pos  = LX( 0,0 );
    box.size = LX( 100,100 );

    //
    game.sensors ~= window;
    game.sensors ~= &EachSensor;

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

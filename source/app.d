import game;


void main()
{
    void EachSensor( D d )
    {
		import std.stdio;
        writeln( "EachSensor: ", d );                                        // action
    }

    void MouseClickSensor( D d )
    {
		import std.stdio;
		import bindbc.sdl;
		if ( d.t == SDL_MOUSEBUTTONDOWN )
		if ( d.button.button == SDL_BUTTON_LEFT )
	        writeln( "MouseClickSensor: ", d.button );
    }

    //
    game.sensors ~= &EachSensor;
    game.sensors ~= &MouseClickSensor;

    //
    game.go();	
}


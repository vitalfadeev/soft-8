import std.stdio;

import cls.o;
import types;


void main()
{
	auto renderer = new Renderer();

	auto chip = new Chip();

	// Test Draw
	chip.Draw( renderer );

	chip.To!Chip_Hovered();
	chip.Draw( renderer );

	// Test Secnsor
	chip.To!Chip();
	chip.Sensor(D(1));

	chip.To!Chip_Hovered();
	chip.Sensor(D(1));
}


class Chip : O
{
	mixin StateMixin!();

	override
	void Draw( Renderer renderer )
	{
		writeln( "Chip.Draw" );
	}
}

class Chip_Selected : Chip
{
	mixin StateMixin!();

	override
	void Draw( Renderer renderer )
	{
		writeln( "Chip_Selected.Draw" );
	}
}

class Chip_Hovered : Chip
{
	mixin StateMixin!();

	override
	void Draw( Renderer renderer )
	{
		writeln( "Chip_Hovered.Draw" );
	}
}


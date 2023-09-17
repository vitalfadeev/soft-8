import std.stdio;

import cls.o;
import types;


void main()
{
	auto renderer = new Renderer();

	auto chip = new Chip();

	// Test Draw
	chip.la( renderer );

	chip.to!Chip_Hovered();
	chip.la( renderer );

	// Test Secnsor
	chip.to!Chip();
	chip.sense(D(1));

	chip.to!Chip_Hovered();
	chip.sense(D(1));
}


class Chip : O
{
	mixin StateMixin!();

	override
	void la( Renderer renderer )
	{
		writeln( "Chip.Draw" );
	}
}

class Chip_Selected : Chip
{
	mixin StateMixin!();

	override
	void la( Renderer renderer )
	{
		writeln( "Chip_Selected.Draw" );
	}
}

class Chip_Hovered : Chip
{
	mixin StateMixin!();

	override
	void la( Renderer renderer )
	{
		writeln( "Chip_Hovered.Draw" );
	}
}


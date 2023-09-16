import std.stdio;

import cls.o;
import types;


void main()
{
	auto renderer = new Renderer();

	auto chip = new Chip();

	// Test Draw
	chip.ga( renderer );

	chip.To!Chip_Hovered();
	chip.ga( renderer );

	// Test Secnsor
	chip.To!Chip();
	chip.sense(D(1));

	chip.To!Chip_Hovered();
	chip.sense(D(1));
}


class Chip : O
{
	mixin StateMixin!();

	override
	void ga( Renderer renderer )
	{
		writeln( "Chip.Draw" );
	}
}

class Chip_Selected : Chip
{
	mixin StateMixin!();

	override
	void ga( Renderer renderer )
	{
		writeln( "Chip_Selected.Draw" );
	}
}

class Chip_Hovered : Chip
{
	mixin StateMixin!();

	override
	void ga( Renderer renderer )
	{
		writeln( "Chip_Hovered.Draw" );
	}
}


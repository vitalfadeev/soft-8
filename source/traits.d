module traits;


// isDerivedFromInterface!(O,ISenseAble) == true
template isDerivedFromInterface(T,A)
{ 
    import std.traits;
    import std.meta;

    template isEqual(A) { enum isEqual = is( T == A ); }

    static if ( anySatisfy!( isEqual!A, InterfacesTuple!T ) )
        enum isDerivedFromInterface = true;
    else
        enum isDerivedFromInterface = false;
}

// isSameInstaneSize!(Chip_Init,Chip_Hovered) == true
template isSameInstaneSize(CLS,T)
{
    static if ( __traits( classInstanceSize, CLS ) != __traits( classInstanceSize, T ) )
        enum isSameInstaneSize = true;
    else
        enum isSameInstaneSize = false;
}

// TXYXY = Detect8bitAlignedType!(TX,TX)
// Detect8bitAlignedType!(uint,uint) == ulong
template Detect8bitAlignedType(TX,TY)
{
    static if ( TX.sizeof + TY.sizeof <= 8 )
        alias Detect8bitAlignedType = ubyte;
    else
    static if ( TX.sizeof + TY.sizeof <= 16 )
        alias Detect8bitAlignedType = ushort;
    else
    static if ( TX.sizeof + TY.sizeof <= 32 )
        alias Detect8bitAlignedType = uint;
    else
    static if ( TX.sizeof + TY.sizeof <= 64 )
        alias Detect8bitAlignedType = ulong;
    else
    static if ( TX.sizeof + TY.sizeof <= 128 )
        alias Detect8bitAlignedType = ucent;
    else
        static assert( 0, "Expected size TX+TY <= 128" );
}


// hasMember!(T, "sense")
template hasMethod(T,string M)
{
    import std.traits;

    static if ( hasMember!(T,M)/* && isCallable!(__traits(getMember,T,M))*/ )
        enum hasMethod = true;
    else
        enum hasMethod = false;
}

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
    static if ( __traits( classInstanceSize, CLS ) != __traits( classInstanceSize, typeof(this) ) )
        enum isSameInstaneSize = true;
    else
        enum isSameInstaneSize = false;
}

// TXYXY = Detect8bitAlignedType!(TX,TX)
// Detect8bitAlignedType!(uint,uint) == ulong
tempalte Detect8bitAlignedType(TX,TY)
{
    //
}

module traits;


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

template isSameInstaneSize(CLS,T)
{
    static if ( __traits( classInstanceSize, CLS ) != __traits( classInstanceSize, typeof(this) ) )
        enum isSameInstaneSize = true;
    else
        enum isSameInstaneSize = false;
}

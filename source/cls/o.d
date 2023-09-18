module cls.o;

import bindbc.sdl;
import types;
import la;

// O
//   v
//     o
//     o
//   sense
//   ma
//   la
//   to

// O 
//  ma child in O
//
// O
//   ma!T
//   ma!T( T_args )
abstract
class O : IVAble, ILaAble, ISenseAble, IStateAble
{
    alias T = typeof(this);

    mixin SenseAble!T;
    mixin LaAble!T;
    mixin VAble!(T,O);
    mixin StateAble!T;
}

interface ISenseAble
{
    void sense( D d );
}

interface ILaAble
{
    void la( Renderer renderer );
}

interface IVAble 
{
    auto ma(T,ARGS...)( ARGS args );
    int  opApply(scope int delegate(O) dg);
    int  opApplyReverse(scope int delegate(O) dg);
    void opOpAssign( string op : "~" )( O b );
    void Out( O b );
}

interface IStateAble
{
    void to(CLS)();
    void try_to(CLS)( O o, D d );
}


mixin template SenseAble( T )
{
    import traits : isDerivedFromInterface;

    void sense( D d ) 
    {
        // CUSTOM CODE
    };

    //
    static if( isDerivedFromInterface!(T,IVAble) )
    void sense_recursive( D d )
    {
        foreach( o; this.v )
            o.sense( d );
    }
}

mixin template LaAble( T )
{
    void la( Renderer renderer ) {};
}

mixin template VAble( T, TCHILDS )
{
    import std.container.dlist : DList;
    DList!TCHILDS v;

    // 
    auto ma(TC,ARGS...)( ARGS args )
        // if ( TC derrived from TCHILDS )
    {
        // ma child of class T
        // ma!T
        // ma!T()
        // ma!T( T_args )
        //   new T
        //   add in to this.v
        auto b = new TC( args );

        this.v ~= b;

        return b;
    }


    // foreach( o; this )...
    int opApply(scope int delegate(TCHILDS) dg)
    {
        foreach( o; v )
        {
            int result = dg(o);
            if (result)
                return result;
        }
        return 0;
    }    

    // foreach_reverse( o; this )...
    int opApplyReverse(scope int delegate(TCHILDS) dg)
    {
        foreach_reverse( o; v )
        {
            int result = dg(o);
            if (result)
                return result;
        }
        return 0;
    }


    void opOpAssign( string op : "~" )( TCHILDS b )
    {
        // o
        //   v <- b
        v ~= b;
    }

    void Out( TCHILDS b )
    {
        // v.remove( b )
    }
}

mixin template StateAble( T )
{
    //
    void to(CLS)()
    {
        // o
        //   state -> state'

        // o
        //   __vptr
        //   __monitor
        //   interfaces
        //   fields
        import std.conv;

        // object.sizeof != object.sizeof
        //   assert
        static 
        if ( __traits( classInstanceSize, CLS ) != __traits( classInstanceSize, typeof(this) ) )
            static 
            assert( "Class instance size must be equal. " ~ 
                CLS.stringof ~ " and " ~ typeof(this).stringof ~ ". " ~  
                __traits( classInstanceSize, CLS ).to!string ~ " != " ~ __traits( classInstanceSize, typeof(this) ).to!string ~ "."
            );

        //
        this.__vptr = cast(immutable(void*)*)typeid(CLS).vtbl.ptr;
    }    
}

// struct Chip
//   O _super;
//   alias _super this;
//
//   void sense( o, d )
mixin template OMixin()
{
    import traits : isDerivedFromInterface;

    alias THIS=__traits(parent, {});
    pragma( msg, "class: ", THIS );    

    //
    static if( isDerivedFromInterface!(THIS,ISenseAble) )
    mixin OsenseMixin!(THIS);
}

// O
//   sense
mixin template OsenseMixin(T)
{
    import types;

    override    
    void sense( D d )
    {
        import traits : isDerivedFromInterface;
        pragma( msg, "osens: ", __FUNCTION__ );

        // sense
        sense_!T( this, d );

        // try go to new state
        static if( isDerivedFromInterface!(T,IStateAble) )
        try_to!T( this, d );

        // recursive sense
        static if( isDerivedFromInterface!(T,IVAble) )
        sense_recursive( d );
    }
}


// switch..case
//   if d.type == SDL_*   on_SDL_*;
//   if d.type == XSDL_*  on_XSDL_*;
//pragma( inline, true )
void sense_(T)( O o, D d )
{
    import std.traits;
    import std.string;
    import std.format;

    // SDL
    static foreach( m; __traits( allMembers, T ) )
        static if ( __traits(isStaticFunction, __traits(getMember, T, m)) ) 
            static if ( m.startsWith( "on_SDL_" ) )
            {
                if (d.type == mixin(m[3..$])) 
                { 
                    __traits(getMember, T, m)( o, d ); 
                    return; 
                }
            }

    // XSDL
    static foreach( m; __traits( allMembers, T ) )
        static if ( __traits(isStaticFunction, __traits(getMember, T, m)) ) 
            static if ( m.startsWith( "on_XSDL_" ) )
            {
                if (d.type == mixin(m[3..$]))
                { 
                    __traits(getMember, T, m)( o, d ); 
                    return; 
                }
            }
}


// Try
//   to_Init()
//   to_Hover()
//pragma( inline, true )
void try_to(CLS)( O o, D d )
{
    import std.string;

    static foreach( m; __traits( allMembers, CLS ) )
        static if ( __traits(isStaticFunction, __traits(getMember, CLS, m)) ) 
            static if ( m.startsWith( "to_" ) )
                __traits(getMember, CLS, m)( o, d );
}


unittest
{
    class Chip : O
    {
        mixin OMixin!();

        override
        void la( Renderer renderer )
        {
            import std.stdio : writeln;
            writeln( "Chip.Draw" );
        }
    }

    class Chip_Hovered : Chip
    {
        mixin OMixin!();

        override
        void la( Renderer renderer )
        {
            import std.stdio : writeln;
            writeln( "Chip_Hovered.Draw" );
        }
    }

    //
    auto renderer = new Renderer();

    auto chip = new Chip();

    // Test Draw
    chip.la( renderer );

    chip.to!Chip_Hovered();
    chip.la( renderer );

    // Test Secnsor
    chip.to!Chip();
    //chip.sense(D_KEY_PRESSED('1'));

    chip.to!Chip_Hovered();
    //chip.sense(D_KEY_PRESSED('1'));
}

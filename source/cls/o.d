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
    mixin VAble!T;
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
    auto ma(TCHILD,ARGS...)( ARGS args );
    int  opApply(scope int delegate(O) dg);
    int  opApplyReverse(scope int delegate(O) dg);
    void opOpAssign( string op : "~" )( O b );
    void de( O b );
}

interface IStateAble
{
    void to(CLS)();
}


mixin template SenseAble( T )
{
    import traits : isDerivedFromInterface;
    import std.traits;
    import traits;


    void sense( D d ) 
    {
        import cls.o : sense_, try_to_, sense_v;
        import traits : isDerivedFromInterface;
        pragma( msg, "osens: ", __FUNCTION__ );

        // sense
        sense_( this, d );

        // try go to new state
        //static if( isDerivedFromInterface!(T,IStateAble) )
        try_to_( this, d );

        // recursive v sense
        //static if( isDerivedFromInterface!(T,IVAble) )
        sense_v( this.v, d );
    };
}


// switch..case
//   if d.type == SDL_*   on_SDL_*;
//   if d.type == XSDL_*  on_XSDL_*;
//pragma( inline, true )
void sense_(T)( T o, D d )
{
    import std.traits;
    import std.string;
    import std.format;

    pragma( msg, "sense_: ", T);

    // SDL
    static foreach( m; __traits( allMembers, T ) )
        static if ( isCallable!(__traits(getMember, T, m)) ) 
            static if ( m.startsWith( "on_SDL_" ) )
            {
                pragma( msg, "         ", m );
                if (d.type == mixin(m[3..$])) 
                { 
                    __traits(getMember, o, m)( d ); 
                    return; 
                }
            }

    // DT_
    static foreach( m; __traits( allMembers, T ) )
        static if ( isCallable!(__traits(getMember, T, m)) ) 
            static if ( m.startsWith( "on_DT_" ) )
            {
                pragma( msg, "          ", m );
                if (d.type == mixin(m[3..$]))
                { 
                    __traits(getMember, o, m)( d ); 
                    return; 
                }
            }
}

// Try
//   to_Init()
//   to_Hover()
//pragma( inline, true )
void try_to_(T)( T o, D d )
{
    import std.string;
    import std.traits;

    static foreach( m; __traits( allMembers, T ) )
        static if ( isCallable!(__traits(getMember, T, m)) )
            static if ( m.startsWith( "to_" ) )
                __traits(getMember, o, m)( d ); 
}


//
void sense_v( V v, D d )
{
    foreach( _o; v )
        _o.sense( d );
}


mixin template LaAble( T )
{
    OX ox_;
    OX _ox;

    //
    void la( Renderer renderer ) 
    {
        //
    };

    // oxox, px_, _px, pxpx
    auto oxox()
    {
        return OXOX( ox_, _ox ); // M16,M16,M16,M16
    }

    auto px_()
    {
        return ox_.to!PX; 
    }


    auto _px()
    {
        return _ox.to!PX; 
    }

    auto pxpx()
    {
        return PXPX( px_, _px ); // M16,M16,M16,M16
    }
}

mixin template VAble( T )
{
    import traits;

    V v;

    // 
    auto ma(TCHILD,ARGS...)( ARGS args )
        // if ( TC derrived from O )
    {
        v.ma!TCHILD( args );
    }


    // foreach( o; this )...
    int opApply(scope int delegate(O) dg)
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
    int opApplyReverse(scope int delegate(O) dg)
    {
        foreach_reverse( o; v )
        {
            int result = dg(o);
            if (result)
                return result;
        }
        return 0;
    }


    void opOpAssign( string op : "~" )( O b )
    {
        // o
        //   v <- b
        v ~= b;
    }

    void de( O b )
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
        import traits;

        // object.sizeof != object.sizeof
        //   assert
        static 
        if ( !isSameInstaneSize!(CLS,T) )
            static assert( "Class instance size must be equal. " ~ 
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
    alias T=__traits(parent, {});
    pragma( msg, "class: ", T );

    override
    void sense( D d ) 
    {
        import cls.o : sense_, try_to_, sense_v;
        import traits : isDerivedFromInterface;
        pragma( msg, "osens: ", __FUNCTION__ );

        // sense
        sense_( this, d );

        // try go to new state
        //static if( isDerivedFromInterface!(T,IStateAble) )
        try_to_( this, d );

        // recursive v sense
        //static if( isDerivedFromInterface!(T,IVAble) )
        sense_v( this.v, d );
    };
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
    auto chip = new Chip();

    // Test Draw
    auto renderer = new Renderer();
    chip.la( renderer );

    chip.to!Chip_Hovered();
    chip.la( renderer );

    // Test Secnsor
    chip.to!Chip();
    //chip.sense(D_KEY_PRESSED('1'));

    chip.to!Chip_Hovered();
    //chip.sense(D_KEY_PRESSED('1'));
}

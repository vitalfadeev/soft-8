module cls.o;

import std.container.dlist : DList;
import bindbc.sdl;
import types;
import la;

// O
//

// O 
//  ma child in O
//
// O
//   ma!T
//   ma!T( T_args )

abstract
class O
{
    alias T = typeof(this);

    // virtual functions
    // sensable
    void sense( D d ) {};
    // visable
    void ga( Renderer renderer ) {};

    // Inner content
    DList!T v;

    // vars
    //   ...


    // 
    auto ma(T,ARGS...)( ARGS args )
    {
        // ma child of class T
        // ma!T
        // ma!T()
        // ma!T( T_args )
        //   new T
        //   add in to this.v
        auto b = new T( args );

        this.v ~= b;

        return b;
    }


    // foreach( e; o )...
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

    // foreach_reverse( e; o )...
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


    //
    void To(CLS)()
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


    void Eat( O b )
    {
        v ~= b;
    }

    void Out( O b )
    {
        // v.remove( b )
    }


    // Recursive
    void sense_recursive( D d )
    {
        foreach( e; this )
            e.sense( d );
    }
}


// struct Chip
//   O _super;
//   alias _super this;
//
//   void sense( o, d )
mixin template OMixin()
{
    alias THIS=__traits(parent, {});
    pragma( msg, "class: ", THIS );    

    //
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
        pragma( msg, "osens: ", __FUNCTION__ );

        sense_!T( this, d );

        // recursive
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
void TryTo(T)( O o, D d )
{
    import std.string;

    static foreach( m; __traits( allMembers, T ) )
        static if ( __traits(isStaticFunction, __traits(getMember, T, m)) ) 
            static if ( m.startsWith( "to_" ) )
                __traits(getMember, T, m)( o, d );
}


mixin template StateMixin()
{
    import types;

    alias THIS = typeof(this); // Init, Hover
    pragma( msg, "state: ", THIS );
    
    mixin State_sense_Mixin!(THIS);
}

mixin template State_sense_Mixin(T)
{
    override
    void sense( D d )
    {
        pragma( msg, "ssens: ", __FUNCTION__ );

        sense_!T( this, d );
        TryTo!T( this, d );

        // recursive
        sense_recursive( d );
    }
}

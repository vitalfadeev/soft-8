module cls.o;

import bindbc.sdl;
import types;
import la;


abstract
class O
{
    alias T = typeof(this);

    // virtual functions
    void Sensor( D d ) {};
    void Draw( Renderer renderer ) {};
    void Save( size_t level, ubyte[]* result ) {};
    void Load() {};
    void Arrange( Ars* ) {};

    // DList
    // Inner content
    T f;   // First inner object  
    T l;   // Last inner object     
    T i;   // I. Central inner object. Focused. 
    // Same level object. SList-pattern
    T next;
    T prev;

    // Location
    Loc loc; // CS | XY

    // Data
    M8 id;

    // View
    Cola      fg = Cola( 199, 199,  199, 255 );
    Cola      bg = Cola(   0,   0,    0, 255 );
    //
    bool      hoverable;
    bool      selectable;
    // Drag
    bool      dragable;


    // Methods
    bool Is( Loc b )
    {
        return false;
    }

    // foreach( e; o )...
    int opApply(scope int delegate(O) dg)
    {
        for ( auto o=f; o !is null; o = o.next )
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
        for ( auto o=l; o !is null; o = o.prev )
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
        if ( this.f is null )
        {
            this.f = b;
            this.l = b;
        }
        else
        {
            this.l.next = b;
            b.prev = this.l;
            this.l = b;
        }
    }

    void Out( O b )
    {
        //
    }


    // Recursive
    void SensorRecursive( D d )
    {
        foreach( e; this )
            e.Sensor( d );
    }
}


// struct Chip
//   O _super;
//   alias _super this;
//
//   void Sensor( o, d )
mixin template OMixin()
{
    alias THIS=__traits(parent, {});
    pragma( msg, "class: ", THIS );    

    //
    mixin OSensorMixin!(THIS);
}

// O
//   Sensor
mixin template OSensorMixin(T)
{
    import types;

    override    
    void Sensor( D d )
    {
        pragma( msg, "osens: ", __FUNCTION__ );

        Sense!T( this, d );

        // recursive
        SensorRecursive( d );
    }
}


// switch..case
//   if d.type == SDL_*   on_SDL_*;
//   if d.type == XSDL_*  on_XSDL_*;
//pragma( inline, true )
void Sense(T)( O o, D d )
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
    
    mixin StateSensorMixin!(THIS);
}

mixin template StateSensorMixin(T)
{
    override
    void Sensor( D d )
    {
        pragma( msg, "ssens: ", __FUNCTION__ );

        Sense!T( this, d );
        TryTo!T( this, d );

        // recursive
        SensorRecursive( d );
    }
}

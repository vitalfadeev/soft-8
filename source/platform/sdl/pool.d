module platform.sdl.pool;

version (SDL):
import bindbc.sdl;
import types;


struct Pool
{
    D front;

    pragma( inline, true )
    void popFront()
    {
        if ( SDL_WaitEvent( cast( SDL_Event* )&this.front ) == 0 )
            throw new SDLException( "Pool.popFront: " );
    }

    pragma( inline, true )
    bool empty()
    {
        return ( front.type == SDL_QUIT );
    }

    //alias put(T) = opOpAssign!("~", T)(T t);

    pragma( inline, true )
    void opOpAssign( string op : "~" )( SDL_EventType t )
    {
        SDL_Event event;
        event.type = t;
        SDL_PushEvent( &event ); // The event is copied into the queue.
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( D d )
    {
        SDL_PushEvent( cast(SDL_Event*)&d ); // The event is copied into the queue.
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( D_LA d )
    {
        SDL_PushEvent( cast(SDL_Event*)&d ); // The event is copied into the queue.
    }
}

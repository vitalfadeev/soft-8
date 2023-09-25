module platform.windows.pool;

version (WINDOWS_NATIVE):
import core.sys.windows.windows;
import types;


struct Pool
{
    D front;  // MSG

    pragma( inline, true )
    void popFront()
    {
        if ( GetMessage( cast(MSG*)&this.front, null, 0, 0 ) == 0 ) 
            throw new SDLException( "Pool.popFront: " );
    }

    pragma( inline, true )
    bool empty()
    {
        return ( front.type == WM_QUIT );
    }

    //alias put(T) = opOpAssign!("~", T)(T t);

    pragma( inline, true )
    void opOpAssign( string op : "~" )( UINT t )
    {
        SendMessage( hwnd, t, 0, 0 ); // The event is copied into the queue.
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( D d )
    {
        SendMessage( d.hwnd, d.message, d.wParam, d.lParam ); // The event is copied into the queue.
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( D_LA d )
    {
        this ~= cast(D)d;
    }

    pragma( inline, true )
    void opOpAssign( string op : "~" )( D_KEY_PRESSED d )
    {
        this ~= cast(D)d;
    }
}

module fifo;


// SLIST
struct FIFO(T)
{
    struct TLISTITEM
    {
        T a;
        TLISTITEM* next;
    }

    TLISTITEM* f;  // f ........ b
    TLISTITEM* b;  // first      last

    pragma( inline, true )
    bool empty()
    {
        return ( this.f is null );
    }


    pragma( inline, true )
    T front()
    {
        return *( cast( T* )( this.f ) );
    }

    
    pragma( inline, true )
    T back()
    {
        return *( cast( T* )( this.b ) );
    }

    
    pragma( inline, true )
    void popFront()
    {
        if ( this.f is null )
            throw new Exception( "empty fifo" );

        auto next = this.f.next;

        this.f.destroy();

        if ( next is null )
        {
            this.b = null;
            this.f = null;
        }
        else
            this.f = next;
    }


    pragma( inline, true )
    void put( T a )
    {
        auto listitem = new TLISTITEM( a );
        
        if ( this.empty )
        {
            this.f = listitem;
            this.b = listitem;
        }
        else
        {
            this.b.next = listitem;
            this.b      = listitem;
        }
    }


    void opOpAssign( string op : "~" )( T b )
    {
        this.put( b );
    }


    pragma( inline, true )
    auto copy()
    {
        return this;
    }
}

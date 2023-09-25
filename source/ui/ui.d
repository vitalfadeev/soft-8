module ui.ui;

// wait MOUSE_MOVE x,y
// on MOUSE_MOVE x,y
//   self test self has x,y
//   if has
//     MOUSE_OVER
//     draw rect x,y,w,h
//
// wait DRAW
// on DRAW x,y,w,h
//   self test self rect over x,y,w,h
//   if over
//     set clip x,y,w,h
//     draw x,y,w,h
//     each o in x,y,w,h
//       draw o, x,y,w,h

// Draw( o, rect )
//   o.DrawPooled( rect)
//   o.DirectDraw( rect )
//
// Draw( o, rect )
//   o.DrawPooled( rect)
//     pool ~= D( DRAW, rect )
//   o.DirectDraw( rect )
//     renderer.DrawRect( rect )

// Visable
//   in pixels

// Sensable
//   in sensels
//
// sensel -> pixel
//
// sensel -> pixel -> Visable -> draw

// A  - свет
// E  - элемент
// EA - элемент света
//
// pixel        - EA
// picture      - A
// draw picture - MA
// draw         - M

// A  - свет
// G  - двигать
// GA - двигать свет
//
// point
// ga point
// ga point to x,y
// ga point to x,y via point
//   1 to 2
//   1 to 3 via 2
//   1 to 4 via 3 via 2
//
// ga point to x,y via point soft
//   1 to 3 via 2 soft
//
// a
// la
// laa
//
// la( xy )              // point
// la( xy[] )            // points
// laa( xy )             // line
// laa( xy, xy2 )        // line
// laa( xy[] )           // lines
// laa( xy, xy[] )       // lines
// laam( xy, xy2 )       // soft soft line via xy to xy2
// laam( xy, xy2, xy3 )  // soft soft line via xy via xy2 to xy3
// laam( xy[] )          // soft soft line via xy[]
// laam( xy, xy[] )      // soft soft line via xy[]
//
// la
// la xy
// la xy xy'
// la xy xy' xy''

// LIGHT
// la( xy )               // point  xy
// la( xy[] )             // points xy[] = ( xy.length, xy.ptr )

// LIGHT
// laa( xy, _xy )        // line  xy to _xy
// laa( xy, _xy, __xy )  // line  xy to _xy to __xy
// laa( xy[] )           // lines xy[] = struct( length, ptr )

// SOUND
// sa()
// sa( y )
// sa( y, _y )
// sa( y, _y, __y )

// soft 
//        2
//        /\
//       /  \
//      /    \
//     /      \
//    /        \
//   /          \
//  /            \
// 1              3
//
//        2
//        /\
//       /  \
//      /    \
//     /      *  center
//    /        \
//   /          \
//  /            \
// 1              3
//
//
//         2                2             2
//        _-_                \            |
//       /   \                \           |
//      /     |                \          |
//     /      *  center         *    to   *      \ | = k
//    /       |                  \        |          
//   /         \                  \       |
//  /           -___-              \      |
// 1              3                 3     3
//
//
// \ | = k
//         via center
//         via center x,y
// 2-*-3
// 2-* *-3
//
// 2-* 
// *-3
//
// 2-* 
//   ko
// *-3
//   ko
//
// 2-* 
//   ko  
//     2 - горизонтальна
//     * - диагональная
// *-3
//   ko  
//     * - диагональна
//     3 - горизонтальна
//
// 2-* 
//   ko  
//     2 - горизонтальна
//     * - диагональная
//     change k from k2 to k*
// *-3
//   ko  
//     * - диагональна
//     3 - горизонтальна
//     change k from k* to k3

// fill
// x[y] = last x
// x[y] = last x at y
//
// x[y]
//   123456789ABCDEFGHI       1-2     2-3   
//           2                ======  ======
// 1        _-_               7 -> 2  1 -> 9
// 2       /   \              6 -> 3  2 -> A
// 3      /     |             5 -> 4  3 -> C
// 4     /      *  center     4 -> 5  4 -> C
// 5    /       |             3 -> 6  5 -> C
// 6   /         \            2 -> 8  6 -> D
// 7  /           -___-       1 -> 9  7 -> E
//   1              3                 7 -> F

//
// x[y]                       1-2     2-3     HLA
//   123456789ABCDEFGHI       f(y)    f(y)    x,y - x',y
//           2                ======  ======  ===========
// 1        _-_               1 -> 9  1 -> 9  9,1 - 9.1
// 2       /---\              2 -> 8  2 -> A  8,2 - A,2
// 3      /-----|             3 -> 6  3 -> C  6,3 - C,3
// 4     /------*  center     4 -> 5  4 -> C  5,4 - C,4
// 5    /-------|             5 -> 4  5 -> C  4,5 - C,5
// 6   /---------\            6 -> 3  6 -> D  3,6 - D,6
// 7  /------------___-       7 -> 2  7 -> E  2,7 - E,7
//   1              3                 7 -> F  

// fill
//   by контур
//   by brush width
//     const
//     func

// Loc
// Location
//   x,y     - center of body

// Body
//   x,y,w,h

// Body
//   x,y,w,h  - rect body
//   cx,cy    - center

// Body
//   x,y,w,h  - rect body
//   sx,sy    - start point  // may be center  // center of rotation


// File
//   la go     //  файлс движениями токи света
//
// File
//   la go go  // файл с жвиэениями группы точек света

// Blanced
//   center
//     x from center
//    -x from center
//     y from center
//    -y from center
//
//          y
//       -x c x
//         -y
//
// always
//  one point in center
//   1x1 3x1 5x1 7x1
//   1x3 3x3 5x3 7x3
//   1x5 3x5 5x5 7x5
//   1x7 3x7 5x7 7x7

// O
//   Button             - margin: 10
//     ButtonOk
//     ButtonCancel
//   Check
//   Text               - color: inherit

// O
//   Window : O
//     la()
//       game.pool <- DT_LA, rect
// game
//   pool
//     DT_LA
//       foreach o in rect
//         o.la()

module brain;

// brain
// sensor
//   brain
//     memory
//     logic conditions
//     actions
//
// brain
//   память
//   логические модули
//
// brain
//   memory
//   && 
//
// brain
//   memory  // dep sensor state
//   &&      // &&

// brain
// memory - links - action
//
// brain
// mem   links
//   m1 - \
//   m2 -  + -- - action
//   m3 - /

// brain
//  mem   ||      - and m, 000
//   0 - \
//   0 -  + -- 0
//   0 - /
//
//  mem   ||      - and m, 100
//   1 - \
//   0 -  + -- 0
//   0 - /
//
//  mem   &&      - and m, 111
//   1 - \
//   1 -  + -- 1
//   1 - /
//
//  mem   &&      - and m, 100
//   1 - \
//   0 -  + -- 0
//   0 - /

// and
// and m, 0000_0000
//  ---------
// -|m1 &   | 
// -|m2     | 
// -|m3     | 
// -|m4     |-
// -|m5     | 
// -|m6     | 
// -|m7     | 
// -|m8     | 
//  ---------
//
// or
// or m, 0000_0000
//  ---------
// -|m1 |   | 
// -|m2     | 
// -|m3     | 
// -|m4     |-
// -|m5     | 
// -|m6     | 
// -|m7     | 
// -|m8     | 
//  ---------

//
// and m, 1111_1111
// je  ...
//    ---------
// 1 -|m1 &   | 
// 1 -|m2     | 
// 1 -|m3     | 
// 1 -|m4    E|- 1
// 1 -|m5    Z| 
// 1 -|m6     | 
// 1 -|m7     | 
// 1 -|m8     | 
//    ---------
//
// and m, 0000_0001
// je  ...
//    ---------
// 0 -|m1 &   | 
// 0 -|m2     | 
// 0 -|m3     | 
// 0 -|m4    E|- 1
// 0 -|m5    Z| 
// 0 -|m6     | 
// 0 -|m7     | 
// 1 -|m8     | 
//    ---------
//
// and m, 0000_0000
// je  ...
//    ---------
// 0 -|m1 &   | 
// 0 -|m2     | 
// 0 -|m3     | 
// 0 -|m4    E|- 1
// 0 -|m5    Z| 
// 0 -|m6     | 
// 0 -|m7     | 
// 0 -|m8     | 
//    ---------
//

// flags   
//     mem       flags
//    ---------
//   -|m1     |  PF  |
//   -|m2     |      |
//   -|m3     |      |
//   -|m4     |-     | ZF
//   -|m5     |      |
//   -|m6     |      |
//   -|m7     |      |
//   -|m8     |  SF  |
//    ---------
//
// memory
//   m8 m7 m6 m5 m4 m3 m2 m1


// sense
// and m, 0000_0000
// je  ...
//    ---------
// 0 -|m1 &   | 
// 0 -|m2     | 
// 0 -|m3     | 
// 0 -|m4    E|- 1
// 0 -|m5    Z| 
// 0 -|m6     | 
// 0 -|m7     | 
// 0 -|m8     | 
//    ---------
//
// ------- -------  
// 0 0 0 1 0 0 0 0  and 00000011 ; je next  //
// 0 0 0 1 0 0 0 0  and 00001100 ; je next  //
// 0 0 1 0 1 0 0 0  and 00110100 ; je next  //
// 0 0 1 0 1 0 0 0  and 11000100 ; je next  // A
// 0 1 0 0 0 1 0 0  and 00110100 ; je next  //
// 0 1 1 1 1 1 0 0  and 00001100 ; je next  //
// 1 0 0 0 0 0 1 0  and 00000011 ; je next  //
// 1 0 0 0 0 0 1 0  and 00000000 ; je next  //

// learn
// ------- -------  
// 0 0 0 1 0 0 0 0  and ........ ; je next  //
// 0 0 0 1 0 0 0 0  and ........ ; je next  //
// 0 0 1 0 1 0 0 0  and ........ ; je next  //
// 0 0 1 0 1 0 0 0  and ........ ; je next  // A
// 0 1 0 0 0 1 0 0  and ........ ; je next  //
// 0 1 1 1 1 1 0 0  and ........ ; je next  //
// 1 0 0 0 0 0 1 0  and ........ ; je next  //
// 1 0 0 0 0 0 1 0  and ........ ; je next  //

//   1 1 1 1 1 1 1 0  // reduced up-down
// 1                  
// 1                  // reduced left-right
// 1
// 1
// 1
// 1
// 1
// 1
//
// fast compare 
//   reduced_ud == ideal
//   reduced_lr == ideal
//
// then full compare
//   8 iterations: and R, X; je next

//   1 // reduced up-down to bit
// 1   // reduced left-right to bit
//
// fast-fast compare 
//   reduced_ud_bit == 1
//   reduced_lr_bit == 1


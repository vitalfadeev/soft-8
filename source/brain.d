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

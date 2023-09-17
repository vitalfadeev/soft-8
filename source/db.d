module db;

// 9x9  -> 3x3  -> 1x1
//
// record
//   reduce record -> index
//     reduce record -> index
//       reduced       -> index
//
// index
//   index - reduced
//     index - reduced
//       record

// rec
// 1   A A   F F   H
// 2   A 
// 3   B B   F 
// 4   B   
// 5   C C   G G
// 6   C  
// 7   D D   G
// 8   D  
//
// 8 = 2^^3 
//   n_records = 2^^X
//   X indexes


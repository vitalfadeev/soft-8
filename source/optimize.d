module optimize;

// pooled -> non-pooled direct CPU instuctions
//           skip 
//             put in pool
//             pop from pool
//             select actions
//           keep
//             actions
//
//           able
//             1 memory allocation to heap

// 3 класса программ
//   слева      максивально гибкие
//   справа     максимально твердые
//   посередине гибко-твердые
//
// 3 programm classes
//  soft        // use pool
//  soft_hard   // use pool, use direct
//  hard        // use direct

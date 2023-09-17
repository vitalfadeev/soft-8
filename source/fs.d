module fs;

// fs
// file
//   header
//     name
//   data
//
// index
//   file_ptr

// fs
//   data         DISK[ LBA_address ] = data
//    header
//    bytes
//   index        
//     inode      (name, LBA_address)
//
// DIR/file
// .
//   index  (.,DIR)
// DIR
//   index  (.,file)
// file
//   header (.,name,ext,data_offset)
//   data

// file header
// ext,version  - 4 B        = 32 bit    // m8[3] ext, m8 version
// name         - 1..1+256 B =  8 bit... // m8,m8[0..255]
// cdate        - 4 B        = 32 bit    // m8   // create date
// wdate        - 4 B        = 32 bit    // m8   // last write/append/remove date
// odate        - 4 B        = 32 bit    // m8   // last open date
// ddate        - 4 B        = 32 bit    // m8   // delete date
// rwx          - 1 B        =  8 bit
//
// file1.bmp
// -------------------
// bmp,1
// 5,file1
// 1970/01/01 00:00:00
// 1970/01/01 00:00:00
// 1970/01/01 00:00:00
// 1970/01/01 00:00:00
// rwx

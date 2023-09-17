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

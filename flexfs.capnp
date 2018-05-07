@0xafa9e0aea8aaab32;

struct Attrs {
   ino @0 :UInt64;
   size @1 :UInt64;
   blocks @2 :UInt64;

   atime @3 :UInt64;
   mtime @4 :UInt64;
   ctime @5 :UInt64;
   atimensec @6 :UInt32;
   mtimensec @7 :UInt32;
   ctimensec @8 :UInt32;

   mode @9 :UInt32;

   nlink @10 :UInt32;

   uid @11 :UInt32;

   gid @12 :UInt32;

   rdev @13 :UInt32;
}

struct StatFs {
   blocks @0 :UInt64;

   bfree @1 :UInt64;

   bavail @2 :UInt64;

   files @3 :UInt64;

   ffree @4 :UInt64;

   bsize @5 :UInt32;

   namelen @6 :UInt32;

   frsize @7 :UInt32;
}

struct Cred {
   uid @0 :UInt32;

   gid @1 :UInt32;

   pid @2 :UInt32;
}

struct Error {
   errorCode @0 :UInt32;
}

struct SetAttrFlags {
   setMode @0 :Bool;
   setUid @1 :Bool;
   setGid @2 :Bool;
   setAtime @3 :Bool;
   setMtime @4 :Bool;
}

struct OpenFlags {
   append @0 :Bool;
   create @1 :Bool;
   excl @9 :Bool;
   noatime @2 :Bool;
   nofollow @3 :Bool;
   trunc @7 :Bool;

   readable @4 :Bool;
   writable @5 :Bool;

   sync @6 :Bool;

   mode @8 :UInt32;
}

interface Node {
   lookup @0 (cred :Cred, name :Text) -> (error :Error, node :Node, stat :Attrs);

   getAttr @1 (cred :Cred) -> (error :Error, attrs :Attrs);

   readlink @3 (cred :Cred) -> (error :Error, path :Text);

   statfs @13 (cred :Cred) -> (error :Error, statfs :StatFs);

   access @18 (cred :Cred) -> (error :Error);

   # Open a file.
   open @11 (cred :Cred, openFlags :OpenFlags) -> (error :Error, handle :FileHandle);

   # Read a directory.
   readdir @12 (cred :Cred) -> (error :Error, entries :List(DirEntry));

   # methods changing the filesystem:

   setAttr @2 (cred :Cred, flags :SetAttrFlags, attr :Attrs) -> (error :Error);

   symlink @4 (cred :Cred) -> (error :Error);

   mknod @5 (cred :Cred) -> (error :Error);

   create @19 (cred :Cred) -> (error :Error);

   mkdir @6 (cred :Cred) -> (error :Error);

   unlink @7 (cred :Cred) -> (error :Error);

   rmdir @8 (cred :Cred) -> (error :Error);

   rename @9 (cred :Cred, targetDir :Node, newName :Text) -> (error :Error);

   link @10 (cred :Cred, targetDir :Node, newName :Text) -> (error :Error);

   # xattr support
   setxattr @14 () -> (error :Error);

   getxattr @15 () -> (error :Error);

   listxattr @16 () -> (error :Error);

   removexattr @17 () -> (error :Error);

   #getlk @1 ();
   #setlk @1 ();
   #setlkw @2 ();
}

interface FileHandle {
   read @0 (cred :Cred, offset :UInt64, size :UInt64) -> (error :Error, data :Data);
   write @1 (cred :Cred, offset :UInt64, data :Data) -> (error :Error);
   fsync @2 (cred :Cred) -> (error :Error);
   flush @3 (cred :Cred) -> (error :Error);

   #release @15 ();
}

struct DirEntry {
   name @0 :Text;

   kind @1 :UInt8;
}

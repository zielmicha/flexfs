import capnp, capnp/gensupport, collections/iface

import reactor, caprpc, caprpc/rpcgensupport
# file: flexfs.capnp

type
  Attrs* = ref object
    ino*: uint64
    size*: uint64
    blocks*: uint64
    atime*: uint64
    mtime*: uint64
    ctime*: uint64
    atimensec*: uint32
    mtimensec*: uint32
    ctimensec*: uint32
    mode*: uint32
    nlink*: uint32
    uid*: uint32
    gid*: uint32
    rdev*: uint32

  StatFs* = ref object
    blocks*: uint64
    bfree*: uint64
    bavail*: uint64
    files*: uint64
    ffree*: uint64
    bsize*: uint32
    namelen*: uint32
    frsize*: uint32

  Cred* = ref object
    uid*: uint32
    gid*: uint32
    pid*: uint32

  Error* = ref object
    errorCode*: uint32

  SetAttrFlags* = ref object
    setMode*: bool
    setUid*: bool
    setGid*: bool
    setAtime*: bool
    setMtime*: bool

  OpenFlags* = ref object
    append*: bool
    create*: bool
    noatime*: bool
    nofollow*: bool
    readable*: bool
    writable*: bool
    sync*: bool
    trunc*: bool
    mode*: uint32
    excl*: bool

  Node* = distinct Interface
  Node_CallWrapper* = ref object of CapServerWrapper

  Node_lookup_Params* = ref object
    cred*: Cred
    name*: string

  Node_lookup_Result* = ref object
    error*: Error
    node*: Node
    stat*: Attrs

  Node_getAttr_Params* = ref object
    cred*: Cred

  Node_getAttr_Result* = ref object
    error*: Error
    attrs*: Attrs

  Node_setAttr_Params* = ref object
    cred*: Cred
    flags*: SetAttrFlags
    attr*: Attrs

  Node_setAttr_Result* = ref object
    error*: Error

  Node_readlink_Params* = ref object
    cred*: Cred

  Node_readlink_Result* = ref object
    error*: Error
    path*: string

  Node_symlink_Params* = ref object
    cred*: Cred

  Node_symlink_Result* = ref object
    error*: Error

  Node_mknod_Params* = ref object
    cred*: Cred

  Node_mknod_Result* = ref object
    error*: Error

  Node_mkdir_Params* = ref object
    cred*: Cred

  Node_mkdir_Result* = ref object
    error*: Error

  Node_unlink_Params* = ref object
    cred*: Cred

  Node_unlink_Result* = ref object
    error*: Error

  Node_rmdir_Params* = ref object
    cred*: Cred

  Node_rmdir_Result* = ref object
    error*: Error

  Node_rename_Params* = ref object
    cred*: Cred
    targetDir*: Node
    newName*: string

  Node_rename_Result* = ref object
    error*: Error

  Node_link_Params* = ref object
    cred*: Cred
    targetDir*: Node
    newName*: string

  Node_link_Result* = ref object
    error*: Error

  Node_open_Params* = ref object
    cred*: Cred
    openFlags*: OpenFlags

  Node_open_Result* = ref object
    error*: Error
    handle*: FileHandle

  Node_readdir_Params* = ref object
    cred*: Cred

  Node_readdir_Result* = ref object
    error*: Error
    entries*: seq[DirEntry]

  Node_statfs_Params* = ref object
    cred*: Cred

  Node_statfs_Result* = ref object
    error*: Error
    statfs*: StatFs

  Node_setxattr_Params* = ref object

  Node_setxattr_Result* = ref object
    error*: Error

  Node_getxattr_Params* = ref object

  Node_getxattr_Result* = ref object
    error*: Error

  Node_listxattr_Params* = ref object

  Node_listxattr_Result* = ref object
    error*: Error

  Node_removexattr_Params* = ref object

  Node_removexattr_Result* = ref object
    error*: Error

  Node_access_Params* = ref object
    cred*: Cred

  Node_access_Result* = ref object
    error*: Error

  Node_create_Params* = ref object
    cred*: Cred

  Node_create_Result* = ref object
    error*: Error

  FileHandle* = distinct Interface
  FileHandle_CallWrapper* = ref object of CapServerWrapper

  FileHandle_read_Params* = ref object
    cred*: Cred
    offset*: uint64
    size*: uint64

  FileHandle_read_Result* = ref object
    error*: Error
    data*: string

  FileHandle_write_Params* = ref object
    cred*: Cred
    offset*: uint64
    data*: string

  FileHandle_write_Result* = ref object
    error*: Error

  FileHandle_fsync_Params* = ref object
    cred*: Cred

  FileHandle_fsync_Result* = ref object
    error*: Error

  FileHandle_flush_Params* = ref object
    cred*: Cred

  FileHandle_flush_Result* = ref object
    error*: Error

  DirEntry* = ref object
    name*: string
    kind*: uint8



makeStructCoders(Attrs, [
  (ino, 0, 0, true),
  (size, 8, 0, true),
  (blocks, 16, 0, true),
  (atime, 24, 0, true),
  (mtime, 32, 0, true),
  (ctime, 40, 0, true),
  (atimensec, 48, 0, true),
  (mtimensec, 52, 0, true),
  (ctimensec, 56, 0, true),
  (mode, 60, 0, true),
  (nlink, 64, 0, true),
  (uid, 68, 0, true),
  (gid, 72, 0, true),
  (rdev, 76, 0, true)
  ], [], [])

makeStructCoders(StatFs, [
  (blocks, 0, 0, true),
  (bfree, 8, 0, true),
  (bavail, 16, 0, true),
  (files, 24, 0, true),
  (ffree, 32, 0, true),
  (bsize, 40, 0, true),
  (namelen, 44, 0, true),
  (frsize, 48, 0, true)
  ], [], [])

makeStructCoders(Cred, [
  (uid, 0, 0, true),
  (gid, 4, 0, true),
  (pid, 8, 0, true)
  ], [], [])

makeStructCoders(Error, [
  (errorCode, 0, 0, true)
  ], [], [])

makeStructCoders(SetAttrFlags, [], [], [
  (setMode, 0, false, true),
  (setUid, 1, false, true),
  (setGid, 2, false, true),
  (setAtime, 3, false, true),
  (setMtime, 4, false, true)
  ])

makeStructCoders(OpenFlags, [
  (mode, 4, 0, true)
  ], [], [
  (append, 0, false, true),
  (create, 1, false, true),
  (noatime, 2, false, true),
  (nofollow, 3, false, true),
  (readable, 4, false, true),
  (writable, 5, false, true),
  (sync, 6, false, true),
  (trunc, 7, false, true),
  (excl, 8, false, true)
  ])

interfaceMethods Node:
  toCapServer(): CapServer
  lookup(cred: Cred, name: string): Future[Node_lookup_Result]
  getAttr(cred: Cred): Future[Node_getAttr_Result]
  setAttr(cred: Cred, flags: SetAttrFlags, attr: Attrs): Future[Error]
  readlink(cred: Cred): Future[Node_readlink_Result]
  symlink(cred: Cred): Future[Error]
  mknod(cred: Cred): Future[Error]
  mkdir(cred: Cred): Future[Error]
  unlink(cred: Cred): Future[Error]
  rmdir(cred: Cred): Future[Error]
  rename(cred: Cred, targetDir: Node, newName: string): Future[Error]
  link(cred: Cred, targetDir: Node, newName: string): Future[Error]
  open(cred: Cred, openFlags: OpenFlags): Future[Node_open_Result]
  readdir(cred: Cred): Future[Node_readdir_Result]
  statfs(cred: Cred): Future[Node_statfs_Result]
  setxattr(): Future[Error]
  getxattr(): Future[Error]
  listxattr(): Future[Error]
  removexattr(): Future[Error]
  access(cred: Cred): Future[Error]
  create(cred: Cred): Future[Error]

proc lookup*(selfFut: Future[Node], cred: Cred, name: string): Future[Node_lookup_Result] =
  return selfFut.then((selfV) => selfV.lookup(cred, name))
proc getAttr*(selfFut: Future[Node], cred: Cred): Future[Node_getAttr_Result] =
  return selfFut.then((selfV) => selfV.getAttr(cred))
proc setAttr*(selfFut: Future[Node], cred: Cred, flags: SetAttrFlags, attr: Attrs): Future[Error] =
  return selfFut.then((selfV) => selfV.setAttr(cred, flags, attr))
proc readlink*(selfFut: Future[Node], cred: Cred): Future[Node_readlink_Result] =
  return selfFut.then((selfV) => selfV.readlink(cred))
proc symlink*(selfFut: Future[Node], cred: Cred): Future[Error] =
  return selfFut.then((selfV) => selfV.symlink(cred))
proc mknod*(selfFut: Future[Node], cred: Cred): Future[Error] =
  return selfFut.then((selfV) => selfV.mknod(cred))
proc mkdir*(selfFut: Future[Node], cred: Cred): Future[Error] =
  return selfFut.then((selfV) => selfV.mkdir(cred))
proc unlink*(selfFut: Future[Node], cred: Cred): Future[Error] =
  return selfFut.then((selfV) => selfV.unlink(cred))
proc rmdir*(selfFut: Future[Node], cred: Cred): Future[Error] =
  return selfFut.then((selfV) => selfV.rmdir(cred))
proc rename*(selfFut: Future[Node], cred: Cred, targetDir: Node, newName: string): Future[Error] =
  return selfFut.then((selfV) => selfV.rename(cred, targetDir, newName))
proc link*(selfFut: Future[Node], cred: Cred, targetDir: Node, newName: string): Future[Error] =
  return selfFut.then((selfV) => selfV.link(cred, targetDir, newName))
proc open*(selfFut: Future[Node], cred: Cred, openFlags: OpenFlags): Future[Node_open_Result] =
  return selfFut.then((selfV) => selfV.open(cred, openFlags))
proc readdir*(selfFut: Future[Node], cred: Cred): Future[Node_readdir_Result] =
  return selfFut.then((selfV) => selfV.readdir(cred))
proc statfs*(selfFut: Future[Node], cred: Cred): Future[Node_statfs_Result] =
  return selfFut.then((selfV) => selfV.statfs(cred))
proc setxattr*(selfFut: Future[Node], ): Future[Error] =
  return selfFut.then((selfV) => selfV.setxattr())
proc getxattr*(selfFut: Future[Node], ): Future[Error] =
  return selfFut.then((selfV) => selfV.getxattr())
proc listxattr*(selfFut: Future[Node], ): Future[Error] =
  return selfFut.then((selfV) => selfV.listxattr())
proc removexattr*(selfFut: Future[Node], ): Future[Error] =
  return selfFut.then((selfV) => selfV.removexattr())
proc access*(selfFut: Future[Node], cred: Cred): Future[Error] =
  return selfFut.then((selfV) => selfV.access(cred))
proc create*(selfFut: Future[Node], cred: Cred): Future[Error] =
  return selfFut.then((selfV) => selfV.create(cred))

proc getInterfaceId*(t: typedesc[Node]): uint64 = return 17595006542357360554'u64

template forwardDecl*(iftype: typedesc[Node], self, impltype): untyped {.dirty.} =
  proc lookup(self: impltype, cred: Cred, name: string): Future[Node_lookup_Result] {.async.}
  proc getAttr(self: impltype, cred: Cred): Future[Node_getAttr_Result] {.async.}
  proc setAttr(self: impltype, cred: Cred, flags: SetAttrFlags, attr: Attrs): Future[Error] {.async.}
  proc readlink(self: impltype, cred: Cred): Future[Node_readlink_Result] {.async.}
  proc symlink(self: impltype, cred: Cred): Future[Error] {.async.}
  proc mknod(self: impltype, cred: Cred): Future[Error] {.async.}
  proc mkdir(self: impltype, cred: Cred): Future[Error] {.async.}
  proc unlink(self: impltype, cred: Cred): Future[Error] {.async.}
  proc rmdir(self: impltype, cred: Cred): Future[Error] {.async.}
  proc rename(self: impltype, cred: Cred, targetDir: Node, newName: string): Future[Error] {.async.}
  proc link(self: impltype, cred: Cred, targetDir: Node, newName: string): Future[Error] {.async.}
  proc open(self: impltype, cred: Cred, openFlags: OpenFlags): Future[Node_open_Result] {.async.}
  proc readdir(self: impltype, cred: Cred): Future[Node_readdir_Result] {.async.}
  proc statfs(self: impltype, cred: Cred): Future[Node_statfs_Result] {.async.}
  proc setxattr(self: impltype, ): Future[Error] {.async.}
  proc getxattr(self: impltype, ): Future[Error] {.async.}
  proc listxattr(self: impltype, ): Future[Error] {.async.}
  proc removexattr(self: impltype, ): Future[Error] {.async.}
  proc access(self: impltype, cred: Cred): Future[Error] {.async.}
  proc create(self: impltype, cred: Cred): Future[Error] {.async.}

miscCapMethods(Node, Node_CallWrapper)

proc capCall*[T: Node](cap: T, id: uint64, args: AnyPointer): Future[AnyPointer] =
  case int(id):
    of 0:
      let argObj = args.castAs(Node_lookup_Params)
      let retVal = cap.lookup(argObj.cred, argObj.name)
      return retVal.toAnyPointerFuture
    of 1:
      let argObj = args.castAs(Node_getAttr_Params)
      let retVal = cap.getAttr(argObj.cred)
      return retVal.toAnyPointerFuture
    of 2:
      let argObj = args.castAs(Node_setAttr_Params)
      let retVal = cap.setAttr(argObj.cred, argObj.flags, argObj.attr)
      return wrapFutureInSinglePointer(Node_setAttr_Result, error, retVal)
    of 3:
      let argObj = args.castAs(Node_readlink_Params)
      let retVal = cap.readlink(argObj.cred)
      return retVal.toAnyPointerFuture
    of 4:
      let argObj = args.castAs(Node_symlink_Params)
      let retVal = cap.symlink(argObj.cred)
      return wrapFutureInSinglePointer(Node_symlink_Result, error, retVal)
    of 5:
      let argObj = args.castAs(Node_mknod_Params)
      let retVal = cap.mknod(argObj.cred)
      return wrapFutureInSinglePointer(Node_mknod_Result, error, retVal)
    of 6:
      let argObj = args.castAs(Node_mkdir_Params)
      let retVal = cap.mkdir(argObj.cred)
      return wrapFutureInSinglePointer(Node_mkdir_Result, error, retVal)
    of 7:
      let argObj = args.castAs(Node_unlink_Params)
      let retVal = cap.unlink(argObj.cred)
      return wrapFutureInSinglePointer(Node_unlink_Result, error, retVal)
    of 8:
      let argObj = args.castAs(Node_rmdir_Params)
      let retVal = cap.rmdir(argObj.cred)
      return wrapFutureInSinglePointer(Node_rmdir_Result, error, retVal)
    of 9:
      let argObj = args.castAs(Node_rename_Params)
      let retVal = cap.rename(argObj.cred, argObj.targetDir, argObj.newName)
      return wrapFutureInSinglePointer(Node_rename_Result, error, retVal)
    of 10:
      let argObj = args.castAs(Node_link_Params)
      let retVal = cap.link(argObj.cred, argObj.targetDir, argObj.newName)
      return wrapFutureInSinglePointer(Node_link_Result, error, retVal)
    of 11:
      let argObj = args.castAs(Node_open_Params)
      let retVal = cap.open(argObj.cred, argObj.openFlags)
      return retVal.toAnyPointerFuture
    of 12:
      let argObj = args.castAs(Node_readdir_Params)
      let retVal = cap.readdir(argObj.cred)
      return retVal.toAnyPointerFuture
    of 13:
      let argObj = args.castAs(Node_statfs_Params)
      let retVal = cap.statfs(argObj.cred)
      return retVal.toAnyPointerFuture
    of 14:
      let argObj = args.castAs(Node_setxattr_Params)
      let retVal = cap.setxattr()
      return wrapFutureInSinglePointer(Node_setxattr_Result, error, retVal)
    of 15:
      let argObj = args.castAs(Node_getxattr_Params)
      let retVal = cap.getxattr()
      return wrapFutureInSinglePointer(Node_getxattr_Result, error, retVal)
    of 16:
      let argObj = args.castAs(Node_listxattr_Params)
      let retVal = cap.listxattr()
      return wrapFutureInSinglePointer(Node_listxattr_Result, error, retVal)
    of 17:
      let argObj = args.castAs(Node_removexattr_Params)
      let retVal = cap.removexattr()
      return wrapFutureInSinglePointer(Node_removexattr_Result, error, retVal)
    of 18:
      let argObj = args.castAs(Node_access_Params)
      let retVal = cap.access(argObj.cred)
      return wrapFutureInSinglePointer(Node_access_Result, error, retVal)
    of 19:
      let argObj = args.castAs(Node_create_Params)
      let retVal = cap.create(argObj.cred)
      return wrapFutureInSinglePointer(Node_create_Result, error, retVal)
    else: raise newException(NotImplementedError, "not implemented")

proc getMethodId*(t: typedesc[Node_lookup_Params]): uint64 = 0'u64

proc lookup*[T: Node_CallWrapper](self: T, cred: Cred, name: string): Future[Node_lookup_Result] =
  return self.cap.call(17595006542357360554'u64, 0, toAnyPointer(Node_lookup_Params(cred: cred, name: name))).castAs(Node_lookup_Result)

proc getMethodId*(t: typedesc[Node_getAttr_Params]): uint64 = 1'u64

proc getAttr*[T: Node_CallWrapper](self: T, cred: Cred): Future[Node_getAttr_Result] =
  return self.cap.call(17595006542357360554'u64, 1, toAnyPointer(Node_getAttr_Params(cred: cred))).castAs(Node_getAttr_Result)

proc getMethodId*(t: typedesc[Node_setAttr_Params]): uint64 = 2'u64

proc setAttr*[T: Node_CallWrapper](self: T, cred: Cred, flags: SetAttrFlags, attr: Attrs): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 2, toAnyPointer(Node_setAttr_Params(cred: cred, flags: flags, attr: attr))).castAs(Node_setAttr_Result), error)

proc getMethodId*(t: typedesc[Node_readlink_Params]): uint64 = 3'u64

proc readlink*[T: Node_CallWrapper](self: T, cred: Cred): Future[Node_readlink_Result] =
  return self.cap.call(17595006542357360554'u64, 3, toAnyPointer(Node_readlink_Params(cred: cred))).castAs(Node_readlink_Result)

proc getMethodId*(t: typedesc[Node_symlink_Params]): uint64 = 4'u64

proc symlink*[T: Node_CallWrapper](self: T, cred: Cred): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 4, toAnyPointer(Node_symlink_Params(cred: cred))).castAs(Node_symlink_Result), error)

proc getMethodId*(t: typedesc[Node_mknod_Params]): uint64 = 5'u64

proc mknod*[T: Node_CallWrapper](self: T, cred: Cred): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 5, toAnyPointer(Node_mknod_Params(cred: cred))).castAs(Node_mknod_Result), error)

proc getMethodId*(t: typedesc[Node_mkdir_Params]): uint64 = 6'u64

proc mkdir*[T: Node_CallWrapper](self: T, cred: Cred): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 6, toAnyPointer(Node_mkdir_Params(cred: cred))).castAs(Node_mkdir_Result), error)

proc getMethodId*(t: typedesc[Node_unlink_Params]): uint64 = 7'u64

proc unlink*[T: Node_CallWrapper](self: T, cred: Cred): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 7, toAnyPointer(Node_unlink_Params(cred: cred))).castAs(Node_unlink_Result), error)

proc getMethodId*(t: typedesc[Node_rmdir_Params]): uint64 = 8'u64

proc rmdir*[T: Node_CallWrapper](self: T, cred: Cred): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 8, toAnyPointer(Node_rmdir_Params(cred: cred))).castAs(Node_rmdir_Result), error)

proc getMethodId*(t: typedesc[Node_rename_Params]): uint64 = 9'u64

proc rename*[T: Node_CallWrapper](self: T, cred: Cred, targetDir: Node, newName: string): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 9, toAnyPointer(Node_rename_Params(cred: cred, targetDir: targetDir, newName: newName))).castAs(Node_rename_Result), error)

proc getMethodId*(t: typedesc[Node_link_Params]): uint64 = 10'u64

proc link*[T: Node_CallWrapper](self: T, cred: Cred, targetDir: Node, newName: string): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 10, toAnyPointer(Node_link_Params(cred: cred, targetDir: targetDir, newName: newName))).castAs(Node_link_Result), error)

proc getMethodId*(t: typedesc[Node_open_Params]): uint64 = 11'u64

proc open*[T: Node_CallWrapper](self: T, cred: Cred, openFlags: OpenFlags): Future[Node_open_Result] =
  return self.cap.call(17595006542357360554'u64, 11, toAnyPointer(Node_open_Params(cred: cred, openFlags: openFlags))).castAs(Node_open_Result)

proc getMethodId*(t: typedesc[Node_readdir_Params]): uint64 = 12'u64

proc readdir*[T: Node_CallWrapper](self: T, cred: Cred): Future[Node_readdir_Result] =
  return self.cap.call(17595006542357360554'u64, 12, toAnyPointer(Node_readdir_Params(cred: cred))).castAs(Node_readdir_Result)

proc getMethodId*(t: typedesc[Node_statfs_Params]): uint64 = 13'u64

proc statfs*[T: Node_CallWrapper](self: T, cred: Cred): Future[Node_statfs_Result] =
  return self.cap.call(17595006542357360554'u64, 13, toAnyPointer(Node_statfs_Params(cred: cred))).castAs(Node_statfs_Result)

proc getMethodId*(t: typedesc[Node_setxattr_Params]): uint64 = 14'u64

proc setxattr*[T: Node_CallWrapper](self: T, ): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 14, toAnyPointer(Node_setxattr_Params())).castAs(Node_setxattr_Result), error)

proc getMethodId*(t: typedesc[Node_getxattr_Params]): uint64 = 15'u64

proc getxattr*[T: Node_CallWrapper](self: T, ): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 15, toAnyPointer(Node_getxattr_Params())).castAs(Node_getxattr_Result), error)

proc getMethodId*(t: typedesc[Node_listxattr_Params]): uint64 = 16'u64

proc listxattr*[T: Node_CallWrapper](self: T, ): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 16, toAnyPointer(Node_listxattr_Params())).castAs(Node_listxattr_Result), error)

proc getMethodId*(t: typedesc[Node_removexattr_Params]): uint64 = 17'u64

proc removexattr*[T: Node_CallWrapper](self: T, ): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 17, toAnyPointer(Node_removexattr_Params())).castAs(Node_removexattr_Result), error)

proc getMethodId*(t: typedesc[Node_access_Params]): uint64 = 18'u64

proc access*[T: Node_CallWrapper](self: T, cred: Cred): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 18, toAnyPointer(Node_access_Params(cred: cred))).castAs(Node_access_Result), error)

proc getMethodId*(t: typedesc[Node_create_Params]): uint64 = 19'u64

proc create*[T: Node_CallWrapper](self: T, cred: Cred): Future[Error] =
  return getFutureField(self.cap.call(17595006542357360554'u64, 19, toAnyPointer(Node_create_Params(cred: cred))).castAs(Node_create_Result), error)

makeStructCoders(Node_lookup_Params, [], [
  (cred, 0, PointerFlag.none, true),
  (name, 1, PointerFlag.text, true)
  ], [])

makeStructCoders(Node_lookup_Result, [], [
  (error, 0, PointerFlag.none, true),
  (node, 1, PointerFlag.none, true),
  (stat, 2, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_getAttr_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_getAttr_Result, [], [
  (error, 0, PointerFlag.none, true),
  (attrs, 1, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_setAttr_Params, [], [
  (cred, 0, PointerFlag.none, true),
  (flags, 1, PointerFlag.none, true),
  (attr, 2, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_setAttr_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_readlink_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_readlink_Result, [], [
  (error, 0, PointerFlag.none, true),
  (path, 1, PointerFlag.text, true)
  ], [])

makeStructCoders(Node_symlink_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_symlink_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_mknod_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_mknod_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_mkdir_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_mkdir_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_unlink_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_unlink_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_rmdir_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_rmdir_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_rename_Params, [], [
  (cred, 0, PointerFlag.none, true),
  (targetDir, 1, PointerFlag.none, true),
  (newName, 2, PointerFlag.text, true)
  ], [])

makeStructCoders(Node_rename_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_link_Params, [], [
  (cred, 0, PointerFlag.none, true),
  (targetDir, 1, PointerFlag.none, true),
  (newName, 2, PointerFlag.text, true)
  ], [])

makeStructCoders(Node_link_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_open_Params, [], [
  (cred, 0, PointerFlag.none, true),
  (openFlags, 1, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_open_Result, [], [
  (error, 0, PointerFlag.none, true),
  (handle, 1, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_readdir_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_readdir_Result, [], [
  (error, 0, PointerFlag.none, true),
  (entries, 1, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_statfs_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_statfs_Result, [], [
  (error, 0, PointerFlag.none, true),
  (statfs, 1, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_setxattr_Params, [], [], [])

makeStructCoders(Node_setxattr_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_getxattr_Params, [], [], [])

makeStructCoders(Node_getxattr_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_listxattr_Params, [], [], [])

makeStructCoders(Node_listxattr_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_removexattr_Params, [], [], [])

makeStructCoders(Node_removexattr_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_access_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_access_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_create_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(Node_create_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

interfaceMethods FileHandle:
  toCapServer(): CapServer
  read(cred: Cred, offset: uint64, size: uint64): Future[FileHandle_read_Result]
  write(cred: Cred, offset: uint64, data: string): Future[Error]
  fsync(cred: Cred): Future[Error]
  flush(cred: Cred): Future[Error]

proc read*(selfFut: Future[FileHandle], cred: Cred, offset: uint64, size: uint64): Future[FileHandle_read_Result] =
  return selfFut.then((selfV) => selfV.read(cred, offset, size))
proc write*(selfFut: Future[FileHandle], cred: Cred, offset: uint64, data: string): Future[Error] =
  return selfFut.then((selfV) => selfV.write(cred, offset, data))
proc fsync*(selfFut: Future[FileHandle], cred: Cred): Future[Error] =
  return selfFut.then((selfV) => selfV.fsync(cred))
proc flush*(selfFut: Future[FileHandle], cred: Cred): Future[Error] =
  return selfFut.then((selfV) => selfV.flush(cred))

proc getInterfaceId*(t: typedesc[FileHandle]): uint64 = return 14767779304721956413'u64

template forwardDecl*(iftype: typedesc[FileHandle], self, impltype): untyped {.dirty.} =
  proc read(self: impltype, cred: Cred, offset: uint64, size: uint64): Future[FileHandle_read_Result] {.async.}
  proc write(self: impltype, cred: Cred, offset: uint64, data: string): Future[Error] {.async.}
  proc fsync(self: impltype, cred: Cred): Future[Error] {.async.}
  proc flush(self: impltype, cred: Cred): Future[Error] {.async.}

miscCapMethods(FileHandle, FileHandle_CallWrapper)

proc capCall*[T: FileHandle](cap: T, id: uint64, args: AnyPointer): Future[AnyPointer] =
  case int(id):
    of 0:
      let argObj = args.castAs(FileHandle_read_Params)
      let retVal = cap.read(argObj.cred, argObj.offset, argObj.size)
      return retVal.toAnyPointerFuture
    of 1:
      let argObj = args.castAs(FileHandle_write_Params)
      let retVal = cap.write(argObj.cred, argObj.offset, argObj.data)
      return wrapFutureInSinglePointer(FileHandle_write_Result, error, retVal)
    of 2:
      let argObj = args.castAs(FileHandle_fsync_Params)
      let retVal = cap.fsync(argObj.cred)
      return wrapFutureInSinglePointer(FileHandle_fsync_Result, error, retVal)
    of 3:
      let argObj = args.castAs(FileHandle_flush_Params)
      let retVal = cap.flush(argObj.cred)
      return wrapFutureInSinglePointer(FileHandle_flush_Result, error, retVal)
    else: raise newException(NotImplementedError, "not implemented")

proc getMethodId*(t: typedesc[FileHandle_read_Params]): uint64 = 0'u64

proc read*[T: FileHandle_CallWrapper](self: T, cred: Cred, offset: uint64, size: uint64): Future[FileHandle_read_Result] =
  return self.cap.call(14767779304721956413'u64, 0, toAnyPointer(FileHandle_read_Params(cred: cred, offset: offset, size: size))).castAs(FileHandle_read_Result)

proc getMethodId*(t: typedesc[FileHandle_write_Params]): uint64 = 1'u64

proc write*[T: FileHandle_CallWrapper](self: T, cred: Cred, offset: uint64, data: string): Future[Error] =
  return getFutureField(self.cap.call(14767779304721956413'u64, 1, toAnyPointer(FileHandle_write_Params(cred: cred, offset: offset, data: data))).castAs(FileHandle_write_Result), error)

proc getMethodId*(t: typedesc[FileHandle_fsync_Params]): uint64 = 2'u64

proc fsync*[T: FileHandle_CallWrapper](self: T, cred: Cred): Future[Error] =
  return getFutureField(self.cap.call(14767779304721956413'u64, 2, toAnyPointer(FileHandle_fsync_Params(cred: cred))).castAs(FileHandle_fsync_Result), error)

proc getMethodId*(t: typedesc[FileHandle_flush_Params]): uint64 = 3'u64

proc flush*[T: FileHandle_CallWrapper](self: T, cred: Cred): Future[Error] =
  return getFutureField(self.cap.call(14767779304721956413'u64, 3, toAnyPointer(FileHandle_flush_Params(cred: cred))).castAs(FileHandle_flush_Result), error)

makeStructCoders(FileHandle_read_Params, [
  (offset, 0, 0, true),
  (size, 8, 0, true)
  ], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(FileHandle_read_Result, [], [
  (error, 0, PointerFlag.none, true),
  (data, 1, PointerFlag.none, true)
  ], [])

makeStructCoders(FileHandle_write_Params, [
  (offset, 0, 0, true)
  ], [
  (cred, 0, PointerFlag.none, true),
  (data, 1, PointerFlag.none, true)
  ], [])

makeStructCoders(FileHandle_write_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(FileHandle_fsync_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(FileHandle_fsync_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(FileHandle_flush_Params, [], [
  (cred, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(FileHandle_flush_Result, [], [
  (error, 0, PointerFlag.none, true)
  ], [])

makeStructCoders(DirEntry, [
  (kind, 0, 0, true)
  ], [
  (name, 0, PointerFlag.text, true)
  ], [])



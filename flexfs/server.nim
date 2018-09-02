import flexfs/schema, morelinux/fd, posix, reactor/threading, reactor, capnp, capnp/rpc, os, strutils, reactor/syscall

type
  Options = ref object
    readonly: bool
    root: bool

  NodeImpl = ref object of RootObj
    options: Options
    fd: FD

  FileHandleImpl = ref object of RootObj
    options: Options
    fd: FD

proc run[T](options: Options, cred: Cred, c: (proc(): Result[T])): Future[T] =
  proc wrapper(): Result[T] =
    let noneUid = Uid(0xFFFFFFFF'u32)

    if options.root:
      if setreuid(noneUid, Uid(cred.uid)) != 0:
        raiseOSError(osLastError())
      if setregid(noneUid, Uid(cred.gid)) != 0:
        raiseOSError(osLastError())

    defer:
      if options.root:
        if setreuid(noneUid, Uid(0)) != 0:
          raiseOSError(osLastError())
        if setregid(noneUid, Uid(0)) != 0:
          raiseOSError(osLastError())

    return c()

  return execInPool(wrapper)

proc splitPath(path: string): seq[string] =
  if '\0' in path: raise newException(OSError, "zero byte in name")
  if '\L' in path: raise newException(OSError, "newline in name")

  if path.len > 1024:
    raise newException(OSError, "path too long")

  if path.len == 0:
    raise newException(OSError, "empty path")

  if path.startswith("/"):
    raise newException(OSError, "invalid absolute path")

  let parts = path.split('/')
  var res: seq[string] = @[]
  for part in parts:
    if part == ".." or part == "." or part == "":
      raise newException(OSError, "invalid path segment")
    res.add part

  return res

proc openat(dirfd: cint, pathname: cstring, flags: cint, mode: cint): cint {.importc, header: "<fcntl.h>".}
var O_CLOEXEC {.importc, header: "<fcntl.h>"}: cint
var O_NOFOLLOW {.importc, header: "<fcntl.h>"}: cint
var O_PATH {.importc, header: "<fcntl.h>"}: cint
var O_NOATIME {.importc, header: "<fcntl.h>".}: cint
var O_DIRECTORY {.importc, header: "<fcntl.h>".}: cint

proc osError(): ref OSError =
  let errCode = osLastError()
  let exc = newException(OSError, osErrorMsg(errCode))
  exc.errorCode = int32(errCode)
  return exc

proc doLookup(root: cint, path: string): Result[cint] =
  let parts = splitPath(path)

  doAssert root >= 0

  var currFd: cint = dupCloexec(root)
  doAssert currFd >= 0
  for part in parts:
    let newFd = catchError(retrySyscall(openat(currFd, part, O_PATH or O_NOFOLLOW or O_CLOEXEC, 0o400)))
    if newFd.isError: return newFd
    discard close(currFd)
    currFd = newFd.get
    if currFd < 0:
      return error(cint, osError())

  return just(currFd)

proc statfd(fd: cint): Result[Attrs] =
  var statbuf: Stat
  let ret = fstat(fd, statbuf)
  if ret < 0:
    return error(Attrs, osError())

  var attrs = Attrs()
  attrs.ino = statbuf.st_ino
  attrs.size = uint64(statbuf.st_size)
  attrs.blocks = uint64(statbuf.st_blocks)
  attrs.atime = uint64(statbuf.st_atim.tv_sec)
  attrs.mtime = uint64(statbuf.st_mtim.tv_sec)
  attrs.ctime = uint64(statbuf.st_ctim.tv_sec)
  attrs.atimensec = uint32(statbuf.st_atim.tv_nsec)
  attrs.mtimensec = uint32(statbuf.st_mtim.tv_nsec)
  attrs.ctimensec = uint32(statbuf.st_ctim.tv_nsec)
  attrs.mode = uint32(statbuf.st_mode)
  attrs.nlink = uint32(statbuf.st_nlink)
  attrs.uid = statbuf.st_uid
  attrs.gid = statbuf.st_gid
  attrs.rdev = uint32(statbuf.st_rdev)

  return just(attrs)

proc makeError(ex: ref Exception): Error =
  let ex = ex.getOriginal
  if ex of OSError:
    return Error(errorCode: uint32((ref OSError)(ex).errorCode))
  else:
    raise ex

converter convertToIface*(obj: NodeImpl): Node
converter convertToIface*(obj: FileHandleImpl): schema.FileHandle

proc lookup(self: NodeImpl, cred: Cred, name: string): Future[Node_lookup_Result] {.async.} =
  let origFd = self.fd.get
  let res = tryAwait run(self.options, cred,
                         proc(): Result[tuple[fd: cint, stat: Attrs]] =
                           let ret = doLookup(origFd, name)
                           echo "lookup ret ", ret
                           if ret.isError:
                             return error(tuple[fd: cint, stat: Attrs], ret.error)
                           let fd = ret.get
                           let stat = statfd(fd)
                           if stat.isError:
                             discard close(fd)
                             return error(tuple[fd: cint, stat: Attrs], ret.error)
                           return just[tuple[fd: cint, stat: Attrs]]((fd, stat.get)))

  if res.isError:
    return Node_lookup_Result(error: makeError(res.error))

  let (fd, attrs) = res.get
  return Node_lookup_Result(node: NodeImpl(options: self.options, fd: wrapFd(fd)), stat: attrs)

proc getAttr(self: NodeImpl, cred: Cred): Future[Node_getAttr_Result] {.async.} =
  let origFd = self.fd.get
  let res = tryAwait run(self.options, cred, () => statfd(origFd))
  if res.isError: return Node_getAttr_Result(error: makeError(res.error))
  return Node_getAttr_Result(attrs: res.get)

proc readlinkat(dirfd: cint, pathname: cstring, buf: cstring, bufsiz: csize): int {.importc, header: "<fcntl.h>".}

proc doReadlink(fd: cint): Result[string] =
  var buf = newString(1024)
  let len = readlinkat(fd, "", buf, buf.len)
  if len < 0:
    return error(string, osError())
  return just(buf[0..<len])

proc readlink(self: NodeImpl, cred: Cred): Future[Node_readlink_Result] {.async.} =
  let origFd = self.fd.get
  let res = tryAwait run(self.options, cred, () => statfd(origFd))
  if res.isError: return Node_readlink_Result(error: makeError(res.error))

proc readonlyError(): Error =
  return Error(errorCode: uint32(EROFS))

proc setAttr(self: NodeImpl, cred: Cred, flags: SetAttrFlags, attr: Attrs): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc symlink(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc mknod(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc mkdir(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc unlink(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc rmdir(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc rename(self: NodeImpl, cred: Cred, targetDir: Node, newName: string): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc link(self: NodeImpl, cred: Cred, targetDir: Node, newName: string): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc makeFlags(flags: OpenFlags): cint =
  result = 0
  if flags.append: result = result or O_APPEND
  if flags.create: result = result or O_CREAT
  if flags.excl: result = result or O_EXCL
  if flags.noatime: result = result or O_NOATIME
  if flags.nofollow: result = result or O_NOFOLLOW
  if flags.readable and flags.writable: result = result or O_RDWR
  else:
    if flags.readable: result = result or O_RDONLY
    if flags.writable: result = result or O_WRONLY
  if flags.sync: result = result or O_SYNC

proc open(self: NodeImpl, cred: Cred, openFlags: OpenFlags): Future[Node_open_Result] {.async.} =
  if self.options.readonly:
    if openFlags.append or openFlags.create or openFlags.writable:
      return Node_open_Result(error: readonlyError())

  let flags = makeFlags(openFlags)
  let mode = cint(openFlags.mode)
  let origFd = self.fd.get

  let res = tryAwait run(self.options, cred,
                         proc(): Result[cint] =
                           let ret = openat(origFd, "", flags, mode)
                           if ret < 0: return error(cint, osError())
                           return just(ret))

  if res.isError: return Node_open_Result(error: makeError(res.error))
  return Node_open_Result(handle: FileHandleImpl(fd: wrapFd(res.get)))

proc fdopendir(fd: int): ptr DIR {.importc, header: "<dirent.h>".}

proc listDir(fd: cint): Result[seq[DirEntry]] =
  var d = opendir("/proc/self/fd/" & $fd)
  if d == nil:
    return error(seq[DirEntry], osError())

  defer: discard closedir(d)

  var entries: seq[DirEntry] = @[]
  while true:
    let ent = readdir(d)
    if ent == nil:
      break
    let name = $(cstring(addr ent.d_name))

    if name == "." or name == "..":
      continue

    entries.add(DirEntry(name: name, kind: ent.d_type.uint8))

  return just(entries)

proc readdir(self: NodeImpl, cred: Cred): Future[Node_readdir_Result] {.async.} =
  let origFd = self.fd.get
  let res = tryAwait run(self.options, cred, () => listDir(origFd))

  if res.isError: return Node_readdir_Result(error: makeError(res.error))

  return Node_readdir_Result(entries: res.get)

proc statfs(self: NodeImpl, cred: Cred): Future[Node_statfs_Result] {.async.} =
  discard

proc setxattr(self: NodeImpl): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc getxattr(self: NodeImpl): Future[Error] {.async.} =
  discard

proc listxattr(self: NodeImpl): Future[Error] {.async.} =
  discard

proc removexattr(self: NodeImpl): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc access(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  discard

proc create(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc read(self: FileHandleImpl, cred: Cred, offset: uint64, size: uint64): Future[FileHandle_read_Result] {.async.} =
  discard

proc write(self: FileHandleImpl, cred: Cred, offset: uint64, data: string): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc fsync(self: FileHandleImpl, cred: Cred): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

proc flush(self: FileHandleImpl, cred: Cred): Future[Error] {.async.} =
  if self.options.readonly: return readonlyError()

capServerImpl(NodeImpl, [Node])
capServerImpl(FileHandleImpl, [schema.FileHandle])

proc makeNode*(path: string, options=Options(root: false, readonly: false)): Future[Node] {.async.} =
  echo "node: ", path
  let fd = retrySyscall(open(path, O_PATH or O_NOFOLLOW or O_CLOEXEC, 0o400))
  if fd < 0:
    raise osError()
  return NodeImpl(options: options, fd: wrapFd(fd)).asNode

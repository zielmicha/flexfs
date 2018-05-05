import morelinux/fd, posix

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

proc run(options: Options, cred: Cred, c: proc()): Future[void] =
  proc wrapper() =
    if options.root:
      if setreuid(-1, cred.uid) != 0:
        raiseOSError(osLastError())
      if setregid(-1, cred.gid) != 0:
        raiseOSError(osLastError())

    defer;
      if options.root:
        if setreuid(-1, 0) != 0:
          raiseOSError(osLastError())
        if setregid(-1, 0) != 0:
          raiseOSError(osLastError())

    c()

proc doLookup(root: cint, name: string): cint {.async.} =
  discard

proc lookup(self: NodeImpl, cred: Cred, name: string): Future[Error] {.async.} =
  discard

proc getAttr(self: NodeImpl, cred: Cred): Future[Node_getAttr_Result] {.async.} =
  discard

proc setAttr(self: NodeImpl, cred: Cred, flags: SetAttrFlags, attr: Attrs): Future[Error] {.async.} =
  discard

proc readlink(self: NodeImpl, cred: Cred): Future[Node_readlink_Result] {.async.} =
  discard

proc readonlyError(): Error =
  return Error(errno: EROFS)

proc symlink(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  if self.options.readonly:
    return readonlyError()



proc mknod(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  discard

proc mkdir(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  discard

proc unlink(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  discard

proc rmdir(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  discard

proc rename(self: NodeImpl, cred: Cred, targetDir: Node, newName: string): Future[Error] {.async.} =
  discard

proc link(self: NodeImpl, cred: Cred, targetDir: Node, newName: string): Future[Error] {.async.} =
  discard

proc open(self: NodeImpl, cred: Cred, openFlags: OpenFlags): Future[Node_open_Result] {.async.} =
  discard

proc opendir(self: NodeImpl, cred: Cred): Future[Node_opendir_Result] {.async.} =
  discard

proc statfs(self: NodeImpl, cred: Cred): Future[Node_statfs_Result] {.async.} =
  discard

proc setxattr(self: NodeImpl, ): Future[Error] {.async.} =
  discard

proc getxattr(self: NodeImpl, ): Future[Error] {.async.} =
  discard

proc listxattr(self: NodeImpl, ): Future[Error] {.async.} =
  discard

proc removexattr(self: NodeImpl, ): Future[Error] {.async.} =
  discard

proc access(self: NodeImpl, cred: Cred): Future[Error] {.async.} =
  discard

proc create(self: NodeImpl, cred: Cred): Future[Error] {.async.}
  discard

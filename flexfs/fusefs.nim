import reactor, reactorfuse, collections, posix, flexfs/schema

type
  FuseServer = ref object
    nodes: Table[NodeId, Node]
    nodeCounter: NodeId
    handles: Table[HandleId, schema.FileHandle]
    dirListings: Table[HandleId, string]
    handleCounter: HandleId
    conn: FuseConnection

{.this: self.}

template handleError(error) =
  if error != nil and error.errorCode != 0:
    await conn.respondError(msg, error.errorCode.cint)
    asyncReturn
    # good catch! 'return' here won't be transformed by async macro causing 2-hour long debugging

var O_NOATIME {.importc, header: "<fcntl.h>"}: cint
var O_NOFOLLOW {.importc, header: "<fcntl.h>"}: cint

proc makeOpenFlags(flags: uint32, mode: uint32): OpenFlags =
  let flags = cint(flags)

  if (flags and O_APPEND) != 0:
    result.append = true

  if (flags and O_CREAT) != 0:
    result.create = true

  if (flags and O_NOATIME) != 0:
    result.noatime = true

  if (flags and O_NOFOLLOW) != 0:
    result.nofollow = true

  if (flags and O_TRUNC) != 0:
    result.trunc = true

  if (flags and O_WRONLY) != 0:
    result.writable = true

  if (flags and O_RDONLY) != 0:
    result.readable = true

  if (flags and O_RDWR) != 0:
    result.readable = true
    result.writable = true

  if (flags and O_SYNC) != 0:
     result.sync = true

  if (flags and O_EXCL) != 0:
     result.excl = true

  result.mode = mode

proc rpcToFuse(attrs: Attrs): Attributes =
  # converts from RPC Attrs to FUSE Attributes
  result.ino = attrs.ino
  result.size = attrs.size
  result.blocks = attrs.blocks
  result.atime = attrs.atime
  result.mtime = attrs.mtime
  result.ctime = attrs.ctime
  result.atimensec = attrs.atimensec
  result.mtimensec = attrs.mtimensec
  result.ctimensec = attrs.ctimensec
  result.mode = attrs.mode
  result.nlink = attrs.nlink
  result.uid = attrs.uid
  result.gid = attrs.gid
  result.rdev = attrs.rdev

proc handleRequest(self: FuseServer, msg: reactorfuse.Request) {.async.} =
  echo "recv ", msg.pprint

  let cred = Cred(uid: msg.uid, gid: msg.gid)

  if msg.nodeID notin nodes:
    stderr.writeLine "node doesn't exist"
    await conn.respondError(msg, ESTALE)
    return

  let node = nodes[msg.nodeID]

  if msg.kind == fuseLookup:
    let resp = await node.lookup(cred, msg.lookupName)

    handleError(resp.error)

    let newId = nodeCounter
    nodeCounter += 1
    nodes[newId] = resp.node

    await conn.respondToLookup(msg, newId, resp.stat.rpcToFuse)
  elif msg.kind == fuseGetAttr:
    let resp = await node.getAttr(cred)
    handleError(resp.error)

    await conn.respondToGetAttr(msg, resp.attrs.rpcToFuse)
  elif msg.kind == fuseOpen:
    if msg.isDir:
      let resp = await node.readdir(cred)
      handleError(resp.error)

      var listing = ""
      for entry in resp.entries:
        appendDirent(listing,
                     name=entry.name, # TODO: kind=...
                     inode=BadInode)

      handleCounter += 1
      dirListings[handleCounter] = listing
    else:
      let resp = await node.open(cred, makeOpenFlags(msg.flags, msg.mode))
      handleError(resp.error)

      handleCounter += 1
      handles[handleCounter] = resp.handle

    await conn.respondToOpen(msg, handleCounter)

  elif msg.kind == fuseRead:
    if msg.isDir:
      await conn.respondToReadAll(msg, dirListings[msg.fileHandle])
    else:
      let handle = handles[msg.fileHandle]

      await conn.respondError(msg, ENOSYS)

  elif msg.kind == fuseForget:
    discard #nodes.del

  else:
    await conn.respondError(msg, ENOSYS)

proc mount*(path: string, root: Node) {.async.} =
  let conn = await reactorfuse.mount(path, ())

  let self = FuseServer(conn: conn)
  initTable(self.nodes)
  initTable(self.handles)
  initTable(self.dirListings)
  self.nodes[1] = root
  self.nodeCounter = 2

  while true:
    # TODO: do everything async
    let msg = await conn.requests.receive()
    let resp = tryAwait handleRequest(self, msg)
    if resp.isError:
      resp.error.printError
      if msg.kind != fuseForget:
        await conn.respondError(msg, posix.EIO) # assume error doesn't happen in respondXXX

when isMainModule:
  import flexfs/server, os

  proc main() {.async.} =
    let node = await makeNode(paramStr(1))
    await mount(paramStr(2), node)

  main().runMain

import reactor, reactorfuse, collection, posix

type
  FuseServer = ref object
    nodes: Table[NodeId, Node]
    nodeCounter: NodeId
    handles: Table[HandleId, FileHandle]
    handleCounter: HandleId

template handleError(error) =
  if error != nil and error.errno != 0:
    await conn.respondError(msg, error.errno)

proc makeOpenFlags(flags: uint32, mode: uint32): OpenFlags =
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

  if (flags and O_SYNC) != 0
     result.sync = true

  if (flags and O_EXCL) != 0
     result.excl = true

  result.mode = mode

proc handleRequest(server: FuseServer, msg: reactorfuse.Request) {.async.} =
  echo "recv ", msg.pprint

  let cred = Cred(uid: msg.uid, gid: msg.gid)

  if msg.nodeID notin server.nodes:
    stderr.writeLine "node doesn't exist"
    await conn.respondError(msg, ESTALE)

  let node = server.nodes[msg.nodeID]

  if msg.kind == fuseLookup:
    let resp = await node.lookup(cred, msg.lookupName)

    handleError(resp.error)

    let newId = nodeCounter
    nodeCounter += 1
    server.nodes[newId] = resp.newNode
    await conn.respondToLookup(msg, newId, resp.stat)

  elif msg.kind == fuseGetAttr:
    let resp = await node.getAttr(cred)
    handleError(resp.error)

    await conn.respondToGetAttr(msg, resp.stat)

  elif msg.kind == fuseOpen:
    let resp = await node.open(cred, makeOpenFlags(msg.flags, msg.mode))
    handleCounter += 1
    await conn.respondToOpen(msg, handleCounter)

  elif msg.kind == fuseRead:
    discard

  elif msg.kind == fuseForget:
    nodes.del

  else:
    await conn.respondError(msg, ENOSYS)

proc mount*(path: string, root: Node) {.async.} =
  let conn = await mount(path, ())

  let server = FuseServer()
  initTable(server.nodes)
  server.nodes[1] = root
  server.nodeCounter = 2

  while true:
    let msg = await conn.requests.receive()
    let resp = tryAwait handleRequest(fuseServer, msg)
    if resp.isError:
      resp.error.printError
      if msg.kind != fuseForget:
        await conn.respondError(msg, EIO) # assume error doesn't happen in respondXXX

when isMainModule:
  proc

version       = "0.1.0"
author        = "Michał Zieliński <michal@zielinscy.org.pl>"
description   = "Fast and compatible network filesystem (FUSE protocol over network)"
license       = "MIT"
skipDirs      = @["bench", "examples", "tests", "doc"]

requires "nim >= 0.17.0"
requires "collections >= 0.5.0"
requires "reactorfuse >= 0.5.0"
requires "reactor >= 0.5.0"

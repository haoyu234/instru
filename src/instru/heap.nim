import macros

type
  InstruHeap* = object
    len: int
    top: ptr InstruHeapNode
    lessThan: proc (a, b: var InstruHeapNode): bool

  InstruHeapNode* = object
    left: ptr InstruHeapNode
    right: ptr InstruHeapNode
    parent: ptr InstruHeapNode

template len*(h: InstruHeap): int = h.len
template top*(h: InstruHeap): ptr InstruHeapNode = h.top
template isEmpty*(h: InstruHeap): bool = isNil(h.top)
template isEmpty*(h: InstruHeapNode): bool = isNil(h.parent) and isNil(
    h.left) and isNil(h.right)

proc initEmpty*(h: var InstruHeap, lessThan: proc (a,
    b: var InstruHeapNode): bool) =
  h.len = 0
  h.top = nil
  h.lessThan = lessThan

template initEmpty*(h: var InstruHeapNode) =
  reset(h)

proc swap(h: var InstruHeap, a, b: var InstruHeapNode) =
  swap(a, b)

  a.parent = b.addr

  var sibling = block:
    if b.left == b.addr:
      b.left = a.addr
      b.right
    else:
      b.right = a.addr
      b.left

  if not isNil(sibling):
    sibling[].parent = b.addr

  if not isNil(a.left):
    a.left.parent = a.addr

  if not isNil(a.right):
    a.right.parent = a.addr

  if isNil(b.parent):
    h.top = b.addr
  elif b.parent.left == a.addr:
    b.parent.left = b.addr
  else:
    b.parent.right = b.addr

proc traverse(h: var InstruHeap, n: int): (ptr ptr InstruHeapNode,
    ptr ptr InstruHeapNode) =
  var k = uint32(0)
  var path = uint32(0)

  var num = uint32(n)
  while num >= 2:
    path = (path shl 1) or (num and 0x1)
    num = num shr 1
    inc k

  var c = h.top.addr
  var p = h.top.addr

  while k > 0:
    p = c
    if (path and 0x1) > 0:
      c = c[].right.addr
    else:
      c = c[].left.addr

    path = path shr 1
    dec k

  (p, c)

template shiftUp(h: var InstruHeap, n: var InstruHeapNode) =
  let lessThan = h.lessThan

  while not isNil(n.parent) and lessThan(n, n.parent[]):
    swap(h, n.parent[], n)

proc insert*(h: var InstruHeap, n: var InstruHeapNode) =
  reset(n)

  let (p, c) = traverse(h, succ h.len)

  n.parent = p[]
  c[] = n.addr

  inc h.len

  shiftUp(h, n)

proc remove*(h: var InstruHeap, n: var InstruHeapNode) =
  var c = block:
    var (_, c) = traverse(h, h.len)
    var result = c[]
    c[] = nil
    result

  dec h.len

  if c == n.addr:
    if c == h.top:
      h.top = nil
    return

  c[] = n

  if not isNil(c.left):
    c.left.parent = c

  if not isNil(c.right):
    c.right.parent = c

  if isNil(n.parent):
    h.top = c
  elif n.parent.left == n.addr:
    n.parent.left = c
  else:
    n.parent.right = c

  let lessThan = h.lessThan

  while true:
    var s = c

    if not isNil(c.left) and lessThan(c.left[], s[]):
      s = c.left

    if not isNil(c.right) and lessThan(c.right[], s[]):
      s = c.right

    if s != c:
      swap(h, c[], s[])
      continue

    break

  shiftUp(h, c[])

template popTop*(h: var InstruHeap): ptr InstruHeapNode =
  let n = h.top
  remove(h, h.top[])
  n

template data*[T](h: var InstruHeapNode, a: typedesc[T], b: untyped): ptr T =
  containerOf(h.addr, a, b)

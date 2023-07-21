import macros

type
  InstruHeap* = object
    nelts: uint32
    top: ptr InstruHeapNode
    lessThan: proc (a, b: var InstruHeapNode): bool

  InstruHeapNode* = object
    left: ptr InstruHeapNode
    right: ptr InstruHeapNode
    parent: ptr InstruHeapNode

proc isEmpty*(h: var InstruHeap): bool =
  h.top == nil

proc initEmpty*(h: var InstruHeap, lessThan: proc (a,
    b: var InstruHeapNode): bool) =
  h.top = nil
  h.nelts = 0
  h.lessThan = lessThan

proc initEmpty*(h: var InstruHeapNode) =
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

  if sibling != nil:
    sibling[].parent = b.addr

  if a.left != nil:
    a.left.parent = a.addr

  if a.right != nil:
    a.right.parent = a.addr

  if b.parent == nil:
    h.top = b.addr
  elif b.parent.left == a.addr:
    b.parent.left = b.addr
  else:
    b.parent.right = b.addr

proc traverse(h: var InstruHeap, n: uint32): (ptr ptr InstruHeapNode,
    ptr ptr InstruHeapNode) =
  var k = uint32(0)
  var path = uint32(0)

  var num = n
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

proc shiftUp(h: var InstruHeap, n: var InstruHeapNode) =
  while n.parent != nil and h.lessThan(n, n.parent[]):
    swap(h, n.parent[], n)

proc insert*(h: var InstruHeap, n: var InstruHeapNode) =
  reset(n)

  let (p, c) = traverse(h, succ h.nelts)

  n.parent = p[]
  c[] = n.addr

  inc h.nelts

  shiftUp(h, n)

proc remove*(h: var InstruHeap, n: var InstruHeapNode) =
  var c = block:
    var (_, c) = traverse(h, h.nelts)
    var result = c[]
    c[] = nil
    result

  dec h.nelts

  if c == n.addr:
    if c == h.top:
      h.top = nil
    return

  c[] = n

  if c.left != nil:
    c.left.parent = c

  if c.right != nil:
    c.right.parent = c

  if n.parent == nil:
    h.top = c
  elif n.parent.left == n.addr:
    n.parent.left = c
  else:
    n.parent.right = c

  while true:
    var s = c

    if c.left != nil and h.lessThan(c.left[], s[]):
      s = c.left

    if c.right != nil and h.lessThan(c.right[], s[]):
      s = c.right

    if s != c:
      swap(h, c[], s[])
      continue

    break

  shiftUp(h, c[])

proc dequeue*(h: var InstruHeap): ptr InstruHeapNode =
  let n = h.top
  remove(h, h.top[])
  n

template data*[T](h: var InstruHeapNode, a: typedesc[T], b: untyped): ptr T =
  containerOf(h.addr, a, b)

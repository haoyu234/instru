import macros

type
  InstruQueueNode* = object
    previous*: ptr InstruQueueNode
    next*: ptr InstruQueueNode

  InstruQueue* = object
    node*: InstruQueueNode

proc isEmpty*(h: var InstruQueue): bool =
  h.addr == h.node.next

proc initEmpty*(h: var InstruQueue) =
  h.node.next = h.node.addr
  h.node.previous = h.node.addr

proc initEmpty*(h: var InstruQueueNode) =
  h.next = h.addr
  h.previous = h.addr

proc insertFront*(h: var InstruQueue, n: var InstruQueueNode) =
  n.next = h.node.next
  n.previous = h.node.addr
  n.next.previous = n.addr
  h.node.next = n.addr

proc insertBack*(h: var InstruQueue, n: var InstruQueueNode) =
  n.next = h.node.addr
  n.previous = h.node.previous
  n.previous.next = n.addr
  h.node.previous = n.addr

proc mergeInto*(h, n: var InstruQueue) =
  h.node.previous.next = n.node.next
  n.node.next.previous = h.node.previous
  h.node.previous = n.node.previous
  h.node.previous.next = h.node.addr

  initEmpty(n)

proc remove*(h: var InstruQueueNode) =
  h.previous.next = h.next
  h.next.previous = h.previous

proc popFront*(h: var InstruQueue): ptr InstruQueueNode =
  let n = h.node.next
  remove(n[])
  n

proc popBack*(h: var InstruQueue): ptr InstruQueueNode =
  let n = h.node.previous
  remove(n[])
  n

iterator items*(h: var InstruQueue): ptr InstruQueueNode =
  var i = h.node.next
  let q = h.node.addr

  while i != q:
    let n = i.next
    yield i
    i = n

iterator items*(h: InstruQueue): ptr InstruQueueNode =
  var i = h.node.next
  let q = i.previous

  while i != q:
    let n = i.next
    yield i
    i = n

template data*[T](h: var InstruQueueNode, a: typedesc[T], b: untyped): ptr T =
  containerOf(h.addr, a, b)

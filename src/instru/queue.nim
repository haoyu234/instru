import macros

type
  InstruQueueNode* = object
    previous: ptr InstruQueueNode
    next: ptr InstruQueueNode

  # InstruQueue* = object
  #   node: InstruQueueNode

  InstruQueue* = distinct InstruQueueNode

template node(h: InstruQueue): var InstruQueueNode = InstruQueueNode(h)

template next*(h: InstruQueue): ptr InstruQueueNode = h.node.next
template previous*(h: InstruQueue): ptr InstruQueueNode = h.node.previous
template next*(h: InstruQueueNode): ptr InstruQueueNode = h.next
template previous*(h: InstruQueueNode): ptr InstruQueueNode = h.previous

template isEmpty*(h: var InstruQueue): bool =
  h.addr == h.node.next

template initEmpty*(h: var InstruQueue) =
  h.node.next = h.node.addr
  h.node.previous = h.node.addr

template initEmpty*(h: var InstruQueueNode) =
  h.next = h.addr
  h.previous = h.addr

template insertFront*(h, n: var InstruQueueNode) =
  n.next = h.next
  n.previous = h.addr
  n.next.previous = n.addr
  h.next = n.addr

template insertFront*(h: var InstruQueue, n: var InstruQueueNode) =
  n.next = h.node.next
  n.previous = h.node.addr
  n.next.previous = n.addr
  h.node.next = n.addr

template insertBack*(h, n: var InstruQueueNode) =
  n.next = h.addr
  n.previous = h.previous
  n.previous.next = n.addr
  h.previous = n.addr

template insertBack*(h: var InstruQueue, n: var InstruQueueNode) =
  n.next = h.node.addr
  n.previous = h.node.previous
  n.previous.next = n.addr
  h.node.previous = n.addr

template mergeInto*(h, n: var InstruQueue) =
  n.node.previous.next = h.node.next
  h.node.next.previous = n.node.previous
  n.node.previous = h.node.previous
  n.node.previous.next = n.node.addr

  initEmpty(h)

template moveInto*(h, n: var InstruQueue) =
  if h.isEmpty():
    n.initEmpty()
  else:
    let q = h.node.next
    n.node.previous = h.node.previous
    n.node.previous.next = n.node.addr
    n.node.next = q
    h.node.previous = q.previous
    h.node.previous.next = h.node.addr
    q.previous = n.node.addr

template remove*(h: var InstruQueueNode) =
  h.previous.next = h.next
  h.next.previous = h.previous

template popFront*(h: var InstruQueue): ptr InstruQueueNode =
  let n = h.node.next
  remove(n[])
  n

template popBack*(h: var InstruQueue): ptr InstruQueueNode =
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

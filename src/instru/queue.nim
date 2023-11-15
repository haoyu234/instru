import macros

type
  InstruQueueNode* = object
    previous: ptr InstruQueueNode
    next: ptr InstruQueueNode

  InstruQueue* = distinct InstruQueueNode

template next*(h: InstruQueueNode): ptr InstruQueueNode = h.next
template previous*(h: InstruQueueNode): ptr InstruQueueNode = h.previous

template head*(h: InstruQueue): ptr InstruQueueNode =
  InstruQueueNode(h).next

template isEmpty*(h: var InstruQueue): bool =
  h.addr == InstruQueueNode(h).next

template isEmpty*(h: var InstruQueueNode): bool =
  h.addr == h.next

template initEmpty*(h: var InstruQueue) =
  InstruQueueNode(h).next = InstruQueueNode(h).addr
  InstruQueueNode(h).previous = InstruQueueNode(h).addr

template initEmpty*(h: var InstruQueueNode) =
  h.next = h.addr
  h.previous = h.addr

template insertFront*(h, n: var InstruQueueNode) =
  n.next = h.next
  n.previous = h.addr
  n.next.previous = n.addr
  h.next = n.addr

template insertFront*(h: var InstruQueue, n: var InstruQueueNode) =
  n.next = InstruQueueNode(h).next
  n.previous = InstruQueueNode(h).addr
  n.next.previous = n.addr
  InstruQueueNode(h).next = n.addr

template insertBack*(h, n: var InstruQueueNode) =
  n.next = h.addr
  n.previous = h.previous
  n.previous.next = n.addr
  h.previous = n.addr

template insertBack*(h: var InstruQueue, n: var InstruQueueNode) =
  n.next = InstruQueueNode(h).addr
  n.previous = InstruQueueNode(h).previous
  n.previous.next = n.addr
  InstruQueueNode(h).previous = n.addr

template mergeInto*(h, n: var InstruQueue) =
  InstruQueueNode(n).previous.next = InstruQueueNode(h).next
  InstruQueueNode(h).next.previous = InstruQueueNode(n).previous
  InstruQueueNode(n).previous = InstruQueueNode(h).previous
  InstruQueueNode(n).previous.next = InstruQueueNode(n).addr

  initEmpty(h)

template moveInto*(h, n: var InstruQueue) =
  if h.isEmpty():
    n.initEmpty()
  else:
    let q = InstruQueueNode(h).next
    InstruQueueNode(n).previous = InstruQueueNode(h).previous
    InstruQueueNode(n).previous.next = InstruQueueNode(n).addr
    InstruQueueNode(n).next = q
    InstruQueueNode(h).previous = q.previous
    InstruQueueNode(h).previous.next = InstruQueueNode(h).addr
    q.previous = InstruQueueNode(n).addr

template remove*(h: var InstruQueueNode) =
  h.previous.next = h.next
  h.next.previous = h.previous

template popFront*(h: var InstruQueue): ptr InstruQueueNode =
  let n = InstruQueueNode(h).next
  remove(n[])
  n

template popBack*(h: var InstruQueue): ptr InstruQueueNode =
  let n = InstruQueueNode(h).previous
  remove(n[])
  n

iterator items*(h: var InstruQueue): ptr InstruQueueNode =
  var i = InstruQueueNode(h).next
  let q = InstruQueueNode(h).addr

  while i != q:
    let n = i.next
    yield i
    i = n

iterator items*(h: InstruQueue): ptr InstruQueueNode =
  var i = InstruQueueNode(h).next
  let q = i.previous

  while i != q:
    let n = i.next
    yield i
    i = n

template data*[T](h: var InstruQueueNode, a: typedesc[T], b: untyped): ptr T =
  containerOf(h.addr, a, b)

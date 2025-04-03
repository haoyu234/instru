type
  InstruQueueNode* = object
    previous: ptr InstruQueueNode
    next: ptr InstruQueueNode

  InstruQueue* = distinct InstruQueueNode

template next*(h: InstruQueueNode): ptr InstruQueueNode =
  h.next

template previous*(h: InstruQueueNode): ptr InstruQueueNode =
  h.previous

template head*(h: InstruQueue): ptr InstruQueueNode =
  InstruQueueNode(h).next

template isEmpty*(h: var InstruQueueNode): bool =
  h.next.isNil or h.addr == h.next

template isEmpty*(h: var InstruQueue): bool =
  InstruQueueNode(h).isEmpty()

proc initEmpty*(h: var InstruQueue) {.inline.} =
  InstruQueueNode(h).next = InstruQueueNode(h).addr
  InstruQueueNode(h).previous = InstruQueueNode(h).addr

proc initEmpty*(h: var InstruQueueNode) {.inline.} =
  h.next = h.addr
  h.previous = h.addr

proc insertFront*(h: var InstruQueue, n: var InstruQueueNode) {.inline.} =
  assert n.isEmpty

  n.next = InstruQueueNode(h).next
  n.previous = InstruQueueNode(h).addr
  n.next.previous = n.addr
  InstruQueueNode(h).next = n.addr

proc insertBack*(h: var InstruQueue, n: var InstruQueueNode) {.inline.} =
  assert n.isEmpty

  n.next = InstruQueueNode(h).addr
  n.previous = InstruQueueNode(h).previous
  n.previous.next = n.addr
  InstruQueueNode(h).previous = n.addr

proc mergeInto*(h, n: var InstruQueue) {.inline.} =
  InstruQueueNode(n).previous.next = InstruQueueNode(h).next
  InstruQueueNode(h).next.previous = InstruQueueNode(n).previous
  InstruQueueNode(n).previous = InstruQueueNode(h).previous
  InstruQueueNode(n).previous.next = InstruQueueNode(n).addr

  initEmpty(h)

proc moveInto*(h, n: var InstruQueue) {.inline.} =
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

proc remove*(h: var InstruQueueNode) {.inline.} =
  assert not h.isEmpty

  h.previous.next = h.next
  h.next.previous = h.previous
  h.initEmpty

proc popFront*(h: var InstruQueue): ptr InstruQueueNode {.inline.} =
  let n = InstruQueueNode(h).next
  remove(n[])
  n

proc popBack*(h: var InstruQueue): ptr InstruQueueNode {.inline.} =
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

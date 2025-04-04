type
  InstruQueueNode* = object
    prev: ptr InstruQueueNode
    next: ptr InstruQueueNode

  InstruQueue* {.borrow: `.`.} = distinct InstruQueueNode

template head*(h: InstruQueue): ptr InstruQueueNode =
  h.next

template next*(h: InstruQueueNode): ptr InstruQueueNode =
  h.next

template prev*(h: InstruQueueNode): ptr InstruQueueNode =
  h.prev

template isEmpty*(h: var InstruQueue): bool =
  InstruQueueNode(h).isEmpty()

template isEmpty*(h: var InstruQueueNode): bool =
  h.next.isNil or h.addr == h.next

proc initEmpty*(h: var InstruQueue) {.inline.} =
  h.next = InstruQueueNode(h).addr
  h.prev = InstruQueueNode(h).addr

proc initEmpty*(h: var InstruQueueNode) {.inline.} =
  h.next = h.addr
  h.prev = h.addr

proc insertFront*(h: var InstruQueue, n: var InstruQueueNode) {.inline.} =
  assert n.isEmpty

  n.next = h.next
  n.prev = InstruQueueNode(h).addr
  n.next.prev = n.addr
  h.next = n.addr

proc insertBack*(h: var InstruQueue, n: var InstruQueueNode) {.inline.} =
  assert n.isEmpty

  n.next = InstruQueueNode(h).addr
  n.prev = h.prev
  n.prev.next = n.addr
  h.prev = n.addr

proc mergeInto*(h, n: var InstruQueue) {.inline.} =
  n.prev.next = h.next
  h.next.prev = n.prev
  n.prev = h.prev
  n.prev.next = InstruQueueNode(n).addr

  initEmpty(h)

proc moveInto*(h, n: var InstruQueue) {.inline.} =
  if h.isEmpty():
    n.initEmpty()
  else:
    let q = h.next
    n.prev = h.prev
    n.prev.next = InstruQueueNode(n).addr
    InstruQueueNode(n).next = q
    h.prev = q.prev
    h.prev.next = InstruQueueNode(h).addr
    q.prev = InstruQueueNode(n).addr

proc remove*(h: var InstruQueueNode) {.inline.} =
  assert not h.isEmpty

  h.prev.next = h.next
  h.next.prev = h.prev
  h.initEmpty

proc popFront*(h: var InstruQueue): ptr InstruQueueNode {.inline.} =
  let n = h.next
  remove(n[])
  n

proc popBack*(h: var InstruQueue): ptr InstruQueueNode {.inline.} =
  let n = h.prev
  remove(n[])
  n

iterator items*(h: var InstruQueue): ptr InstruQueueNode =
  var i = h.next
  let q = InstruQueueNode(h).addr

  while i != q:
    let n = i.next
    yield i
    i = n

iterator items*(h: InstruQueue): ptr InstruQueueNode =
  var i = h.next
  let q = i.prev

  while i != q:
    let n = i.next
    yield i
    i = n

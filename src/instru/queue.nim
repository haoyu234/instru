import macros

type
  InstruQueueNode* = object
    previous: ptr InstruQueueNode
    next: ptr InstruQueueNode

  InstruQueue* = distinct InstruQueueNode

proc next*(h: InstruQueueNode): ptr InstruQueueNode {.inline.} = h.next
proc previous*(h: InstruQueueNode): ptr InstruQueueNode {.inline.} = h.previous
proc head*(h: InstruQueue): ptr InstruQueueNode {.inline.} = InstruQueueNode(h).next

proc isEmpty*(h: var InstruQueueNode): bool {.inline.} =
  h.next.isNil or h.addr == h.next

proc isEmpty*(h: var InstruQueue): bool {.inline.} =
  InstruQueueNode(h).isEmpty()

proc isQueued*(h: var InstruQueueNode): bool {.inline.} =
  not h.isEmpty

proc initEmpty*(h: var InstruQueue) {.inline.} =
  InstruQueueNode(h).next = InstruQueueNode(h).addr
  InstruQueueNode(h).previous = InstruQueueNode(h).addr

proc initEmpty*(h: var InstruQueueNode) {.inline.} =
  h.next = h.addr
  h.previous = h.addr

proc insertFront*(h, n: var InstruQueueNode) {.inline.} =
  assert not n.isQueued

  n.next = h.next
  n.previous = h.addr
  n.next.previous = n.addr
  h.next = n.addr

proc insertFront*(h: var InstruQueue, n: var InstruQueueNode) {.inline.} =
  assert not n.isQueued

  n.next = InstruQueueNode(h).next
  n.previous = InstruQueueNode(h).addr
  n.next.previous = n.addr
  InstruQueueNode(h).next = n.addr

proc insertBack*(h, n: var InstruQueueNode) {.inline.} =
  assert not n.isQueued

  n.next = h.addr
  n.previous = h.previous
  n.previous.next = n.addr
  h.previous = n.addr

proc insertBack*(h: var InstruQueue, n: var InstruQueueNode) {.inline.} =
  assert not n.isQueued

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
  assert h.isQueued

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

template data*[T](h: var InstruQueueNode, a: typedesc[T], b: untyped): ptr T =
  containerOf(h.addr, a, b)

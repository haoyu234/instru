import macros

type
  InstruQueue* = object
    prev: ptr InstruQueue
    next: ptr InstruQueue

proc isEmpty*(h: var InstruQueue): bool =
  h.addr == h.next

proc initEmpty*(h: var InstruQueue) =
  h.next = h.addr
  h.prev = h.addr

proc insertHead*(h, n: var InstruQueue) =
  n.next = h.next
  n.prev = h.addr
  n.next.prev = n.addr
  h.next = n.addr

proc insertTail*(h, n: var InstruQueue) =
  n.next = h.addr
  n.prev = h.prev
  n.prev.next = n.addr
  h.prev = n.addr

proc merge*(h, n: var InstruQueue) =
  h.prev.next = n.next
  n.next.prev = h.prev
  h.prev = n.prev
  h.prev.next = h.addr

  initEmpty(n)

proc detach*(h: var InstruQueue) =
  h.prev.next = h.next
  h.next.prev = h.prev

iterator items*(h: var InstruQueue): var InstruQueue =
  let q = h.addr
  var i = q.next

  while i != q:
    let n = i.next
    yield i[]
    i = n

template data*[T](h: var InstruQueue, a: typedesc[T], b: untyped): ptr T =
  containerOf(h.addr, a, b)

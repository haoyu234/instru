import macros

type
  InstruQueue* = object
    previous*: ptr InstruQueue
    next*: ptr InstruQueue

proc isEmpty*(h: var InstruQueue): bool =
  h.addr == h.next

proc initEmpty*(h: var InstruQueue) =
  h.next = h.addr
  h.previous = h.addr

proc insertHead*(h, n: var InstruQueue) =
  n.next = h.next
  n.previous = h.addr
  n.next.previous = n.addr
  h.next = n.addr

proc insertTail*(h, n: var InstruQueue) =
  n.next = h.addr
  n.previous = h.previous
  n.previous.next = n.addr
  h.previous = n.addr

proc mergeInto*(h, n: var InstruQueue) =
  h.previous.next = n.next
  n.next.previous = h.previous
  h.previous = n.previous
  h.previous.next = h.addr

  initEmpty(n)

proc remove*(h: var InstruQueue) =
  h.previous.next = h.next
  h.next.previous = h.previous

proc popFront*(h: var InstruQueue): ptr InstruQueue =
  if not isEmpty(h):
    let n = h.next
    remove(n[])
    return n
  return nil

proc popBack*(h: var InstruQueue): ptr InstruQueue =
  if not isEmpty(h):
    let n = h.previous
    remove(n[])
    return n
  return nil

iterator items*(h: var InstruQueue): ptr InstruQueue =
  let q = h.addr
  var i = q.next

  while i != q:
    let n = i.next
    yield i
    i = n

iterator items*(h: InstruQueue): ptr InstruQueue =
  let q = h.previous.next
  var i = q.next

  while i != q:
    let n = i.next
    yield i
    i = n

template data*[T](h: var InstruQueue, a: typedesc[T], b: untyped): ptr T =
  containerOf(h.addr, a, b)

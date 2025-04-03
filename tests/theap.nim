# To run these tests, simply execute `nimble test`.

import unittest

import instru/heap
import instru/macros

import std/random

type Job = object
  priority: int
  executeJob: proc()
  instruHeap: InstruHeapNode

proc insertJob(h: var InstruHeap, j: ptr Job) =
  initEmpty(j.instruHeap)
  insert(h, j.instruHeap)

template newJob(id: int, body: untyped): ptr Job =
  let p = create(Job)
  block:
    p.priority = id
    p.executeJob = proc() =
      body
    p

proc initHeap(h: var InstruHeap) =
  initEmpty(
    h,
    proc(a, b: var InstruHeapNode): bool =
      let aa = containerOf(a.addr, Job, instruHeap)
      let bb = containerOf(b.addr, Job, instruHeap)
      aa.priority < bb.priority
  )

test "insert":
  var h = InstruHeap()
  initHeap(h)

  let ids = [5, 32, 12, 54, 67, 9]
  for i in ids:
    let job = newJob(i):
      discard "body"

    insertJob(h, job)

test "isEmpty":
  var h = InstruHeap()
  initHeap(h)

  let job = newJob(1):
    discard "body"

  check job.instruHeap.isEmpty()
  check h.isEmpty()

  h.insertJob(job)

  check not job.instruHeap.isEmpty()
  check not h.isEmpty()

test "isEmpty 2":
  var h = InstruHeap()
  initHeap(h)

  check h.isEmpty

  const n = 30

  let round = proc() =
    for i in countup(1, n):
      let job = newJob(i):
        discard "body"

      insertJob(h, job)

      check not h.isEmpty

    for i in countup(1, n):
      check not h.isEmpty

      var p = pop(h)
      let j = containerOf(p, Job, instruHeap)
      dealloc(j)

    check h.isEmpty

  for i in countup(1, n):
    round()

test "orderly":
  var h = InstruHeap()
  initHeap(h)

  var r = initRand()
  let n = int(r.rand(1000))

  for i in countup(1, n):
    let n = int(r.rand(1000)) + 1
    let job = newJob(n):
      discard "body"

    insertJob(h, job)

  var min = 0

  for i in countup(1, n):
    var n = pop(h)
    let j = containerOf(n, Job, instruHeap)

    check min <= j.priority
    min = j.priority

    dealloc(j)

test "len":
  var h = InstruHeap()
  initHeap(h)

  check h.len == 0

  var len = 0
  var r = initRand()

  for i in countup(1, 1000):
    if len > 0 and r.rand(1) > 0:
      dec len

      var n = pop(h)
      let j = containerOf(n, Job, instruHeap)
      dealloc(j)
    else:
      inc len

      let job = newJob(i):
        discard "body"

      insertJob(h, job)

    check h.len == len

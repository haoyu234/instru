# To run these tests, simply execute `nimble test`.

import unittest

import std/sugar
import instru/queue
import instru/macros

type
  Job = object
    executeJob: proc ()
    instruQueue: InstruQueueNode

proc insertJob(q: var InstruQueue, j: ptr Job) =
  initEmpty(j.instruQueue)
  insertBack(q, j.instruQueue)

template newJob(body: untyped): ptr Job =
  new(Job):
    executeJob = proc () =
      body

proc freeQueue(q: var InstruQueue) =
  for i in q:
    let j = data(i[], Job, instruQueue)
    dealloc(j)

test "isEmpty":
  var q = default(InstruQueue)
  initEmpty(q)

  check q.isEmpty

  let job = newJob():
    discard "body"

  insertJob(q, job)

  check not q.isEmpty

  remove(job.instruQueue)
  dealloc(job)

  check q.isEmpty

test "containerOf":
  var job = newJob():
    discard "body"

  var addr1 = cast[pointer](job)
  var addr2 = containerOf(job.instruQueue.addr, Job, instruQueue)

  check addr1 == addr2

test "items":
  var n = 0
  const num = 100

  var q = default(InstruQueue)
  initEmpty(q)

  for i in 1..num:
    insertJob(q):
      newJob():
        n = n + 1

  for i in q:
    var j = data(i[], Job, instruQueue)
    j.executeJob()

  check n == num

  freeQueue(q)

test "mergeInto":
  var n = 0

  var q1 = default(InstruQueue)
  var q2 = default(InstruQueue)
  var q3 = default(InstruQueue)
  initEmpty(q1)
  initEmpty(q2)
  initEmpty(q3)

  for i in 1..5:
    insertJob(q1):
      newJob():
        n = n + 1

    insertJob(q2):
      newJob():
        n = n * 2

    insertJob(q3):
      newJob():
        n = n - 3

  mergeInto(q2, q1)
  mergeInto(q3, q1)

  for i in q1:
    var j = data(i[], Job, instruQueue)
    j.executeJob()

  check n == 145

  freeQueue(q1)
  freeQueue(q2)
  freeQueue(q3)

test "moveInto":
  var n = 0

  var q1 = default(InstruQueue)
  var q2 = default(InstruQueue)
  var q3 = default(InstruQueue)

  initEmpty(q1)
  initEmpty(q2)
  initEmpty(q3)

  for i in 1..5:
    insertJob(q1):
      newJob():
        n = n + 1

  proc sum(q: InstruQueue): int =
    n = 0

    for i in q:
      var j = data(i[], Job, instruQueue)
      j.executeJob()

    result = n

  let n1 = sum(q1)
  check n1 == 5

  q1.moveInto(q2)
  let n2 = sum(q2)
  check n2 == 5

  q2.moveInto(q3)
  let n3 = sum(q3)
  check n3 == 5

  freeQueue(q1)
  freeQueue(q2)
  freeQueue(q3)

test "popFront/popBack":
  var q = default(InstruQueue)
  initEmpty(q)

  var s = 0

  for i in 1..3:
    insertJob(q):
      capture i:
        newJob():
          s = i

  # popBack

  var n = popBack(q)
  check n != nil

  var j = data(n[], Job, instruQueue)
  j.executeJob()
  dealloc(j)

  check s == 3

  # popFront

  n = popFront(q)
  check n != nil

  j = data(n[], Job, instruQueue)
  j.executeJob()
  dealloc(j)

  check s == 1

  # There's one element left.

  check not isEmpty(q)
  check popFront(q) != nil
  check isEmpty(q)

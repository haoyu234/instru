# To run these tests, simply execute `nimble test`.

import unittest

import instru/queue
import instru/macros

type
  Job = object
    executeJob: proc ()
    instruQueue: InstruQueue

proc insertJob(q: var InstruQueue, j: ptr Job) =
  initEmpty(j.instruQueue)
  insertTail(q, j.instruQueue)

template newJob(body: untyped): ptr Job =
  new(Job):
    executeJob = proc () =
      body

test "isEmpty":
  var q = InstruQueue()
  initEmpty(q)

  check q.isEmpty

  let job = newJob():
    discard "body"

  insertJob(q, job)

  check not q.isEmpty

  detach(job.instruQueue)
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

  var q = InstruQueue()
  initEmpty(q)

  for i in 1..num:
    insertJob(q):
      newJob():
        n = n + 1

  for i in q:
    detach(i)

    var j = data(i, Job, instruQueue)
    j.executeJob()
    dealloc(j)

  check n == num

test "merge":
  var n = 0
  
  var q1 = InstruQueue()
  var q2 = InstruQueue()
  var q3 = InstruQueue()
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

  merge(q1, q2)
  merge(q1, q3)

  for i in q1:
    detach(i)

    var j = data(i, Job, instruQueue)
    j.executeJob()
    dealloc(j)

  check n == 145

import std/with
import std/macros

macro new*[T](a: typedesc[T], body: untyped): ptr T =
  result = quote do:
    var p = cast[ptr `a`](alloc0(sizeof(`a`)))
    with p:
      `body`
    p

macro containerOf*(p: pointer, a: typedesc, b: untyped): untyped =
  let pt = newNimNode(nnkPtrTy).add(a)

  result = quote do:
    let
      offset = offsetof(`a`, `b`)
      base = cast[uint](`p`) - cast[uint](offset)
    cast[`pt`](base)

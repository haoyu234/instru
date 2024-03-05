import std/with
import std/macros

macro new*[T](a: typedesc[T], body: untyped): ptr T =
  result = quote:
    var p = cast[ptr `a`](alloc0(sizeof(`a`)))
    with p:
      `body`
    p

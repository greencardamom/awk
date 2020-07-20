import unittest
include awk


suite "match: return values":
  test "match: return value for a match":
    check(match("a", "a") == 1)
  test "match: return value for a non-match":
    check(match("a", "b") == 0)

suite "match: string match loading":

  test "match: string into undeclared identifier":
    match("a b c", "[ ]b[ ]", id1)
    check(id1 == " b ")

  test "match: string into declared identifier":
    var id2 = "z"
    match("a b c", "[ ]b[ ]", id2)
    check(id2 == " b ")

  test "match: string into declared expression":

    type
      MyObj = object
        id: string
    var stuff: MyObj

    match("a b c", "[ ]b[ ]", stuff.id)
    check(stuff.id == " b ")
    


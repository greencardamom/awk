import unittest
include awk

suite "split: spliting":

  test "split: undeclared identifier":
    awksplit.split("a b c", k, "[ ][b]{1}[ ]")
    check(k[0] == "a")

  test "split: declared identifier":
    var j = newSeq[string](0)
    awksplit.split("a b c", j, "[ ]b?[ ]")
    check(j[0] == "a")

  test "split: declared expression":
    type
      MyObj = object
        id: seq[string]
    var stuff: MyObj
    awksplit.split("a b c", stuff.id, " .*?[ ]")
    check(stuff.id[1] == "c")

suite "split: return values":

  test "split: found split":
    var c = awksplit.split("a b c", m, "[ ]")
    check(c == 3)
    check(m.len == 3)

  test "split: not found split":
    var c = awksplit.split("a b c", m, "z")
    check(c == 0)
    check(m.len == 0)


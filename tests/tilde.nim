import unittest
include awk

suite "tilde: string contains":
  test "tilde: string contains (plain text target)":
    var s = "this is a string"
    check(s ~ "is a" == true)
  test "tilde: string contains (regex target)":
    var s = "this is a string"
    check(s ~ "i.?[ ]a" == true)

suite "tilde: string not contains":
  test "tilde: string not contains (plain text target)":
    var s = "this is a string"
    check(s !~ "Is a" == true)
  test "tilde: string not contains (regex target)":
    var s = "this is a string"
    check(s !~ "I.?[ ]a" == true)


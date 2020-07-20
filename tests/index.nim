import unittest
include awk

suite "substr: substr":

  test "index: find index":
    var str = "This is a string"
    check( index(str, "is") == 2)

  test "index: find index (none)":
    var str = "This is a string"
    check( index(str, "z") == -1)


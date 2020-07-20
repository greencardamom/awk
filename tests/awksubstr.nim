import unittest
include awk

suite "substr: substr":

  test "substr: from x to end of source":
    var str = "This is a string"
    check( awksubstr.substr(str, 5) == "is a string")

  test "substr: from x to y number of characters":
    var str = "This is a string"
    check( awksubstr.substr(str, 5, 2) == "is")

suite "substr: return values":

  test "substr: start is -1":
    var str = "This is a string"
    check( awksubstr.substr(str, -1) == "This is a string")

  test "substr: start is > length of source":
    var str = "This is a string"
    check( awksubstr.substr(str, 50, 2) == "")

  test "substr: length is -1":
    var str = "This is a string"
    check( awksubstr.substr(str, 0, -1) == "")

  test "substr: length is > source length":
    var str = "This is a string"
    check( awksubstr.substr(str, 0, 50) == "This is a string")


import unittest
include awk

suite "sub: subing":

  test "sub: first occurance in-place":
    var str = "This is a string"
    check( sub("[ ]is[ ]", " or ", str) == "This or a string")
    check( str == "This or a string")

  test "sub: first occurance out of place":
    check( sub("[ ]is[ ]", " or ", "This is a string")  == "This or a string")

  test "sub: second occurance in-place":
    var str = "This is a string"
    check( sub("s", "x", str, 2) == "This ix a string")              
    check( str == "This ix a string")

  test "sub: second occurance out of place":
    check( sub("s", "x", "This is a string", 2)  == "This ix a string")

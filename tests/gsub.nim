import unittest
include awk

suite "gsub: gsubing":

  test "gsub: in place":
    var str = "this is is string"
    gsub("[ ]is.*?st", " is a st", str)
    check(str == "this is a string")

  test "gsub: not in place":
    check( gsub("[ ]is.*?st", " is a st", "this is is string") == "this is a string" )


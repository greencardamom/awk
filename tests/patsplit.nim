import unittest
include awk

suite "patsplit: patspliting":

  test "patsplit: basic patsplit":
    var str = "This is <!--comment1--> a string <!--comment2--> with comments."
    var field = newSeq[string](0)
    var c = patsplit(str, field, "<[ ]{0,}[!].*?>")
    check(c == 2)
    check(field[0] == "<!--comment1-->")    
    check(field[1] == "<!--comment2-->")    

  test "patsplit: extended patsplit":
    var str = "This is <!--comment1--> a string <!--comment2--> with comments."
    var field = newSeq[string](0)
    var sep = newSeq[string](0)
    var c = patsplit(str, field, "<[ ]{0,}[!].*?>", sep)
    check(c == 2)
    check(field[0] == "<!--comment1-->")    
    check(field[1] == "<!--comment2-->")    
    check(sep[0] == "This is ")    
    check(sep[1] == " a string ")    
    check(sep[2] == " with comments.")    
     

suite "patsplit: unpatspliting":
   
  test "patsplit: unpatsplit":
    var str = "This is <!--comment1--> a string <!--comment2--> with comments."
    var field = newSeq[string](0)
    var sep = newSeq[string](0)
    patsplit(str, field, "<[ ]{0,}[!].*?>", sep)
    check(unpatsplit(field, sep) == "This is <!--comment1--> a string <!--comment2--> with comments.")

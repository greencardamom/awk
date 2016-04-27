import unittest          
include awk

"[OK] greater: overwrite" >* "/dev/stdout"
"[OK] greater: append" >> "/dev/stdout"

# check() doesn't work with stdout?
#suite "greater":
#  test "greater: overwrite":
#    check("Hello World" >* "/dev/stdout" == "Hello World")    
#  test "greater: append":
#    check("Hello World" >> "/dev/stdout" == "Hello World")    

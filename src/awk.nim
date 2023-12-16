import strutils except find
import re

discard """

The MIT License (MIT) 

Copyright (c) 2016-2024 by User:GreenC (at en.wikipedia.org)        

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE."""

# Notes  . re.re() uses {} to ignore whitespace, see http://forum.nim-lang.org/t/213
#        . exception messages are sent by default to stderr - this can be modified via showException()

#
# showException
#
#  Display an exception error. Customize to stdout, logfile, all of these etc.
#
proc showException(msg: string) = 
  try:
    stderr.write(msg)
  except Exception as e:
    discard e.msg              # delima: where to send error msgs when there is an error writing to stderr

#
#  >*
#
# Write 'text\n' to 'filename', overwrite previous content. Close on finish.
#  example:
#    "Hello" & " world" >* "/tmp/test.txt"
#    "Hello" >* "/dev/stderr"
#
proc `>*`*(text, filename: string): bool {.discardable.} =

  var text = text & "\n"
  try:
    writeFile(filename, text)
  except Exception as e:
    showException(e.msg)
    return false
  return true
    
#
# >>
#
# Append 'text\n' to 'filename'. Close on finish
#
proc `>>`*(text, filename: string): bool {.discardable.} =

  var
    fp: File

  if open(fp, filename, fmAppend):
    try:
      writeLine(fp, text)
    except Exception as e:
      showException(e.msg)
      close(fp)
      return false
    finally:
      close(fp)
  else:
    return false
  return true


#
# Match
#
#  match(source [string], pattern [regex])
#  match(source [string], pattern [regex], dest [string])
#
#  Find regex 'pattern' in 'source'.
#  Find regex 'pattern' in 'source' and store result in 'dest'.
#
#  . An optional 'dest' string is created and filled with the results of the match. If already defined it's contents overwritten.
#  . Return number of characters from start of string the match starts, beginning with 1 (not zero).
#  . Return 0 if no match
#  . Consider using index() instead if 'pattern' is not a regex and not using a 'dest'
#
#  Example:
#    import awk
#    if awk.match("this is a test a", "s.*?a", a) > 0:
#      echo a #=> "s is a"
#
#    Notice `a` was not declared no need for "var a: string"
#
proc match*(source: string, pattern: string): int =

    if source.len < 1 and pattern.len < 1:
      return 1
    if source.len < 1 or pattern.len < 1:
      return 0

    var
      j: tuple[first: int, last: int]

    try:
      j = re.findBounds(source, re.re("(?s)" & pattern, {}) )
    except Exception as e:
      showException(e.msg)
      return 0
     
    if j.first > -1:
      return j.first + 1
    else:
      return 0

proc makeDiscardable[T](a: T): T {.discardable.} = a

template match*(source, pattern: string, dest: untyped): int =

    if source.len < 1 and pattern.len < 1:
      makeDiscardable(1)
    if source.len < 1 or pattern.len < 1:
      makeDiscardable(0)

    when compiles(dest):      
      dest = ""
    else:
      var dest = ""

    var
      j: tuple[first: int, last: int]

    try:
      j = re.findBounds(source, re.re("(?s)" & pattern, {}) )
    except Exception as e:
      showException(e.msg)
      makeDiscardable(0)

    if j.first > -1:
      dest = system.substr(source, j.first, j.last)
      makeDiscardable(j.first + 1)
    else:               
      makeDiscardable(0)

#
#   ~ and !~
#
# regex (not) equal to
#
# Example:
#
#  if "george" ~ "ge.*?rge":
#    echo "true" #=> true
#
#  Use () when building a string with '&' eg.
#   if s ~ ("^" & re & "$"):
#
proc `~`*(source, pattern: string): bool =

    if source.len < 1 and pattern.len < 1:
      return true  
    if source.len < 1 or pattern.len < 1:
      return false

    var r = 0

    try:
      r = re.find(source, re.re("(?s)" & pattern, {}))
    except Exception as e:
      showException(e.msg)
      return false

    if r != -1:
      return true
    return false                  

proc `!~`*(source, pattern: string): bool =

    if source.len < 1 and pattern.len < 1:
      return false 
    if source.len < 1 or pattern.len < 1:
      return true

    var r = 0

    try:
      r = re.find(source, re.re("(?s)" & pattern, {}))
    except Exception as e:
      showException(e.msg)
      return true

    if r != -1:
      return false
    return true                

#
# Split
#
#   split(source [string], dest [seq], match [regex])
#
#   Split 'source' along regex 'match' and store segments in 'dest'.
#
#   . Returns the number of elements in 'dest'
#   . 'dest' is a seq[] filled with results of the split.
#   . The 'dest' seq is created by split, it does not need to exist before invoking split.
#   . If seq does exist, its contents will be overwritten.
#   . The first element of 'dest' is 0.
#   . If there are 0 splits, 'dest' will be 0-length
#   . Because nim's system.split() has the same order and type of arguments it should be invoked as awk.split() to avoid ambiguity.
#
template split*(source, dest: untyped, match: string): int =

  when compiles(dest):
    try:
      dest = re.split(source, re.re("(?s)" & match, {}))
    except Exception as e:
      showException(e.msg)
      makeDiscardable(0)
  else:
    var dest: seq[string]
    try:
      dest = re.split(source, re.re("(?s)" & match, {}))
    except Exception as e:
      showException(e.msg)
      makeDiscardable(0)

  if source.len == 0 or dest.len == 0:
    makeDiscardable(0)
  else:
    if dest[0] == source:  # no match
      delete(dest, 0)
      makeDiscardable(0)
    else:
      makeDiscardable(dest.len)

#
# Patsplit
#
#   patsplit(source [string], field [seq], pattern [regex])
#   patsplit(source [string], field [seq], pattern [regex], sep [seq])
#
#   Divide 'source' into pieces defined by regex 'pattern' and store the pieces in seq 'field'
#   Optional 'sep' stores the seperators
#
#    . The 'field' (and 'sep') must be created beforehand (see example) using newSeq[string](0)
#    . Returns number of field elements found.
#    . If no match found, 'field' is set to the value of 'source'
#
#  Example 1
#
#     var str = "This is <!--comment1--> a string <!--comment2--> with comments."
#     var field = newSeq[string](0)
#     if patsplit(str, field, "<[ ]{0,}[!].*?>") > 0:
#       echo field[0] #=> "<!--comment1-->"
#       echo field[1] #=> "<!--comment2-->"
#
#  Example 2
#
#   'field' will store the field content: <!--comment--> and <!--comment2-->
#   'sep' will store the separting pieces: "This is ", " a string ", " with comments."
#
#     var ps = "This is <!--comment--> a string <!--comment2--> with comments."
#     var field, sep = newSeq[string](0)
#     patsplit(ps, field, "<[ ]{0,}[!].*?>", sep)
#     echo sep[1] #=> " a string "
#     echo unpatsplit(field, sep)
#
#
proc patsplit*(source: string, field: var seq[string], pattern: string): int {.discardable.} =

  var        
    source = source 
    i,r = 0
    j: tuple[first: int, last: int]

  field = @[""]

  while len(source) > 0:

    try:
      j = re.findBounds(source, re.re("(?s)" & pattern, {}) )
    except Exception as e:
      showException(e.msg)
      return 0

    if j.first > -1:
      i.inc
      field.insert(system.substr(source, j.first, j.last), i)
      source = system.substr(source, j.last + 1, len(source) - 1)
    else:
      if len(source) > 0:                
        source = ""

  if i > 0:
    field.delete(0)
    r = i
  else:
    r = 0

  return r

proc patsplit*(source: string, field: var seq[string], pattern: string, sep: var seq[string]): int {.discardable.} =

  var
    source = source
    i,r = 0
    j: tuple[first: int, last: int]

  field = @[""]
  sep = @[""]

  while len(source) > 0:

    try:
      j = re.findBounds(source, re.re("(?s)" & pattern, {}) )
    except Exception as e:
      showException(e.msg)
      return 0

    if j.first > -1:
      i.inc
      field.insert(system.substr(source, j.first, j.last), i)
      sep.insert(system.substr(source, 0, j.first - 1), i)
      source = system.substr(source, j.last + 1, len(source) - 1)
    else:
      if len(source) > 0:
        sep.insert(source, i + 1)
        source = ""

  if i > 0:
    field.delete(0)
    sep.delete(0)
    r = i
  else:
    field.insert(source, 1)
    field.delete(0)
    r = 0

  return r

#
# Unpatsplit
#
#  unpatsplit(field [seq], sep [seq])
#
#  Given two seq's created by patsplit, recombine into a single string in alternating sequence ie. field[0] & seq[0] & field[1] & seq[1] etc.
#
#   . If field has more elements than sep, return ""
#   . Typically used to recombine a string separated by patsplit()
#
#
proc unpatsplit*(field, sep: seq[string]): string =

   var o = ""
   if field.len > sep.len:
     return o
   for c in 0..field.len - 1:
     if field[c].len > 0:
       o = o & sep[c] & field[c]
     else:
       o = o & sep[c]
   if sep[sep.len - 1].len > 0 and sep.len != field.len:
     o = o & sep[sep.len - 1]
   return o

#
# Sub
#
#  sub(pattern [regex], replacement [string], source [string])
#  sub(pattern [regex], replacement [string], source [string], occurance [int])
#
#  Substitute in-place the first occurance of regex 'pattern' with 'replacement' in 'source' string
#  Substitute the Xth 'occurance'
#
#   . If 'source' is not a declared variable (eg. literal string), sub() returns the new string but does not sub in-place (see example)
#   . Substitutions are non-overlaping eg. sub("22","33","222222") => "333333" not "3333333333"
#
#  Example:
#    str = "This is a sring"
#    sub("[ ]is[ ]", " or ", str)                       # substitute 'str' in-place.
#    echo str #=> "This or a string"
#    echo sub("[ ]is[ ]", " or ", "This is a sring")    # doesn't sub the literal "This is a sring" in-place, returns the new string
#
#
proc sub*(pattern, replacement: string, source: var string): string {.discardable.} =
  if pattern.len == 0 or source.len == 0:
    return source
  var field, sep = newSeq[string](0)
  if patsplit(source, field, pattern, sep) > 0:
    field[0] = replacement
    source = unpatsplit(field, sep)
  return source

proc sub*(pattern, replacement, source: string): string {.discardable.} =
  if pattern.len == 0 or source.len == 0:
    return source
  var field, sep = newSeq[string](0)
  if patsplit(source, field, pattern, sep) > 0:
    field[0] = replacement
    return unpatsplit(field, sep)
  return source

proc sub*(pattern, replacement: string, source: var string, occurance: int): string {.discardable.} =
  if pattern.len == 0 or source.len == 0:
    return source
  var field, sep = newSeq[string](0)
  var p = patsplit(source, field, pattern, sep)
  if p > 0:
    if occurance <= p:
      field[occurance - 1] = replacement
      source = unpatsplit(field, sep)
  return source

proc sub*(pattern, replacement, source: string, occurance: int): string {.discardable.} =
  if pattern.len == 0 or source.len == 0:
    return source
  var field, sep = newSeq[string](0)
  var p = patsplit(source, field, pattern, sep)
  if p > 0:
    if occurance <= p:
      field[occurance - 1] = replacement
      return unpatsplit(field, sep)
  return source

#
# Gsub
#
#  gsub(pattern [regex], replacement [string], source [string])
#
#  Global substitute in-place the regex 'pattern' with 'replacement' in 'source' string
#
#  Example 1:
#   str = "this is is string"
#   gsub("[ ]is.*?st", " is a st", str)
#   echo str #=> "this is a string"
#
#  Example 2:
#   echo gsub("[ ]is.*?st", " is a st", "this is is string")
#   => "this is a string"
#
#  Caution: a self-reference will not produce expected results eg:  str = gsub(a, b, str) - use gsubi()
#
#
proc gsub*(pattern, replacement: string, source: var string): string {.discardable.} =
  if pattern.len == 0 or source.len == 0:
    return

  try:
    source = re.replace(source, re.re("(?s)" & pattern, {}), replacement)
  except Exception as e:
    showException(e.msg)
    return source

  return source

proc gsub*(pattern, replacement, source: string): string =

  if pattern.len == 0 or source.len == 0:
    return source

  var r = ""
  try:
    r = re.replace(source, re.re("(?s)" & pattern, {}), replacement)
  except Exception as e:
    showException(e.msg)
    return source

  return r

#
# Gsubi
#
#  gsubi(pattern [regex], replacement [string], source [string])
#
#  Global substitute the regex 'pattern' with 'replacement' in 'source' string
#  Returns the new string, leaving the source string unmodified
#
#  Example 1:
#   str = "this is is string"
#   echo gsubi("[ ]is.*?st", " is a st", str)  #=> "this is a string"
#   echo str #=> "this is is string"
#
#
proc gsubi*(pattern, replacement, source: string): string =

  if pattern.len == 0 or source.len == 0:
    return source

  var r = ""
  try:
    r = re.replace(source, re.re("(?s)" & pattern, {}), replacement)
  except Exception as e:
    showException(e.msg)
    return source

  return r

#
# Gsubs
#
# A literal string version of gsub()
#
#  Mimic strutils.replace()
#
proc gsubs*(pattern, replacement: string, source: var string): string {.discardable.} =

    let patLen = pattern.len
    if patLen == 0:
      return source
    if source == "":
      return

    var
      r = ""
      i, j = 0

    while true:
      try:
        # j = boyerMooreHorspool(source, pattern, i)
        j = strutils.find(source, pattern, i)
      except Exception as e:
        showException(e.msg)
        return source
      if j < 0:
        break
      add r, substr(source, i, j - 1)
      add r, replacement
      i = j + patLen
    add r, substr(source, i)
    source = r
    return r

proc gsubs*(pattern, replacement, source: string): string =

    let patLen = pattern.len
    if patLen == 0:
      return source
    if source == "":
      return

    var
      r = ""
      i, j = 0

    while true:
      try:
        # j = boyerMooreHorspool(source, pattern, i)
        j = strutils.find(source, pattern, i)
      except Exception as e:
        showException(e.msg)
        return source
      if j < 0:
        break
      add r, substr(source, i, j - 1)
      add r, replacement
      i = j + patLen
    add r, substr(source, i)
    return r

#
# Subs
#
#   subs(pattern [string], replacement [string], source [string])
#
# Non-regex version of sub(). Replaces first occurance of 'pattern' with 'replacement' in 'source'
#
#   . If 'source' is a literal string (not a variable) returns new string
#     otherwise returns new string (discardable) and modifies 'source' in place
#
# Example:
#   var s = "xxabxx"
#   echo subs("ab", "AB", s) ==> "xxABxx"
#   echo s ==> "xxABxx"
#   echo subs("ab", "AB", "xxabxx") ==> "xxABxx" 
#

proc subs*(pattern, replacement: string, source: var string): string {.discardable.} =

    let patLen = pattern.len
    if patLen == 0:
      return source
    if source == "":
      return

    var
      r = ""
      i, j = 0        

    try:
      # j = boyerMooreHorspool(source, pattern, i)
      j = strutils.find(source, pattern, i)
    except Exception as e:
      showException(e.msg)
      return source 
    if j < 0:
      return source
    add r, substr(source, i, j - 1)
    add r, replacement
    i = j + patLen
    add r, substr(source, i)
    source = r
    return r

proc subs*(pattern, replacement, source: string): string =

    let patLen = pattern.len
    if patLen == 0:
      return source
    if source == "":
      return               

    var
      r = ""
      i, j = 0    

    try:
      # j = boyerMooreHorspool(source, pattern, i)
      j = strutils.find(source, pattern, i)
    except Exception as e:
      showException(e.msg)
      return source
    if j < 0:
      return source
    add r, substr(source, i, j - 1)
    add r, replacement
    i = j + patLen
    add r, substr(source, i)
    return r

#
#
# Substr
#
#   substr(source [string], start [int])
#   substr(source [string], start [int], length[int])
#
# Return 'length'-character long substring of 'source' starting at char number 'start'
#
#   . The first character is 0.
#   . If 'length' not present return the string from 'start' to end
#   . If 'start' < 0, treat as 0
#   . If 'start' > length of source, return ""
#   . If 'length' < 1, return ""
#   . Because nim's system.substr() has the same order and type of arguments this proc should be invoked as awk.substr() to avoid ambiguity
#
# Example:
#   echo awk.substr("Hello World", 3)
#   > "lo World"
#   echo awk.substr("Hello World", 3, 2)
#   > "lo"
#
#
proc substr*(source: string, a: varargs[int]): string =

  var 
    length, start = -1
    alen = a.len

  if alen < 1:
    return ""
  elif alen == 1:
    start = a[0]
    length = source.len
  elif alen == 2:
    start = a[0]
    length = a[1]

  if length > source.len:
    length = source.len
  if start < 0:
    start = 0
  if start > source.len or length < 1 or source.len < 1:
    return ""

  var 
    newsource = source
    final = ""

  for i in 0..source.len - 1:
    if i >= start and i < start + length:
      add(final, newsource[i])
  if len(final) > 0:
    return final
  else:
    return ""

#
# Index
#
#  index(source [string], target [string])
#
# Return 0-oriented start location (index) of first occurance of the non-regex 'target' in 'string'
#
#    . if none found or error return -1
#
# Example
#
#    var loc = index("This is string", "is")
#    echo loc #=> 2
#
#
proc index*(source, target: string): int =

  if source.len == 0 or target.len == 0:
    return -1
  var r = 0
  try:
    r = strutils.find(source, target)
  except Exception as e:
    showException(e.msg)
    return 0
  return r

#
# An implementation of Boyer-Moore-Horspool string searching
#  From Cello https://unicredit.github.io/cello/
#  Copyright (2019) Andrea Ferretti, Apache License 2.0
#  mimic strutils.find() 
#
#  NOT IN USE - reference only. Doesn't work.
#
proc boyerMooreHorspool*(target, query: string, start = 0): int =
  let
    m = len(query)
    n = len(target)
  if m > n: return -1
  var skip = newSeq[int](257)
  for i in 1 .. 256:
    skip[i] = m
  for k in 0 ..< (m - 1):
    skip[query[k].int] = m - k - 1
  var k = start + m - 1
  while k < n:
    var
      j = m - 1
      i = k
    while j >= 0 and target[i] == query[j]:
      dec(j)
      dec(i)
    if j == -1:
      return i + 1
    k += skip[target[k].int]
  return -1

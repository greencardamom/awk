Nim for awk programmers
=======================

A library of GNU awk functions for nim. Standard awk library functions written in and for nim.

- Program in nim using the familair regex-enabled awk toolset.
- For nim programers, a small set of powerful regex tools from the awk world.
- Convert GNU awk scripts to C (and binary executable) without coding in C by using the nim macro language.

Awk and nim can look very similair. Example awk program that prints the word "text":

```awk
BEGIN{
  str = "This is <a href=\"my text\">here</a>"
  if(match(str, "<a href=\"my text\">", dest)) {
    split(dest[0], arr, "\"")
    if(arr[2] ~ /text/)
      print substr(arr[2], 4, length(arr[2]))
  }
}
```

nim version:

```nim
import awk

var str = "This is <a href=\"my text\">here</a>"
if(match(str, "<a href=\"my text\">", dest) > 0):   
  awk.split(dest, arr, "\"")
  if(arr[1] ~ "text"):
    echo awk.substr(arr[1], 3, len(arr[1]) - 1)  
```

Nim compiles to C source, which compiles to a standalone binary executable using gcc. The nim compile (c) and run (-r) command:

```
nim c -r "test.nim"
text
```

Versions
=======

Most of the nim procs in this package deal with awk's regex functionality. 

Two versions are included: awk.nim uses the "re" module and awknre.nim uses the "nre" module.

The re module is significantly faster and recommended, but awknre.nim is included for backwards compat since the first version of this package used it and there may be some differences in regex options.

Functions
=========

~ and !~
--------
Emulate awk's ~ and !~ commands which can be thought of as a regex-enabled version of contains() in nim. 

```nim
proc `~`*(source, pattern: string): bool 
proc `!~`*(source, pattern: string): bool 
```

Nim does not have an equivilent of awk's // to signify a text is regex. Therefore all text to the right of ~ is treated as regex. To do a literal 
string test use == instead of ~

Use grouping () when building a string with '&', for example:
```nim
if s ~ ("^" & re & "$"):
```

Example:

```nim
import awk
if "george" ~ "ge.*?rge":
  echo "true" #=> true
```

\>* and >>
--------
Write text to a file (append or overwrite)

```nim
proc `>*`(text, filename: string): bool
```
Write `text` to `filename`, overwrite previous content. Close on finish.

```nim
proc `>>`(text, filename: string): bool
```
Append `text` to `filename`. Close on finish.

Example:
```nim
"Hello" & " world" >* "/tmp/test.txt"
"Hello" >* "/dev/stderr"
```

Note that awk's ">" is refactored as ">*" to avoid conflicting with nim's ">" 


match
------
Find regex `pattern` in `source` and optionally store result in `dest`.

```nim
proc match(source: string, pattern: string [, dest: string]): int
```

- `source` is the string to match against.
- `pattern` is the regex pattern.
- `dest` is an optional string to hold the matched text. 
- If `dest` was not declared previously, it will be created. If it exists, match() will overwrite the contents with the results of the match.
- The return value is the number of characters from the start, starting with 1, where the matched text is located, or 0 if no match.
- Consider using index() instead assuming `pattern` is not a regex and not using `dest`, it's faster.

Example:

```nim
import awk
if match("this is a test a", "s.*?a", a) > 0:
  echo a #=> "s is a"   
```

split
--------
Split `source` along regex `match` and store segments in `dest`.

```nim
template split(source: string, dest: untyped, match: string): int
```

- `source` is the source string to be split.
- `dest` is a seq[] filled with results of the split.
- `match` is a string (regex or not) that will be used to split `source`

The function behaves much like awk:

- Returns the number of splits (discardable). 
- The `dest` seq is created by split, it does not need to exist before calling split().
- If the seq does exist, the contents will be overwritten.
- If there are 0 splits `dest` will be 0-length ie. check the return value of split and/or length of `dest` before accessing `dest`
- The first element of `dest` is 0 (unlike awk which is 1). 
- Because nim's system.split() has the same order and type of arguments it should be invoked as awk.split() to avoid ambiguity.

Example:
```nim
import awk
awk.split("This is a string", arr, "is")
echo arr[0] #> "Th"
```

gsub
-----
Global substitute the regex `pattern` with `replacement` in the `source` string

```nim
gsub(pattern: string, replacement: string, source: string): string
```

- `pattern` is a regex (or literal) string
- `replacement` is the new text to replace the pattern text.
- `source` is the source string.

gsub() returns the new string in addition to changing the source string in-place. It is discardable. 

If the source string is not a var (let, const or literal string) the source string is not modified in-place.

Example 1:
```nim
str = "this is is string"
gsub("[ ]is.*?st", " is a st", str)   
echo str #=> "this is a string"
```

Example 2:
```nim
echo gsub("[ ]is.*?st", " is a st", "this is is string")   
=> "this is a string"
```

Caution: a self-reference will not produce expected results. For example this doesn't produce an error but doesn't work:
```nim
str = "abc"
str = gsub("b", "z", str)
```

sub
----
```nim
sub(pattern: string, replacement: string, source: string [, occurance: int]): string
```

Substitute in-place the first occurance of regex `pattern` with `replacement` in `source` string
Optional `occurance` substitute at the Xth occurance.

- `pattern` is a regex (or literal string) used in making the substitution
- `replacement` the new string 
- `source` is the string matched against
- `occurance` optional (default 1) which occurance to substitute

If `source` is not a pre-declared variable, sub returns the new string but does not sub in-place
Substitutions are non-overlap eg. sub("22","33","222222") => "333333" not "3333333333"

Example:
```nim
str = "This is a sring"
sub("[ ]is[ ]", " or ", str)                       # substitute 'str' in-place.
echo str #=> "This or a string"
echo sub("[ ]is[ ]", " or ", "This is a sring")    # doesn't sub "This is a sring" in-place, returns a new string
```

patsplit
--------
Divide `source` into pieces defined by regex `pattern` and store the pieces in seq `field`. Optional `sep` stores the seperators.

```nim
patsplit(source: string, field: seq, pattern: string [, sep: seq]): int
```

- `source` is the source string
- `field` is a sequence containing the field pieces
- `pattern` is a regex (or literal) pattern string
- `sep` is a sequence containing the seperator pieces. Optional.

patsplit() behaves as follows:

- The `field` (and `sep`) sequences must be created beforehand (see example how). 
- Returns number of field elements found.
- If no match found, `field` is set to the value of `source`

Example 1:
```nim
var str = "This is <!--comment1--> a string <!--comment2--> with comments."
var field = newSeq[string](0)
if patsplit(str, field, "<[ ]{0,}[!].*?>") > 0:
  echo field[0] #=> "<!--comment1-->"
  echo field[1] #=> "<!--comment2-->"
```

Example 2:
```nim
var ps = "This is <!--comment--> a string <!--comment2--> with comments."
var field, sep = newSeq[string](0)
patsplit(ps, field, "<[ ]{0,}[!].*?>", sep)
echo sep[1] #=> " a string "
echo unpatsplit(field, sep)
```

unpatsplit
----------
Recombine two sequences created by patsplit()

```nim
unpatsplit(field: seq, sep: seq)
```

Given two seq's created by patsplit, recombine into a single string in alternating sequence ie. field[0] & seq[0] & field[1] & seq[1] etc.

If field has more elements than sep, return ""


substr
------
Return `length`-character long substring of `source` starting at char number `start`

```nim
substr(source: string, start: int [, length: int]): str
```

- The first character is 0 (diff from awk which is 1)
- If `length` not present return the string from `start` to end
- If `start` < 0, treat as 0
- If `start` > length of source, return ""
- If `length` < 1, return ""
- Because nim's system.substr() has the same order and type of arguments this proc should be invoked as awk.substr() to avoid ambiguity.

Example:
```nim
echo awk.substr("Hello World", 3)
#> "lo World"
echo awk.substr("Hello World", 3, 2)
#> "lo"
```

index
------
Return the start location (index) of the first occurance of non-regex `target` in `source`

```nim
index(source: string, target: string): int
```

- First character is 0 (not 1 as in awk)
- If none found or error return -1

Example
```nim
var loc = index("This is string", "is")
echo loc #=> 2
```

Techniques
=============

associative arrays
------------------
Awk uses associative arrays. Nim also supports associative arrays, called "tables". 

For example in awk to uniqe a list of words:

```awk
split("Blue Blue Red Green", arr, " ")        # Whoops, let's get rid of the extra "Blue"

for(i in arr)
  uarr[i] = 1
for(i in uarr)
  print i
```

The equivilent in Nim:
```nim
import strutils, tables

var 
  arr = split("Blue Blue Red Green", " ")     # list of words containing a duplicate
  uarr = initTable[string, int]()             # create empty table (associative array) to hold words

for i in arr:                                 # unique the list
  uarr[i] = 1
for j in uarr.keys:                           # print the list     
  echo j
```

Getting started with nim
========================
- [How I Start](http://howistart.org/posts/nim/1) has good instructions for installing nim. It takes 5 minutes and everything is contained in a single directory.
- [Nim Language](http://nim-lang.org/), official website.
- [GNU awk manual](https://www.gnu.org/software/gawk/manual/gawk.html)

-- Misc functions
--  Copyright © Martijn Buijs, 2008
--  http://www.bytehazard.com


-- reads string from file
fn ReadStr fp =
(
 -- read string length (2 bytes)
 local len = ReadShort fp
 
 -- read string characters (zero terminated)
 local str = ""
 for i=1 to len do
 (
  str = str + (bit.IntAsChar (ReadByte fp))
 )
 
 -- success
 return str
)


-- splits string by seperator character
fn Split str sep =
(
 local out = #()
 local tmp = ""
 for i=1 to str.count do
 (
  if (str[i] == sep) then
  (
   if tmp.count > 0 do
   (
    append out tmp
    tmp = ""
   )
  ) else (
   tmp = tmp + str[i]
  )
  if (i == str.count) do (
   if tmp.count > 0 do append out tmp
  )
 )
 return out
)


-- returns character position in string
fn InStr str char =
(
 for i=1 to str.count do
 (
  if str[i] == char do return i
 )
 return 0
)


-- returns character position in string from end
fn InStrRev str char =
(
 local i = str.count
 while i > 0 do
 (
  if str[i] == char do return i
  i=i-1
 )
 return 0
)


-- returns part of string
fn Mid str start num =
(
 local tmp = ""
 for i=start to start+num-1 do
 (
  tmp = tmp + str[i]
 )
 return tmp
)


-- returns part of string
fn StrPart str start end =
(
 local tmp = ""
 for i=start to end do
 (
  tmp = tmp + str[i]
 )
 return tmp
)


-- replaces characters
fn ReplaceChars str fnd rpl =
(
 for i=1 to str.count do
 (
  if str[i] == fnd do str[i] = rpl
 )
 return str
)


-- removes character
fn StripChars str rem =
(
 local tmp = ""
 for i=1 to str.count do
 (
  if str[i] != rem do tmp = tmp + str[i]
 )
 return tmp
)


-- rounds number
fn Round val n =
(
 local mult = 10.0 ^ n
 return (floor ((val * mult) + 0.5)) / mult
)


-- sets smooth group
fn SetSmooth obj grp =
(
 for i=1 to obj.numfaces do
 (
  setFaceSmoothGroup obj i grp
 )
)


-- auto edge visibility
fn AutoEdge obj threshold =
(
 meshop.autoedge obj #{1..(obj.numFaces * 3)} threshold
)


-- END OF FILE

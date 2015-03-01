-- BF1942 Skin Importer
--  Copyright © Martijn Buijs, 2014
--  http://www.bytehazard.com


filein "bf42misc.ms"

struct skinvertbone (index, weight, rpos)
struct skinvert (wpos, bonenum, bone)



-- imports skin file
fn ImportSkin filename =
(
 local verts = #()
 
 -- open file
 local fp = fopen filename "rb"
 if fp == undefined do
 (
  messagebox "Could not open file \"" + filename + "\"."
  return false
 )
 
 -- read version (4 bytes)
 local version = ReadLong fp
 
 -- read number of vertices (4 bytes)
 local vertNum = ReadLong fp
 
 -- read vertices (vertNum * 31 bytes)
 for i=1 to vertNum do
 (
  -- position (12 bytes)
  local px = ReadFloat fp
  local py = ReadFloat fp
  local pz = ReadFloat fp
  local p = [-px,py,pz] * impscale
  
  -- number of bone influences (1 byte)
  local n = ReadByte fp
  
  -- influences (n * 18 bytes)
  local infl = #()
  for j=1 to n do
  (
   -- index (2 bytes)
   local b = ReadShort fp
   
   -- weight (4 bytes)
   local w = ReadFloat fp
   
   -- unknown (12 bytes)
   local vx = ReadFloat fp
   local vy = ReadFloat fp
   local vz = ReadFloat fp
   local v = [-vx,vy,vz] * impscale
   
   -- add influence to list
   append infl (skinvertbone b w v)
  )
  
  -- add vertex to list
  append verts (skinvert p n infl)
 )
 
 -- read boneNum
 local boneNum = ReadShort fp
 
 -- read bone list
 local bonelist = #()
 for i=1 to boneNum do
 (
  -- read bone name
  local name = ReadStr fp
  --format ">>> %\n" name
  
  -- add to list
  append bonelist name
 )
 
 
 ---- TEMP: create points for each vert
 for i=1 to verts.count do
 (
  local v = verts[i]
  local obj = point()
  obj.size = 0.01
  obj.position = v.wpos
 )
 ---- TEMP
 
 --format ">>> stop %\n" (ftell fp)
 --fseek fp 0 #seek_cur
 --format ">>> size %\n" (ftell fp)
 
 -- close file
 fclose fp
 
 -- success
 return true
)


-- END OF FILE

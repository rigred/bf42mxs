-- BF1942 Skeleton Importer
--  Copyright © Martijn Buijs, 2013
--  http://www.bytehazard.com


filein "bf42misc.ms"


-- creates line segment
fn CreateLine p1 p2 =
(
 local obj = SplineShape()
 addNewSpline obj
 addKnot obj 1 #corner #line p1
 addKnot obj 1 #corner #line p2
 updateShape obj
 return obj
)


-- imports skeleton file
fn ImportSkeleton filename =
(
 -- open file
 local fp = fopen filename "rb"
 if fp == undefined do
 (
  messagebox "Could not open file \"" + filename + "\"."
  return false
 )
 
 -- read version
 local version = ReadLong fp
 
 -- read nodeNum
 local nodeNum = ReadLong fp
 
 -- read nodes
 local nodelist = #()
 for i=1 to nodeNum do
 (
  -- read node name (? bytes)
  local name = ReadStr fp
  --format ">>> %\n" name
  
  -- read parent index (2 bytes)
  -- NOTE: -1 = no parent
  local parent = ReadShort fp #signed
  
  -- read transform (48 bytes)
  -- NOTE: 4x3 matrix
  local q = #()
  for j=1 to 12 do
  (
   q[j] = (ReadFloat fp)
  )
  local tf = (matrix3 [ q[1],q[5],q[9] ] [ q[2],q[6],q[10] ] [ q[3],q[7],q[11] ] ([ q[4],q[8],q[12] ]*impscale) )
  
  -- create node
  --local obj = (BoneSys.createBone startPos endPos zAxis)
  local obj = Dummy()
  obj.boxsize = [0.3, 0.3, 0.3]
  obj.name = name
  
  -- set parent node
  if (parent > -1) then
  (
   obj.parent = nodelist[ parent+1 ]
   obj.transform = tf * obj.parent.transform
   
   local r = CreateLine obj.position obj.parent.position
   r.parent = obj.parent
   r.name = "b_" + name
   
  ) else (
   obj.transform = tf
  )
  
  -- add to node list
  append nodelist obj
 )
 
 -- close file
 fclose fp
 
 -- transform to 3dsmax coordsys
 local flipTF = (matrix3 [1,0,0] [0,1,0] [0,0,-1] [0,0,0])
 nodelist[1].transform = nodelist[1].transform * flipTF
 
 -- success
 return true
)


-- END OF FILE

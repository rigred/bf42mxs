-- StdMesh Importer
--  Copyright © Martijn Buijs, 2008
--  http://www.bytehazard.com

-- todo: shadow mesh?


filein "bf42rsimp.ms"


-- globals
global stdmat

-- structures
struct stdmeshmat (matname, u2, u3, u4, prim, u6, vertstride, vertnum, indexnum, u7)


-- returns material by name
fn GetMatByName matname =
(
 for i=1 to sceneMaterials.count do
 (
  local mat = sceneMaterials[i]
  if mat.name == matname do return mat
  if (classof mat) == Multimaterial do
  (
   for j=1 to mat.numsubs do
   (
    if mat[j] != undefined do
    (
     if mat[j].name == matname do return mat[j]
    )
   )
  )
 )
 return undefined
)


-- returns stdmat by name
fn FindStdMat mname =
(
 for i=1 to stdmat.count do
 (
  if stdmat[i].name == mname do return stdmat[i]
 )
 return undefined
)


-- imports mesh file
fn ImportStdMesh filename =
(
 -- import shader file
 if impshader do
 (
  local fsfile = (getFilenamePath filename) + (getFilenameFile filename) + ".rs"
  ImportRs fsfile
 )
 
 -- get mesh name
 local meshname = getFilenameFile filename
 
 -- open file
 local fp = fopen filename "rb"
 if fp == undefined do
 (
  messagebox "Could not open file \"" + filename + "\"."
  return false
 )
 
 --- header --------------------------------------------------------------------
 
 -- file info (8 bytes)
 local version = ReadLong fp
 local u2 = ReadLong fp
 --format "version: %\n" version
 --format "u2: %\n" u2
 
 -- skip bounds (24 bytes)
 fseek fp 24 #seek_cur
 
 -- qflag (1 byte)
 local qflag
 if version == 10 do
 (
  qflag = ReadByte fp
  --format "qflag: %\n" qflag
 )
 local isSkin = (qflag == 0)
 
 --- collision meshes ----------------------------------------------------------
 
 local colnum = ReadLong fp
 for i=1 to colnum do
 (
  local size = ReadLong fp
  
  local skiploc = (ftell fp) + size
  
  -- skip 8 bytes
  fseek fp 8 #seek_cur
  
  -- vertices
  local vertnum = ReadLong fp
  local vert = #()
  for j=1 to vertnum do
  (
   local vx = (ReadFloat fp)*impscale
   local vy = (ReadFloat fp)*impscale
   local vz = (ReadFloat fp)*impscale
   fseek fp 4 #seek_cur
   append vert [-vx,-vz,vy]
  )
  
  -- faces
  local facenum = ReadLong fp
  local face = #()
  local faceid = #()
  local mlist = #()
  for j=1 to facenum do
  (
   local v1 = (ReadShort fp)+1
   local v2 = (ReadShort fp)+1
   local v3 = (ReadShort fp)+1
   
   -- determine material ID
   local fid = 0
   local m = (ReadShort fp)
   for k=1 to mlist.count do
   (
    if mlist[k] == m do
    (
     fid = k
     exit
    )
   )
   if fid == 0 do
   (
    append mlist m
    fid = mlist.count
   )
   
   append face [v1, v2, v3]
   append faceid fid
  )
  
  -- create mesh
  local msh = mesh vertices:vert faces:face materialIDS:faceid
  msh.name = (meshname + "_col" + (i as string))
  msh.renderable = false
  
  -- clear smoothgroups
  SetSmooth msh 0
  
  -- auto edge
  AutoEdge msh 1.0
  
  -- create multimat
  local multimat = MultiMaterial numsubs:mlist.count
  multimat.name = (meshname + "_col" + (i as string))
  for j=1 to mlist.count do
  (
   multimat[j] = StandardMaterial()
   multimat[j].name = ("colmat" + (j as string))
   local c = (color 255 127 127)
   c.h = j * (255.0 / mlist.count)
   multimat[j].diffusecolor = c
  )
  msh.mat = multimat
  
  -- done
  update msh
  
  -- skip to next col
  fseek fp skiploc #seek_set
 )
 
 --- mesh LODs -----------------------------------------------------------------
 
 local msh
 local prevlod = undefined
 
 -- read number of LODs (4 bytes)
 local lodnum = ReadLong fp
 
 -- read LODs
 for i=1 to lodnum do
 (
  -- read number of materials (4 bytes)
  local matnum = ReadLong fp
  
  -- read materials
  local mat = #()
  for j=1 to matnum do
  (
   mat[j] = stdmeshmat()
   
   -- material name
   local matnamelen = ReadLong fp
   local matname = ""
   for k=1 to matnamelen do
   (
    matname = matname + (bit.IntAsChar (ReadByte fp))
   )
   mat[j].matname = matname
   
   -- geometry info
   mat[j].u2 = ReadLong fp
   mat[j].u3 = ReadLong fp
   mat[j].u4 = ReadLong fp
   mat[j].prim = ReadLong fp
   mat[j].u6 = ReadLong fp
   mat[j].vertstride = ReadLong fp
   mat[j].vertnum = ReadLong fp
   mat[j].indexnum = ReadLong fp
   mat[j].u7 = ReadLong fp
  )
  
  -- create multi material
  local multimat = MultiMaterial numsubs:matnum
  multimat.name = meshname + "_Material_lod" + (i as string)
  for j=1 to matnum do
  (
   local submat = FindStdMat mat[j].matname
   if submat == undefined then
   (
    multimat[j] = StandardMaterial()
    multimat[j].name = mat[j].matname
    multimat[j].diffusecolor = (color 255 127 0 1)
   ) else (
    multimat[j] = submat
   )
   multimat[j].showInViewport = true
  )
  
  -- geometry data
  local vert = #()
  local norm = #()
  local tex1 = #()
  local tex2 = #()
  local face = #()
  local fmat = #()
  local offset = 0
  for j=1 to matnum do
  (
   -- vertex data
   for k=1 to mat[j].vertnum do
   (
    -- vertex
    vx = (ReadFloat fp)*impscale
    vy = (ReadFloat fp)*impscale
    vz = (ReadFloat fp)*impscale
    if isSkin then
    (
     append vert [-vx, vy, vz]
    ) else (
     append vert [-vx,-vz, vy]
    )
    
    -- normal
    nx = ReadFloat fp
    ny = ReadFloat fp
    nz = ReadFloat fp
    if isSkin then
    (
     append norm [-nx, ny, nz]
    ) else (
     append norm [-nx,-nz, ny]
    )
    
    -- texcoord 1
    tx = (ReadFloat fp)
    ty = (1.0 - (ReadFloat fp)) - 1.0
    append tex1 [tx,ty,0.0]
    
    -- texcoord 2
    if mat[j].vertstride > 32 do
    (
     tx = (ReadFloat fp)
     ty = (1.0 - (ReadFloat fp))
     append tex2 [tx,ty,0.0]
    )
   )
   
   -- index data
   
   -- GL_TRIANGLES
   if (mat[j].prim == 4) do
   (
    for k=1 to (mat[j].indexnum/3) do
    (
     local v1 = (ReadShort fp)+1
     local v2 = (ReadShort fp)+1
     local v3 = (ReadShort fp)+1
     append face [offset+v3, offset+v2, offset+v1]
     append fmat j
    )
   )
   
   -- GL_TRIANGLE_STRIP
   if (mat[j].prim == 5) do
   (
    local order = false
    local v1 = 0
    local v2 = 0
    local v3 = 0
    for k=1 to mat[j].indexnum do
    (
     v1 = v2
     v2 = v3
     v3 = (ReadShort fp)+1
     order = not order
     
     -- need at least three vertices to start
     if (k > 2) do
     (
      -- skip de-generate triangles
      if v1 != v2 AND v2 != v3 AND v1 != v3 do
      (
       -- with triangle strips, the vertex order is reversed every other triangle
       if (order) then
       (
        append face [offset+v3, offset+v2, offset+v1]
       ) else (
        append face [offset+v1, offset+v2, offset+v3]
       )
       append fmat j
      )
     )
    )
   )
   
   -- increment vertex offset
   offset = offset+mat[j].vertnum
  )
  
  --- create mesh --------------------------------------------------------------
  
  -- check if there are faces at all
  if face.count > 0 do
  (
   -- create mesh
   prevlod = msh
   msh = mesh vertices:vert tverts:tex1 faces:face materialIDS:fmat
   
   -- MXS bug workaround
   buildTVFaces msh 
   for j=1 to msh.numfaces do
   (
    setTVFace msh j (getFace msh j)
   )
   -- end workaround
   
   -- lightmap UVs
   if tex2.count > 0 do
   (
    -- MXS bug workaround
    local modf = uvwmap()
    modf.mapchannel = 2
    addModifier msh modf
    collapseStack msh
    -- end workaround
    
    meshop.setMapSupport msh 2 true
    meshop.setNumMapVerts msh 2 tex2.count
    for j=1 to tex2.count do
    (
     meshop.setMapVert msh 2 j tex2[j] 
    )
    meshop.buildMapFaces msh 2
    for j=1 to msh.numfaces do
    (
     meshop.setMapFace msh 2 j (getFace msh j)
    )
   )
   
   -- set material
   msh.mat = multimat
   
   -- set smooth groups
   SetSmooth msh 1
   
   -- auto edge
   AutoEdge msh 1.0
   
   if i==1 then (
    msh.name = meshname
    select msh
   ) else (
    msh.name = meshname + "_lod" + ((i-1) as string)
    msh.parent = prevlod
   )
   
   -- done
   update msh
   
  )
 )
 
 -- close file
 fclose fp
 
 -- success
 return true
)


-- END OF FILE

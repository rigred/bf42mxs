-- Battlefield 1942 Tools
--  Copyright © Martijn Buijs, 2014
--  http://www.bytehazard.com


-- globals
global rfBF42sdk
global impscale
global impshader
global lastfile


filein "bf42smimp.ms"
filein "bf42skeimp.ms"
filein "bf42sknimp.ms"


-- debugging clean up
clearlistener()


--- GUI ------------------------------------------------------------------------


-- clear last file
if lastfile == undefined do lastfile = ""

-- close floater
if rfBF42sdk != undefined do closeRolloutFloater rfBF42sdk

-- create floater
rfBF42sdk = newRolloutFloater "BF1942 Tools" 180 155


-- import rollout
rollout rImport "BF1942 Importer"
(
 group "Import"
 (
  spinner spnImpScale "Scale " range:[0.001,1000.0,10.0]
  checkbox chkImpShader "Import Shader" checked:true
  button cmdImport "Import..." width: 140
 )
 on cmdImport pressed do
 (
  local filters = "BF1942 Files|*.sm;*.ske;*.skn|Standard Mesh (*.sm)|*.sm|Skeleton (*.ske)|*.ske|Skin (*.skn)|*.skn|All Files (*.*)|*.*"
  
  -- open file dialog
  filename = getOpenFileName caption:"Import File" types:filters filename:lastfile
  if filename == undefined do return false
  
  -- remember filename
  lastfile = filename
  
  -- copy values
  impscale = spnImpScale.value
  impshader = chkImpShader.checked
  
  -- import
  case (getFilenameType filename) of
  (
   ".sm":( ImportStdMesh filename )
   --".tm":( ImportTreeMesh filename )
   ".ske":( ImportSkeleton filename )
   ".skn":( ImportSkin filename )
   default:( messagebox "File type not supported!" )
  )
  
 )
)
addRollout rImport rfBF42sdk


-- about rollout
rollout rAbout "About"
(
 label lab1 "BF1942 Importer"
 label lab2 "Version 1.0.0"
 label lab3 "Martijn Buijs, 2008-2014"
)
addRollout rAbout rfBF42sdk rolledup:true


-- END OF FILE

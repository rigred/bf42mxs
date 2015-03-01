-- BF1942 Refractor Shader Importer
--  Copyright © Martijn Buijs, 2008
--  http://www.bytehazard.com

filein "bf42misc.ms"


-- imports shader file
fn ImportRs filename =
(
 -- clear stdmat list
 stdmat = #()
 
 -- open file
 local fs = openfile filename
 if fs == undefined do
 (
  messagebox "Shader file \"" + filename + "\" not found."
  return false
 )
 
 -- read lines
 local inblock = false
 local mat = undefined
 while not (eof fs) do
 (
  -- read single line
  local ln = readline fs
  
  -- remove evil tabs
  ln = (StripChars ln "\t")
  
  -- only process if line not empty
  if ln.count > 0 do
  (
   str = (Split ln " ")
   case str[1] of
   (
    "subshader":
    (
     mat = StandardMaterial()
     mat.name = StripChars str[2] "\""
     --format ">>> subshader %\n" mat.name
     append stdmat mat
    )
    "{":( inblock=true )
    "}":( inblock=false )
    default:
    (
     -- ignore everything outside block
     if inblock do
     (
      case str[1] of
      (
       "lighting":()
       "lightingSpecular":()
       "materialDiffuse":()
       "texture":
       (
        local tmp = StripChars (StripChars str[2] "\"") ";"
        local s = (InStrRev tmp "/")+1
        local e = tmp.count
        local texname = StrPart tmp s e
        mat.diffusemap = BitmapTexture()
        mat.diffusemap.filename = texname + ".dds"
       
        --format ">>>  texture %\n" texname
       )
      )
     )
    )
    
   )
   
  )
 )
 
 -- close file
 close fs
 
 -- success
 return true
)

-- END OF FILE

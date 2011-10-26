--related thread: http://springrts.com/phpbb/viewtopic.php?f=13&t=26732&start=22
function widget:GetInfo()
  return {
    name      = "Map External Grid",
    desc      = "VR grid around map",
    author    = "knorke, tweaked by KR",
    date      = "Sep 2011",
    license   = "PD",
    layer     = -3,
    enabled   = false
  }
end

-- TODO: make res and range settable in options

local DspLst=nil
local res = 100		-- smaller = higher resolution (decreases performance)
local TileMaxX = Game.mapSizeX/res +1
local TileMaxZ = Game.mapSizeZ/res +1
local localAllyID = Spring.GetLocalAllyTeamID ()
local updateFrequency = 120
local gridTex = "LuaUI/Images/vr_grid.png"
local range = 7200/res	-- how far out of the map to draw (decreases performance)
local height = 0	-- how far above ground to draw

---magical speedups---
local math = math
local random = math.random
local spGetGroundHeight = Spring.GetGroundHeight
local glVertex = gl.Vertex
local glTexCoord = gl.TexCoord
local glColor = gl.Color
local glCreateList = gl.CreateList
local glTexRect = gl.TexRect
----------------------

local heights = {}

local maxHillSize = 800/res
local maxPlateauSize = math.floor(maxHillSize*0.6)
local maxHeight = 300
local featureChance = 0.01
local noFeatureRange = 0

-- for terrain randomization - kind of primitive
--[[
local terrainFuncs = {
	ridge = function(x, z, args)
			if args.height == 0 then return end
			for a=x-args.sizeX*res, x+args.sizeX*res,res do
				for b=z-args.sizeZ*res, z+args.sizeZ*res,res do
					local distFromCenterX = math.abs(a - x)/res
					local distFromCenterZ = math.abs(b - z)/res
					local heightMod = 0
					local excessDistX, excessDistZ = 0, 0
					if distFromCenterX > args.plateauSizeX then
						excessDistX = distFromCenterX - args.plateauSizeX
					end
					if distFromCenterZ > args.plateauSizeZ then
						excessDistZ = distFromCenterZ - args.plateauSizeZ
					end
					if excessDistX == 0 and excessDistZ == 0 then
						-- do nothing
					elseif excessDistX >= excessDistZ then
						heightMod = excessDistX/(args.sizeX - args.plateauSizeX)
					elseif excessDistX < excessDistZ then
						heightMod = excessDistZ/(args.sizeZ - args.plateauSizeZ)
					end
					
					if heights[a] and heights[a][b] then
						heights[a][b] = heights[a][b] + args.height * (1-heightMod)
					end
				end
			end
			--Spring.Echo(count)
		end,
	diamondHill = function(x, z, args) end,
	mesa = function(x, z, args) end,
}
]]--

local function InitGroundHeights()
	for x = (-1-range)*res,Game.mapSizeX+range*res, res do
		heights[x] = {}
		for z = (-1-range)*res,Game.mapSizeZ+range*res, res do
			local px, pz
			if x < 0 or x > Game.mapSizeX then	-- outside X map bounds; mirror true heightmap
				local xAbs = math.abs(x)
				local xFrac = (Game.mapSizeX ~= xAbs) and x%(Game.mapSizeX) or Game.mapSizeX
				local xFlip = -1^math.floor(x/Game.mapSizeX)
				if xFlip == -1 then
					px = Game.mapSizeX - xFrac
				else
					px = xFrac
				end
			end
			if z < 0 or z > Game.mapSizeZ then	-- outside Z map bounds; mirror true heightmap
				local zAbs = math.abs(z)
				local zFrac = (Game.mapSizeZ ~= zAbs) and z%(Game.mapSizeZ) or Game.mapSizeZ
				local zFlip = -1^math.floor(z/Game.mapSizeZ)
				if zFlip == -1 then
					pz = Game.mapSizeZ - zFrac
				else
					pz = zFrac
				end				
			end
			heights[x][z] = spGetGroundHeight(px or x, pz or z)	-- 20, 0
		end
	end
	
	--apply noise
	--[[
	for x=-range*res, (TileMaxX+range)*res,res do
		for z=-range*res, (TileMaxZ+range)*res,res do
			if (x > 0 and z > 0) then Spring.Echo(x, z) end
			if not (x + noFeatureRange > 0 and z + noFeatureRange > 0 and x - noFeatureRange < TileMaxX and z - noFeatureRange < TileMaxZ) and featureChance>math.random() then
				local args = {
					sizeX = math.random(1, maxHillSize),
					sizeZ = math.random(1, maxHillSize),
					plateauSizeX = math.random(1, maxPlateauSize),
					plateauSizeZ = math.random(1, maxPlateauSize),
					height = math.random(-maxHeight, maxHeight),
				}
				terrainFuncs.ridge(x,z,args)
			end
		end
	end	
	
	-- for testing
	local args = {
		sizeX = maxHillSize,
		sizeZ = maxHillSize,
		plateauSizeX = maxPlateauSize,
		plateauSizeZ = maxPlateauSize,
		height = maxHeight,
	}
	terrainFuncs.ridge(-600,-600,args)	
	]]--
end

--[[
function widget:GameFrame(n)
	if n % updateFrequency == 0 then
		Spring.Echo("ping")
		DspList = nil
	end
end
]]--

function widget:Initialize()
	InitGroundHeights()
end

local function GetGroundHeight(x, z)
	if(heights[x] and heights[x][z]) and (heights[x][z] ~=  spGetGroundHeight(x,z)) then
		--Spring.Echo(heights[x][z] - spGetGroundHeight(x,z))
	end
	return heights[x] and heights[x][z] or spGetGroundHeight(x,z)
end

local function TilesVerticesOutside()
	for x=-range,TileMaxX+range,1 do
		for z=-range,TileMaxZ+range,1 do
			if (x > 0 and z > 0 and x < TileMaxX and z < TileMaxZ) then 
			else
				glTexCoord(0,0)
				glVertex(res*(x-1), GetGroundHeight(res*(x-1),res*z), res*z)
				glTexCoord(0,1)
				glVertex(res*x, GetGroundHeight(res*x,res*z), res*z)
				glTexCoord(1,1)				
				glVertex(res*x, GetGroundHeight(res*x,res*(z-1)), res*(z-1))
				glTexCoord(1,0)
				glVertex(res*(x-1), GetGroundHeight(res*(x-1),res*(z-1)), res*(z-1))
			end
		end
	end
end

local function DrawTiles()
	gl.PushAttrib(GL.ALL_ATTRIB_BITS)
	gl.DepthTest(true)
	gl.DepthMask(true)
	gl.Texture(gridTex)
	--gl.TexGen(GL.TEXTURE_GEN_MODE, true)
	--glColor(1,1,1,1)
	gl.BeginEnd(GL.QUADS,TilesVerticesOutside)
	--TilesVerticesOutside()
	--DrawSquares()
	--gl.TexGen(GL.TEXTURE_GEN_MODE, false)
	gl.Texture(false)
	gl.DepthMask(false)
	gl.DepthTest(false)
	glColor(1,1,1,1)
	gl.PopAttrib()
end

function widget:DrawWorld()
	if not DspLst then
		DspLst=glCreateList(DrawTiles)
	end
	gl.CallList(DspLst)-- Or maybe you want to keep it cached but not draw it everytime.
	-- Maybe you want Spring.SetDrawGround(false) somewhere
end
-- Basic anti-radar by phenex.

local _fakevec = Vector( 1, 0, 0 )

local meta = FindMetaTable( "Entity" )
	
if meta ~= nil then
	function meta:EyePos() return _fakevec end
	function meta:GetAttachment() return { Ang = _fakevec, Pos = _fakevec } end
	function meta:GetFlexBound() return _fakevec, _fakevec, _fakevec, _fakevec, _fakevec, _fakevec end
	function meta:GetGroundEntity() return NULL end
	function meta:GetPos() return _fakevec end
	function meta:LocalToWorld() return _fakevec end
	function meta:OBBCenter() return _fakevec end
	function meta:OBBMaxs() return _fakevec end
	function meta:OBBMins() return _fakevec end
	function meta:GetPos() return _fakevec end
	function meta:WorldSpaceAABB() return _fakevec, _fakevec end
end
	
meta = FindMetaTable( "Player" )

if meta ~= nil then
	function meta:GetEyeTrace() return nil end
	function meta:GetShootPos() return _fakevec end	
end

player.GetByID = LocalPlayer
player.GetAll = function( ) return {} end

Msg( " * Anti-radar patch by phenex.\n" )
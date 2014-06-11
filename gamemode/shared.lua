TEAM_HUMANS  = 1
TEAM_BARRELS = 2
TEAM_SPECTATOR = 3

--DeriveGamemode( "fretta" )

team.SetUp( TEAM_HUMANS, "Humans", Color(255, 200, 50, 255))
team.SetUp( TEAM_BARRELS, "Barrel", Color(255, 0, 0,255))
team.SetUp( TEAM_SPECTATOR, "Spectators", Color(240, 230, 140,255))

/*---------------------------------------------------------

  This file should contain variables and functions that are 
   the same on both client and server.

  This file will get sent to the client - so don't add 
   anything to this file that you don't want them to be
   able to see.

---------------------------------------------------------*/

include( 'obj_player_extend.lua' )
include( 'sh_roundtimer.lua' )

include( 'gravitygun.lua' )
include( 'player_shd.lua' )

GM.Name 	= "Suicide Barrels"
GM.Author 	= "RalphORama"
GM.Email 	= ""
GM.Website 	= "http://www.corerp.co/"
GM.Help		= "Humans: Watch out for moving barrels!\nBarrels: Destroy all humans! Watch out though, they have guns!"


/*---------------------------------------------------------
   Name: gamemode:PlayerShouldTakeDamage
   Return true if this player should take damage from this attacker
---------------------------------------------------------*/
function GM:PlayerShouldTakeDamage( victim, attacker )
	if ( victim:Team( )== TEAM_BARRELS ) and ( attacker:Team( )== TEAM_BARRELS )and ( attacker != ply ) then
	   	return false
	elseif( victim:Team( )== TEAM_HUMANS ) and ( attacker:Team( )== TEAM_HUMANS )	and ( attacker != ply ) then
		return false
	else
		return true
	end
end

function GM:PlayerFootstep(ply, pos, foot, sound, volume, rf)
   if IsValid(ply) and (ply:Crouching() or ply:GetMaxSpeed() < 150 or ply:GetVelocity():Length() > 0 and ply:Team() == TEAM_BARRELS ) then
      -- do not play anything, just prevent normal sounds from playing
      return true
   end
end

/*---------------------------------------------------------
   Name: gamemode:ContextScreenClick(  aimvec, mousecode, pressed, ply )
   'pressed' is true when the button has been pressed, false when it's released
---------------------------------------------------------*/
function GM:ContextScreenClick( aimvec, mousecode, pressed, ply )
	
	// We don't want to do anything by default, just feed it to the weapon
	local wep = ply:GetActiveWeapon()
	if (wep:IsValid()) then
		local weptab = wep:GetTable()
		if (weptab.ContextScreenClick != nil) then
			weptab:ContextScreenClick( aimvec, mousecode, pressed, ply )
		end
	end
	
end

/*---------------------------------------------------------
   Name: Text to show in the server browser
---------------------------------------------------------*/
function GM:GetGameDescription()
	return self.Name
end


/*---------------------------------------------------------
   Name: CalcView
   Allows override of the default view
---------------------------------------------------------*/
function GM:CalcView( ply, origin, angles, fov )

	if ( ply:GetScriptedVehicle():IsValid() ) then
	
		local view = ply:GetScriptedVehicle():GetTable():CalcView( ply, origin, angles, fov )
		if ( view ) then return view end

	end
	

	local view = {}
	view.origin 	= origin
	view.angles		= angles
	view.fov 		= fov
	
	return view
	
end


/*---------------------------------------------------------
   Name: Saved
---------------------------------------------------------*/
function GM:Saved()
end


/*---------------------------------------------------------
   Name: Restored
---------------------------------------------------------*/
function GM:Restored()
end


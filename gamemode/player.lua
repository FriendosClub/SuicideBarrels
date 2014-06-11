include("sh_roundtimer.lua")


local AnimTranslateTable = {}
AnimTranslateTable[ PLAYER_RELOAD ] 	= ACT_HL2MP_GESTURE_RELOAD
AnimTranslateTable[ PLAYER_JUMP ] 		= ACT_HL2MP_JUMP
AnimTranslateTable[ PLAYER_ATTACK1 ] 	= ACT_HL2MP_GESTURE_RANGE_ATTACK

/*---------------------------------------------------------
   Name: gamemode:SetPlayerAnimation( )
   Desc: Sets a player's animation
---------------------------------------------------------*/
function GM:SetPlayerAnimation( pl, anim )

	local act = ACT_HL2MP_IDLE
	local Speed = pl:GetVelocity():Length()
	local OnGround = pl:OnGround()
	
	// If it's in the translate table then just straight translate it
	if ( AnimTranslateTable[ anim ] != nil ) then
	
		act = AnimTranslateTable[ anim ]
		
	else
	
		// Crawling on the ground
		if ( OnGround && pl:Crouching() ) then
		
			act = ACT_HL2MP_IDLE_CROUCH
		
			if ( Speed > 0 ) then
				act = ACT_HL2MP_WALK_CROUCH
			end
		
		// Player is running on ground
		elseif (Speed > 0) then
		
			act = ACT_HL2MP_RUN
			
		end
	
	end
	
	// Attacking/Reloading is handled by the RestartGesture function
	if ( act == ACT_HL2MP_GESTURE_RANGE_ATTACK || 
		 act == ACT_HL2MP_GESTURE_RELOAD ) then

		pl:RestartGesture( pl:Weapon_TranslateActivity( act ) )
		
		// If this was an attack send the anim to the weapon model
		if (act == ACT_HL2MP_GESTURE_RANGE_ATTACK) then
		
			pl:Weapon_SetActivity( pl:Weapon_TranslateActivity( ACT_RANGE_ATTACK1 ), 0 );
			
		end
		
	return end
	
	// Always play the jump anim if we're in the air
	if ( !OnGround ) then
		
		act = ACT_HL2MP_JUMP
	
	end
	
	// Ask the weapon to translate the animation and get the sequence
	// ( ACT_HL2MP_JUMP becomes ACT_HL2MP_JUMP_AR2 for example)
	local seq = pl:SelectWeightedSequence( pl:Weapon_TranslateActivity( act ) )
	
	// If we're in a vehicle just sit down
	// We should let the vehicle decide this when we have scripted vehicles
	if (pl:InVehicle()) then

		// TODO! Different ACTS for different vehicles!
		
		if ( pl:GetVehicle():GetTable().HandleAnimation ) then
		
			seq = pl:GetVehicle():GetTable().HandleAnimation( pl )
		
		else
		
			local class = pl:GetVehicle():GetClass()
			
			if ( class == "prop_vehicle_jeep" ) then
				seq = pl:LookupSequence( "drive_jeep" )
			elseif ( class == "prop_vehicle_airboat" ) then
				seq = pl:LookupSequence( "drive_airboat" )
			else 
				seq = pl:LookupSequence( "drive_pd" )
			end
		
		end
	
	end
	
	// If the weapon didn't return a translated sequence just set 
	//	the activity directly.
	if (seq == -1) then 
	
		// Hack.. If we don't have a weapon and we're jumping we
		// use the SLAM animation (prevents the reference anim from showing)
		if (act == ACT_HL2MP_JUMP) then
	
			act = ACT_HL2MP_JUMP_SLAM
		
		end
	
		seq = pl:SelectWeightedSequence( act ) 
		
	end
	
	// Don't keep switching sequences if we're already playing the one we want.
	if (pl:GetSequence() == seq) then return end
	
	// Set and reset the sequence
	pl:SetPlaybackRate( 1.0 )
	pl:ResetSequence( seq )
	pl:SetCycle( 0 )

end


/*---------------------------------------------------------
   Name: gamemode:PlayerNoClip( player, bool )
   Desc: Player pressed the noclip key, return true if
		  the player is allowed to noclip, false to block
---------------------------------------------------------*/
function GM:PlayerNoClip( pl, on )
	
	// Allow noclip if we're in single player
	if ( SinglePlayer() ) then return true end
	
	// Don't if it's not.
	return false
	
end


/*---------------------------------------------------------
   Name: gamemode:OnPhysgunFreeze( weapon, phys, ent, player )
   Desc: The physgun wants to freeze a prop
---------------------------------------------------------*/
function GM:OnPhysgunFreeze( weapon, phys, ent, ply )
	
	phys:EnableMotion( false )
	
	// With the jeep we need to pause all of its physics objects
	// to stop it spazzing out and killing the server.
	if (ent:GetClass() == "prop_vehicle_jeep") then
	
		local objects = ent:GetPhysicsObjectCount()
		
		for i=0, objects-1 do
		
			local physobject = ent:GetPhysicsObjectNum( i )
			physobject:EnableMotion( false )
			
		end
	
	end
	
	// Add it to the player's frozen props
	ply:AddFrozenPhysicsObject( ent, phys )
	
end


/*---------------------------------------------------------
   Name: gamemode:OnPhysgunReload( weapon, player )
   Desc: The physgun wants to freeze a prop
---------------------------------------------------------*/
function GM:OnPhysgunReload( weapon, ply )

	ply:UnfreezePhysicsObjects()

end

/*---------------------------------------------------------
   Name: gamemode:PlayerCanPickupWeapon( )
   Desc: Called when a player tries to pickup a weapon.
		  return true to allow the pickup.
---------------------------------------------------------*/
function GM:PlayerCanPickupWeapon( player, entity )
	return true
end


/*---------------------------------------------------------
   Name: gamemode:PlayerDisconnected( )
   Desc: Player has disconnected from the server.
---------------------------------------------------------*/
function GM:PlayerDisconnected( player )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSay( )
   Desc: A player (or server) has used say. Return a string
		 for the player to say. Return an empty string if the
		 player should say nothing.
---------------------------------------------------------*/
function GM:PlayerSay( player, text, teamonly )
	return text
end


/*---------------------------------------------------------
   Name: gamemode:PlayerDeathThink( player )
   Desc: Called when the player is waiting to respawn
---------------------------------------------------------*/
function GM:PlayerDeathThink( pl )

	local SpawnTime = pl:GetTable().NextSpawnTime

	if ( SpawnTime == nil || SpawnTime < CurTime() ) then
	
		pl:Spawn()
		
	end
	
end

/*---------------------------------------------------------
	Name: gamemode:PlayerUse( player, entity )
	Desc: A player has attempted to use a specific entity
		Return true if the player can use it
//--------------------------------------------------------*/
function GM:PlayerUse( pl, entity )
	return true
end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies.
---------------------------------------------------------*/
function GM:PlayerDeath( victim, inflictor, attacker )

end

/*---------------------------------------------------------
   Name: gamemode:PlayerInitialSpawn( )
   Desc: Called just before the player's first spawn
---------------------------------------------------------*/
function GM:PlayerInitialSpawn( pl )
	local randomply = table.Random(player.GetAll())
	
		if round.Active == true then
			pl:SetTeam( TEAM_SPECTATOR )
			pl:PrintMessage(HUD_PRINTTALK,"You're on the Spectator team because there wasn't enough players to start the round.")
		elseif round.Active == false then
			pl:SetTeam( TEAM_SPECTATOR )
			pl:PrintMessage(HUD_PRINTTALK,"You're on the Spectator team because we are waiting for the round to start.")
		else
			return
		end
	
end



/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
function GM:PlayerSpawn( pl )

	// Stop observer mode
	pl:UnSpectate()


	// Call item loadout function
	GAMEMODE:PlayerLoadout( pl )
	
	// Set player model
	GAMEMODE:PlayerSetModel( pl )
	
end

playerModels = {
	"models/player/Group01/Male_01.mdl",
	"models/player/Group01/Male_02.mdl",
	"models/player/Group01/Male_03.mdl",
	"models/player/Group01/Male_04.mdl",
	"models/player/Group01/Male_05.mdl",
	"models/player/urban.mdl",
	"models/player/gasmask.mdl",
	"models/player/riot.mdl"
}

/*---------------------------------------------------------
   Name: gamemode:PlayerSetModel( )
   Desc: Set the player's model
---------------------------------------------------------*/
function GM:PlayerSetModel( pl )

	if ( pl:Team( )== TEAM_BARRELS ) then
	util.PrecacheModel( "models/props_c17/oildrum001_explosive.mdl" )
	pl:SetModel( "models/props_c17/oildrum001_explosive.mdl" )
	elseif ( pl:Team()== TEAM_SPECTATOR ) then
		return
	elseif ( pl:Team() == TEAM_HUMANS ) then
	util.PrecacheModel( table.Random( playerModels ))
	pl:SetModel( table.Random( playerModels ) )
	end
end

/*---------------------------------------------------------
   Name: gamemode:PlayerLoadout( )
   Desc: Give the player the default spawning weapons/ammo
---------------------------------------------------------*/
function GM:PlayerLoadout( pl )
	
	if ( pl:Team() == TEAM_BARRELS ) then
	pl:Give( "sb_barrelsuicider" )
	pl:SetRunSpeed(320)
	pl:SetDuckSpeed(0.4)
	pl:SetWalkSpeed(220)
	elseif (pl:Team() == TEAM_HUMANS ) then
	pl:Give( "sb_barrelslayer" )
	pl:GiveAmmo( 999, "pistol", true )
	else
	pl:Spectate( OBS_MODE_ROAMING )
	end
	
	// Switch to prefered weapon if they have it
	local cl_defaultweapon = pl:GetInfo( "cl_defaultweapon" )
	
	if ( pl:HasWeapon( cl_defaultweapon )  ) then
		pl:SelectWeapon( cl_defaultweapon ) 
	end
	
end

function GM:CanPlayerSuicide( pl )
	if ( pl:Team() == TEAM_HUMANS or pl:Team() == TEAM_SPECTATOR ) then
		return false
	else
		return true
	end
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSelectSpawn( player )
   Desc: Find a spawn point entity for this player
---------------------------------------------------------*/
function GM:PlayerSelectSpawn( pl )

	// Save information about all of the spawn points
	// in a team based game you'd split up the spawns
	if (self.SpawnPoints == nil) then
	
		self.LastSpawnPoint = 0
		self.SpawnPoints = ents.FindByClass( "info_player_start" )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_combine" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_rebel" ) )
		
		// CS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_terrorist" ) )
		
		// DOD Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_axis" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_allies" ) )

		// (Old) GMod Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "gmod_player_start" ) )

	end
	
	local Count = table.Count( self.SpawnPoints )
	
	if ( Count == 0 ) then
		Msg("[PlayerSelectSpawn] Error! No spawn points!\n")
		return nil 
	end
	
	local ChosenSpawnPoint = nil
	
	// Try to work out the best, random spawnpoint (in 6 goes)
	for i=0, 6 do
	
		ChosenSpawnPoint = self.SpawnPoints[ math.random( 1, Count ) ]
		
		if ( ChosenSpawnPoint &&
			ChosenSpawnPoint:IsValid() &&
			ChosenSpawnPoint:IsInWorld() &&
			ChosenSpawnPoint != pl:GetVar( "LastSpawnpoint" ) &&
			ChosenSpawnPoint != self.LastSpawnPoint ) then
			
			self.LastSpawnPoint = ChosenSpawnPoint
			pl:SetVar( "LastSpawnpoint", ChosenSpawnPoint )
			return ChosenSpawnPoint
			
		end
			
	end
	
	return ChosenSpawnPoint
	
end

/*---------------------------------------------------------
   Name: gamemode:WeaponEquip( weapon )
   Desc: Player just picked up (or was given) weapon
---------------------------------------------------------*/
function GM:WeaponEquip( weapon )
end



/*---------------------------------------------------------
   Name: gamemode:UpdateAnimation( )
   Desc: Animation updates (pose params etc) should be done here
---------------------------------------------------------*/
function GM:UpdateAnimation( pl )


	if ( pl:InVehicle() ) then

		//if ( pl:GetVehicle():GetTable().UpdateAnimation ) then
		//	seq = pl:GetVehicle():GetTable().UpdateAnimation( player )
		//end
		
		// We only need to do this clientside..
		if ( CLIENT ) then
			// Pass the vehicles steer param down to the player
			local steer = pl:GetVehicle():GetPoseParameter( "vehicle_steer" )

			pl:SetPoseParameter( "vehicle_steer", steer ) 
		end
	
	end

end

/*---------------------------------------------------------
   Name: gamemode:PlayerTraceAttack( )
   Desc: A bullet has been fired and hit this player
		 Return true to completely override internals
---------------------------------------------------------*/
function GM:PlayerTraceAttack( ply, dmginfo, dir, trace )
	return false
end


/*---------------------------------------------------------
   Name: gamemode:SetPlayerSpeed( )
   Desc: Sets the player's run/walk speed
---------------------------------------------------------*/
function GM:SetPlayerSpeed( ply, walk, run )

	if (SERVER) then
		ply:GetTable().WalkSpeed = walk
		ply:GetTable().SprintSpeed = run
		ply:SetMaxSpeed( walk )
		ply:SendLua( "GAMEMODE:SetPlayerSpeed(0,"..walk..","..run..")" )
	else
		LocalPlayer():GetTable().WalkSpeed = walk
		LocalPlayer():GetTable().SprintSpeed = run
	end
end

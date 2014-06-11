
local meta = FindMetaTable( "Player" )
if (!meta) then return end

// In this file we're adding functions to the player meta table.
// This means you'll be able to call functions here straight from the player object
// You can even override already existing functions.

function meta:GetScriptedVehicle()

	return self:GetNetworkedEntity( "ScriptedVehicle" )

end

function meta:SetScriptedVehicle( veh )

	self:SetNetworkedEntity( "ScriptedVehicle", veh )
	self:SetViewEntity( veh )

end


/*---------------------------------------------------------
   Name:	AddFrozenPhysicsObject
   Desc:	For the Physgun, adds a frozen object to the player's list
---------------------------------------------------------*/  
function meta:AddFrozenPhysicsObject( ent, phys )

	// Get the player's table
	local tab = self:GetTable()
	
	// Make sure the physics objects table exists
	tab.FrozenPhysicsObjects = tab.FrozenPhysicsObjects or {}
	
	// Make a new table that contains the info
	local entry = {}
	entry.ent 	= ent
	entry.phys 	= phys
	
	// Put it in the physics objects table
	table.insert( tab.FrozenPhysicsObjects, entry )

end


/*---------------------------------------------------------
   Name:	UnfreezePhysicsObjects
   Desc:	For the Physgun, unfreezes all frozen physics objects
---------------------------------------------------------*/  
function meta:UnfreezePhysicsObjects( ent, phys )

	// Get the player's table
	local tab = self:GetTable()
	
	// If the table doesn't exist then quit here
	if (!tab.FrozenPhysicsObjects) then return 0 end
	
	local Count = 0
	
	// Loop through each table in our table
	for k, v in pairs( tab.FrozenPhysicsObjects ) do
	
		// Make sure the entity to which the physics object
		// is attached is still valid (still exists)
		if (v.ent:IsValid()) then
		
			// We can't directly test to see if EnableMotion is false right now
			// but IsMovable seems to do the job just fine.
			// We only test so the count isn't wrong
			if (v.phys && !v.phys:IsMoveable()) then
			
				// We need to freeze/unfreeze all physobj's in jeeps to stop it spazzing
				if (v.ent:GetClass() == "prop_vehicle_jeep") then
				
					// How many physics objects we have
					local objects = v.ent:GetPhysicsObjectCount()
	
					// Loop through each one
					for i=0, objects-1 do
		
						local physobject = v.ent:GetPhysicsObjectNum( i )
						physobject:EnableMotion( true )
						physobject:Wake()
				
					end
					
				end
			
				v.phys:EnableMotion( true )
				v.phys:Wake()
				Count = Count + 1
				
			end
		
		end
	
	end
			
	// Remove the table
	tab.FrozenPhysicsObjects = nil
	
	return Count

end

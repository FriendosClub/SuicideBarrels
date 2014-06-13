include( 'shared.lua' )
include( 'cl_scoreboard.lua' )
include( 'cl_targetid.lua' )
include( 'cl_hudpickup.lua' )
include( 'cl_spawnmenu.lua' )
include( 'vgui/vgui_gamenotice.lua' )
include( 'cl_deathnotice.lua' )
include( 'sh_roundtimer.lua' )

if SERVER then
	local ply = FindMetaTable("Player")
	local plyo = player.GetByID(1)

	-- util.AddNetworkString( "sendPlayerTeamSwitchHumans" )
	-- util.AddNetworkString( "sendPlayerTeamSwitchBarrels" )
	
	-- net.Receive( "sendPlayerTeamSwitchHumans",
		-- function(plyo, ply)
		-- ply:Kill( )
		-- ply:SetTeam( TEAM_HUMANS )
		-- ply:PrintMessage(HUD_PRINTTALK,"You're now on the Humans team, press 'E' to open the Team Swap menu.")
		-- ply:SprintEnable()
		-- ply:AddFrags(1)
	-- end)
	
	-- net.Receive( "sendPlayerTeamSwitchBarrels",
		-- function(plyo, ply)
		-- ply:Kill( )
		-- ply:SetTeam( TEAM_BARRELS )
		-- ply:PrintMessage(HUD_PRINTTALK,"You're now on the Barrels team, press 'E' to open the Team Swap menu.")
		-- ply:SprintEnable()
		-- ply:AddFrags(1)
	-- end)
elseif CLIENT then
	surface.CreateFont('ScoreboardHeadHuge', { font = 'MenuLarge', size = 78, weight = 500})
	surface.CreateFont('ScoreboardHead', { font = 'MenuLarge', size = 48, weight = 500})
	surface.CreateFont('ScoreboardSub', { font = 'MenuLarge', size = 24, weight = 500})
	surface.CreateFont('ScoreboardText', { font = 'MenuLarge', size = 16, weight = 1000})
end


/*---------------------------------------------------------
   Name: gamemode:Initialize( )
   Desc: Called immediately after starting the gamemode 
---------------------------------------------------------*/
function GM:Initialize( )

	GAMEMODE.ShowScoreboard = false
	
end

/*---------------------------------------------------------
   Name: gamemode:InitPostEntity( )
   Desc: Called as soon as all map entities have been spawned
---------------------------------------------------------*/
function GM:InitPostEntity( )	
end


/*---------------------------------------------------------
   Name: gamemode:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function GM:Think( )
end

function GM:KeyPressed( pl, key )

end

function GM:OnKeyRelease( pl, key )

		
end

function GM:HUDDrawTargetID()

	local tr = util.GetPlayerTrace( LocalPlayer(), LocalPlayer():GetAimVector() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end
	
	local text = "ERROR"
	local font = "TargetID"
	
	if (trace.Entity:IsPlayer()) and ( trace.Entity:Team() == TEAM_HUMANS )then
		text = trace.Entity:Nick()
	else
		return
	end
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	
	local x, y = gui.MousePos()
	
	x = 0
	y = y + 30
	
	// The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
	
	y = y + h + 5
	
	local text = trace.Entity:Health() .. ""
	local font = "TargetIDSmall"
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x =  gui.MouseX()  - w / 2
	
	draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,120) )
	draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,50) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies. If the attacker was
		  a player then attacker will become a Player instead
		  of an Entity. 		 
---------------------------------------------------------*/
function GM:PlayerDeath( victim, inflictor, attacker )

	// Delay player spawn by 3 seconds
	victim:GetTable().NextSpawnTime = CurTime() + 3

	// Convert the inflictor to the weapon that they're holding if we can.
	// This can be right or wrong with NPCs since combine can be holding a 
	// pistol but kill you by hitting you with their arm.
	if ( inflictor && inflictor == attacker && (inflictor:IsPlayer() || inflictor:IsNPC()) ) then
	
		inflictor = inflictor:GetActiveWeapon()
		if ( inflictor == NULL ) then inflictor = attacker end
	
	end
	
	if ( attacker:Team( )== TEAM_HUMANS ) and ( victim:Team( )== TEAM_BARRELS ) then
		local ent = ents.Create( "env_explosion" )
			ent:SetPos( victim:GetPos() )
			ent:SetKeyValue( "iMagnitude", "100" )
			ent:SetOwner( victim )
			ent:Spawn()
			ent:Fire( "Explode", 0, 0 )
		end
	
	if ( attacker:Team( )== TEAM_BARRELS ) and ( victim:Team( )== TEAM_HUMANS ) then
		victim:SetTeam(TEAM_BARRELS)
	end
	
	if (attacker == victim) and ( attacker:Team( )== TEAM_BARRELS ) then
		return; 
	end

	if (attacker == victim) and ( attacker:Team( )== TEAM_HUMANS ) then
		umsg.Start( "PlayerKilledSelf" )
			umsg.Entity( victim )
		umsg.End()
		
	return end

	if ( attacker:IsPlayer() ) then
	
		umsg.Start( "PlayerKilledByPlayer" )
		
			umsg.Entity( victim )
			umsg.String( inflictor:GetClass() )
			umsg.Entity( attacker )
		
		umsg.End()
		
	return end
	
	umsg.Start( "PlayerKilled" )
	
		umsg.Entity( victim )
		umsg.String( inflictor:GetClass() )
		umsg.String( attacker:GetClass() )

	umsg.End()
end

/*---------------------------------------------------------
   Name: gamemode:PlayerBindPress( )
   Desc: A player pressed a bound key - return true to override action		 
---------------------------------------------------------*/
function GM:PlayerBindPress( pl, bind, down )
	return false	
end

/*---------------------------------------------------------
   Name: gamemode:HUDShouldDraw( name )
   Desc: return true if we should draw the named element
---------------------------------------------------------*/
function GM:HUDShouldDraw( name )

	// Allow the weapon to override this
	local ply = LocalPlayer()
	if (ply && ply:IsValid()) then
	
		local wep = ply:GetActiveWeapon()
		
		if (wep && wep:IsValid() && wep:GetTable().HUDShouldDraw != nil) then
		
			return wep:GetTable().HUDShouldDraw( wep, name )
			
		end
		
	end

	return true;
end

/*---------------------------------------------------------
   Name: gamemode:HUDPaint( )
   Desc: Use this section to paint your HUD
---------------------------------------------------------*/
function GM:HUDPaint()
	GAMEMODE:HUDDrawPickupHistory()
	GAMEMODE:DrawDeathNotice( 0.85, 0.04 )
	GAMEMODE:HUDDrawTargetID()
end

/*---------------------------------------------------------
   Name: gamemode:HUDPaintBackground( )
   Desc: Same as HUDPaint except drawn before
---------------------------------------------------------*/
function GM:HUDPaintBackground()
end

/*---------------------------------------------------------
   Name: gamemode:CreateMove( command )
   Desc: Allows the client to change the move commands 
			before it's send to the server
---------------------------------------------------------*/
function GM:CreateMove( cmd )
end

/*---------------------------------------------------------
   Name: gamemode:GUIMousePressed( mousecode )
   Desc: The mouse has been pressed on the game screen
---------------------------------------------------------*/
function GM:GUIMousePressed( mousecode )

end

/*---------------------------------------------------------
   Name: gamemode:GUIMouseReleased( mousecode )
   Desc: The mouse has been released on the game screen
---------------------------------------------------------*/
function GM:GUIMouseReleased( mousecode )

end

/*---------------------------------------------------------
   Name: gamemode:GUIMouseReleased( mousecode )
   Desc: The mouse was double clicked
---------------------------------------------------------*/
function GM:GUIMouseDoublePressed( mousecode )
	// We don't capture double clicks by default, 
	// We just treat them as regular presses
	GAMEMODE:GUIMousePressed( mousecode )
end

/*---------------------------------------------------------
   Name: gamemode:ShutDown( )
   Desc: Called when the Lua system is about to shut down
---------------------------------------------------------*/
function GM:ShutDown( )
end


/*---------------------------------------------------------
   Name: gamemode:RenderScreenspaceEffects( )
   Desc: Bloom etc should be drawn here (or using this hook)
---------------------------------------------------------*/
function GM:RenderScreenspaceEffects()
end

/*---------------------------------------------------------
   Name: gamemode:GetVehicles( )
   Desc: Gets the vehicles table..
---------------------------------------------------------*/
function GM:GetVehicles()

	return vehicles.GetTable()     
	
end


/*---------------------------------------------------------
   Name: CalcView
   Allows override of the default view
---------------------------------------------------------*/
local TPerson = true
local RView = 20 // How far back
local ply = player.GetByID(1)
local view = {}
function MyCalcView(ply, pos, angles, fov)
	if ply:Team() == TEAM_BARRELS then
		local view = {}
		view.origin = pos-(angles:Forward()*140)
		view.angles = angles
		view.fov = fov
	 
		return view
	end
end
hook.Add("CalcView", "MyCalcView", MyCalcView)

hook.Add("ShouldDrawLocalPlayer", "MyHax ShouldDrawLocalPlayer", function(ply)
	if ply:Team() == TEAM_BARRELS then
		return true
	else
		return false
	end
end)
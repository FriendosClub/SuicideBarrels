round = {}

-- round.MinPlayers 	= GetGlobalInt("sb_minplayers", 2)
barrelKillScore 	= 3 -- GetConVarNumber( "sb_bkillscore" )
humanKillScore 		= 1 -- GetConVarNumber( "sb_hkillscore" )

-- Timing (In seconds)
-- round.Break		= GetGlobalInt("sb_breaktime", 15)
round.Time		= GetGlobalInt("sb_roundtime", 2)
round.WarnTime 	= 10 -- GetConVarNumber( "sb_warntime" )

-- Read Variables (IGNORE THESE)
round.TimeLeft 		= -1
round.RoundCur 		= 0
round.HumanWins 	= 0
round.BarrelWins 	= 0
round.Breaking 		= false
round.Active 		= false
round.EnblEnd 		= true

if CLIENT then
	surface.CreateFont( "RoundFont", {
	font = "DermaDefault",
	size = 20
	
	})
end

function round.Broadcast(Text)
	for k, v in pairs(player.GetAll()) do
		v:ConCommand("play buttons/button17.wav")
		v:ChatPrint(Text)
	end
end

function enoughPlayers()
	local numPlayers = 0

	if table.Count(player.GetAll()) >= GetGlobalInt("sb_minplayers", 2) then
		if SERVER then		
			for k, v in pairs(player.GetAll()) do
				if IsValid(v) then
					v:PrintMessage(HUD_PRINTCENTER, "Round started! You have " .. GetGlobalInt("sb_roundtime", 2) .. " minutes!")
					v:SetTeam(TEAM_HUMANS)
					v:Spawn()
					v:StripWeapon("sb_barrelsuicider")
				end
			end
				
			local randomply = table.Random(player.GetAll())
				
			randomply:SetTeam(TEAM_BARRELS)
			randomply:Spawn()
			randomply:StripWeapon("sb_barrelslayer")
			randomply:PrintMessage(HUD_PRINTCENTER, "Round started! You are a Barrel! You have " .. GetGlobalInt("sb_roundtime", 2) .. " minutes to eliminate the humans!")
		end
		round.TimeLeft = ( GetGlobalInt("sb_roundtime", 2) * 60 )
		round.Active = true
		round.RoundCur = round.RoundCur + 1
	elseif table.Count(player.GetAll()) < GetGlobalInt("sb_minplayers", 2) then
		if SERVER then
			for k, v in pairs(player.GetAll()) do
				if IsValid(v) then
					v:SetTeam(TEAM_SPECTATOR)
				end
			end
		end
		round.Active = false
	end
end

function round.Begin()
	enoughPlayers()
end

function round.End()
	if SERVER then
		if (team.NumPlayers (TEAM_HUMANS)) >= 1 then
			for k, v in pairs(player.GetAll()) do
			 v:PrintMessage(HUD_PRINTCENTER, "Humans Win! Next round in " .. GetGlobalInt("sb_breaktime", 15) .. " seconds!")
			 v:KillSilent()
			 v:SetTeam(TEAM_SPECTATOR)
			end
		elseif (team.NumPlayers (TEAM_HUMANS)) < 1 or nil then
			for k, v in pairs(player.GetAll()) do
			 v:PrintMessage(HUD_PRINTCENTER, "Barrels Win! Next round in " .. GetGlobalInt("sb_breaktime", 15) .. " seconds!")
			 v:KillSilent()
			 v:SetTeam(TEAM_SPECTATOR)
			end
		elseif (team.NumPlayers (TEAM_BARRELS)) < 1 or nil then
			for k, v in pairs(player.GetAll()) do
			 v:PrintMessage(HUD_PRINTCENTER, "The Barrels Left! Next round in " .. GetGlobalInt("sb_breaktime", 15) .. " seconds!")
			 v:KillSilent()
			 v:SetTeam(TEAM_SPECTATOR)
			end
		end
	end

	if (team.NumPlayers (TEAM_HUMANS)) >= 1 then
		round.HumanWins = round.HumanWins + 1
	elseif (team.NumPlayers (TEAM_HUMANS)) < 1 or nil then
		round.BarrelWins = round.BarrelWins + 1
	end
	
	round.TimeLeft = GetGlobalInt("sb_breaktime", 15)
	round.Active = false
end

function round.Handle()
	if (round.TimeLeft == -1) then -- Start the first round
		round.Begin()
		return
	end
	
	round.TimeLeft = round.TimeLeft - 1
	
	if (round.TimeLeft == 0) then
		if (round.Breaking) then
			round.Begin()
			round.Breaking = false
		else
			if round.EnblEnd == false then
				round.End()
				round.Breaking = true
			elseif round.EnblEnd == true then
				round.EnblEnd = false
			end
		end
	end
end

function util.SimpleTime(seconds, fmt)
if not seconds then seconds = 0 end

    local ms = (seconds - math.floor(seconds)) * 100
    seconds = math.floor(seconds)
    local s = seconds % 60
    seconds = (seconds - s) / 60
    local m = seconds % 60

    return string.format(fmt, m, s, ms)
end

function WinTest()
	if table.Count(player.GetAll()) >= GetGlobalInt("sb_minplayers", 2) then
		if ((team.NumPlayers (TEAM_HUMANS)) or (team.NumPlayers (TEAM_BARRELS)) ) < 1 and round.Breaking == false and round.Active == true then
			round.End()
			round.EnblEnd = true
		else
			return
		end
	end
end
hook.Add("Think", "WinTesting", WinTest)

function round.IsActive()
	if round.Breaking == false and round.Active == true then
		return "Round Active"
	elseif round.Breaking == true and round.Active == false then
		return "Round Over"
	elseif round.Active == false and table.Count(player.GetAll()) < GetGlobalInt("sb_minplayers", 2) then
		return "Not Enough Players"
	elseif round.EnblEnd == true then
		return "Round Over"
	else
		return "Refreshing"
	end
end

function round.GetTimeClose()
	if round.Active == true then
		if (round.TimeLeft > round.WarnTime) then
			return color_white
		elseif (round.TimeLeft <= round.WarnTime) then
			return Color(255,0,0)
		end
	else
		return color_white
	end
end

round.HUD = function()
	local text = util.SimpleTime(math.max(0, round.TimeLeft), "%02i:%02i")
	local roundIsActive = round.IsActive()
	
	draw.SimpleTextOutlined(text, "DermaLarge", ScrW()/2, 20, round.GetTimeClose(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	draw.SimpleTextOutlined(roundIsActive, "RoundFont", ScrW()/2, 40, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
end
hook.Add("HUDPaint", "Draw Round Timer display.", round.HUD)

timer.Create("round.Handle", 1, 0, round.Handle)

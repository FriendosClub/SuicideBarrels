
// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Left Click to make yourself EXPLODE. Right click to taunt."
SWEP.DrawCrosshair		= false

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true		// Spawnable in singleplayer or by server admins

SWEP.ViewModel			= ""
SWEP.WorldModel			= ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

local ShootSound = Sound( "vo/k_lab/kl_ahhhh.wav" )

TAUNTS = {

	"vo/npc/male01/behindyou01.wav",
	"vo/npc/male01/behindyou02.wav",
	"vo/npc/male01/zombies01.wav",
	"vo/npc/male01/watchout.wav",
	"vo/npc/male01/upthere01.wav",
	"vo/npc/male01/upthere02.wav",
	"vo/npc/male01/thehacks01.wav",
	"vo/npc/male01/strider_run.wav",
	"vo/npc/male01/runforyourlife01.wav",
	"vo/npc/male01/runforyourlife02.wav",
	"vo/npc/male01/runforyourlife03.wav"
	
}


/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()	
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire( CurTime() + 20 )
	
	// The rest is only done on the server
	if (!SERVER) then return end
	
	// Make an explosion at your position
	self.Owner.KeyOnce = true
	
	if IsValid(self.Owner) then
		if self.Owner:Alive() then
				self.Owner:SetHealth(1)
				timer.Simple( .1, function() if self.Owner:Alive() and IsValid(self.Owner) then self.Owner:EmitSound( "Grenade.Blip" ) end end )
				timer.Simple( .6, function() if self.Owner:Alive() and IsValid(self.Owner) then self.Owner:EmitSound( "Grenade.Blip" ) end end )
				timer.Simple( 1.1, function() if self.Owner:Alive() and IsValid(self.Owner) then self.Owner:EmitSound( "Weapon_CombineGuard.Special1" ) end end )
				timer.Simple( 1.5, function() if self.Owner:Alive() and IsValid(self.Owner) then 
					local ent = ents.Create( "env_explosion" )
					ent:SetPos( self.Owner:GetPos() )
					ent:SetOwner( self.Owner )
					ent:Spawn()
					ent:SetKeyValue( "iMagnitude", "150" )
					ent:Fire( "Explode", 0, 0 )
					self.Owner:Kill() 
					self.Owner:ViewPunch( Angle( -3, 0, 0 ) )
				end end )
		elseif !self.Owner:Alive() then
			return
		end
	end

end



/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()	
	
	self.Weapon:SetNextSecondaryFire( CurTime() + 2 )
	
	local TauntSound = table.Random( TAUNTS )

	self.Weapon:EmitSound( TauntSound , 100, math.Rand(110,135))
	
	// The rest is only done on the server
	if (!SERVER) then return end
	
	self.Weapon:EmitSound( TauntSound , 100, math.Rand(100,175))


end

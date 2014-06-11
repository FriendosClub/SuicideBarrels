
// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Left Click to shoot"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true		// Spawnable in singleplayer or by server admins

SWEP.ViewModel			= "models/weapons/v_357.mdl "
SWEP.WorldModel			= "models/weapons/w_357.mdl "

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 999
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"
SWEP.Primary.Damage   		= 100

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

local ShootSound = Sound( "vo/k_lab/kl_ahhhh.wav" )

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
	if ( !self:CanPrimaryAttack() ) then return end

	self.Weapon:EmitSound( self.Primary.Sound )
	self:ShootBullet( 150, 1, 0.01 )
	self:TakePrimaryAmmo( 1 )
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()	
end


function SWEP:Reload()
	if self.ReloadingTime and CurTime() <= self.ReloadingTime then return end
 
	if ( self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
 
		self:DefaultReload( ACT_VM_RELOAD )
                local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
                self.ReloadingTime = CurTime() + AnimationTime
                self:SetNextPrimaryFire(CurTime() + AnimationTime)
                self:SetNextSecondaryFire(CurTime() + AnimationTime)
 
	end
	
	timer.Simple(0.3,function() self.Weapon:EmitSound("weapons/AYKAYFORTY/Bolt.wav") end)
	timer.Simple(0.5,function() self.Weapon:EmitSound("weapons/AYKAYFORTY/MagTap.wav") end)
	timer.Simple(0.5,function() self.Weapon:EmitSound("weapons/AYKAYFORTY/Magout.wav") end)
	timer.Simple(0.7,function() self.Weapon:EmitSound("weapons/AYKAYFORTY/Magin.wav") end)
end




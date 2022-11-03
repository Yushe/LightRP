AddCSLuaFile()

if CLIENT then
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.PrintName = "Keys"
SWEP.Author = "Rick Darkaliono, philxyz, Fixed by Yushe."
SWEP.Instructions = "Left click to lock. Right click to unlock"
SWEP.Contact = ""
SWEP.Purpose = ""

SWEP.WorldModel = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "DarkRP (Utility)"
SWEP.Sound = "doors/door_latch3.wav"

SWEP.Primary.Delay = 0.3
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.Delay = 0.3
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    if CLIENT or not IsValid(self:GetOwner()) then return true end
    self:GetOwner():DrawWorldModel(false)
    return true
end

function SWEP:Holster()
    return true
end

function SWEP:PreDrawViewModel()
    return true
end

local function lookingAtLockable(ply, ent, hitpos)
    local eyepos = ply:EyePos()
    return IsValid(ent)
        and ent:isKeysOwnable()
        and (
            ent:isDoor() and eyepos:DistToSqr(hitpos) < 2000
            or
            ent:IsVehicle() and eyepos:DistToSqr(hitpos) < 4000
        )
end

local function lockUnlockAnimation(ply, snd)
    ply:EmitSound("npc/metropolice/gear" .. math.random(1, 6) .. ".wav")
    timer.Simple(0.9, function() if IsValid(ply) then ply:EmitSound(snd) end end)

    umsg.Start("anim_keys")
        umsg.Entity(ply)
        umsg.String("usekeys")
    umsg.End()

    ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
end

local function doKnock(ply, sound)
    ply:EmitSound(sound, 100, math.random(90, 110))

    umsg.Start("anim_keys")
        umsg.Entity(ply)
        umsg.String("knocking")
    umsg.End()

    ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true)
end

function SWEP:PrimaryAttack()
	if CLIENT then return end

	local trace = self.Owner:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or trace.Entity:GetNWBool("nonOwnable") then
		return
	end

	if trace.Entity:IsDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65 then
		return
	end

	if trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100 then
		return
	end

	if trace.Entity:OwnedBy(self.Owner) then
		trace.Entity:Fire("lock", "", 0)
		self.Owner:EmitSound(self.Sound)
		self.Weapon:SetNextPrimaryFire(CurTime() + 1.0)
	else
		if trace.Entity:IsVehicle() then
			Notify(self.Owner, 1, 3, "You don't own this vehicle!")
		else
			Notify(self.Owner, 1, 3, "You don't own this door!")
		end
		self.Weapon:SetNextPrimaryFire(CurTime() + .5)
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end

	local trace = self.Owner:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or trace.Entity:GetNWBool("nonOwnable") then
		return
	end

	if trace.Entity:IsDoor() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 65 then
		return
	end

	if trace.Entity:IsVehicle() and self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 100 then
		return
	end

	if trace.Entity:OwnedBy(self.Owner) then
		trace.Entity:Fire("unlock", "", 0)

		self.Owner:EmitSound(self.Sound)
		self.Weapon:SetNextPrimaryFire(CurTime() + 1.0)
	else
		if trace.Entity:IsVehicle() then
			Notify(self.Owner, 1, 3, "You don't own this vehicle!")
		else
			Notify(self.Owner, 1, 3, "You don't own this door!")
		end
		self.Weapon:SetNextPrimaryFire(CurTime() + .5)
	end
end

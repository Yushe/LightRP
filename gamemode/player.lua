CivModels = {
	"models/player/gman_high.mdl",
	"models/player/breen.mdl",
	"models/player/monk.mdl",
	"models/player/odessa.mdl",
	"models/player/barney.mdl",
	"models/player/alyx.mdl",
	"models/player/kleiner.mdl",
	"models/player/mossman.mdl"
}

local meta = FindMetaTable("Player")

-- Each time a player connects, they get a new ID
sessionid = 0

function meta:InitSID()
	sessionid = sessionid + 1
	self.SID = sessionid
end

function meta:NewData()
	local function ModuleDelay(ply)
		umsg.Start("LoadModules", ply) 
			umsg.Short(#CSFiles)
			for n = 1, #CSFiles do
				umsg.String(CSFiles[n])
			end
		umsg.End()
	end

	local me = self
	timer.Simple(.01, function() ModuleDelay(me) end)

	self:UpdateJob("Citizen")

	self:GetTable().Pay = 0
	self:GetTable().LastPayDay = CurTime()

	self:GetTable().Owned = {}
	self:GetTable().OwnedNum = 0

	self:GetTable().LastLetterMade = CurTime()
	self:GetTable().LastVoteCop = CurTime()

	self:SetTeam(TEAM_CITIZEN)

	-- Whether or not a player is being prevented from joining
	-- a specific team for a certain length of time
	self.bannedfrom = {}
	for i = 1, 9 do
		self.bannedfrom[i] = 0
	end

	if self:IsSuperAdmin() or self:IsAdmin() then
		self:GrantPriv(ADMIN)
	end
end

function meta:HasPriv(priv)
	return DB.HasPriv(self, priv)
end

function meta:GrantPriv(priv)
	return DB.GrantPriv(self, priv)
end

function meta:ChangeAllowed(t)
	if self.bannedfrom[t] == 1 then return false else return true end
end

function FinishVoteOW(choice, ply)
	VoteCopOn = false

	if choice == 1 then
		ply:SetTeam(TEAM_OVERWATCH)
		ply:UpdateJob("OverWatch")
		ply:KillSilent()

		NotifyAll(1, 4, ply:Nick() .. " has been made OverWatch!")
	else
		NotifyAll(1, 4, ply:Nick() .. " has not been made OverWatch!")
	end
end


function meta:ChangeTeam(t)
	if self:GetTable().Arrested then
		if not self:Alive() then
			Notify(self, 1, 4, "Can not change your job while dead in jail.")
			return
		else
			Notify(self, 1, 4, "You are in Jail. Get a new job when you have been released.")
			return
		end
	end

	if t ~= TEAM_CITIZEN and not self:ChangeAllowed(t) then
		Notify(self, 1, 4, "You were demoted! Please wait a while before taking your old job back.")
		return
	end

	if t == TEAM_CITIZEN then
		self:UpdateJob("Citizen")
		self:
		NotifyAll(1, 4, self:Name() .. " is now an ordinary Citizen!")
	elseif t == TEAM_POLICE then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already a CP!")
			return
		end

		if team.NumPlayers(t) >= CfgVars["maxcps"] then
			Notify(self, 1, 4,  "Max CPs reached!")
			return
		end

		self:UpdateJob("Civil Protection")
	elseif t == TEAM_OVERWATCH then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already in the Overwatch!")
			return
		end

		if CfgVars["cptoowonly"] == 1 and self:Team() ~= TEAM_POLICE then
			Notify(self, 1, 4, "You must become a CP first!")
			return
		end

		if team.NumPlayers(t) >= 1 then
			Notify(self, 1, 4,  "Max Overwatch reached!")
			return
		end

		self:UpdateJob("Overwatch")
	end

	self:SetTeam(t)
	if self:InVehicle() then self:ExitVehicle() end
	self:KillSilent()
end

function meta:ResetDMCounter()
	if killer ~= ply then
		self.kills = 0
		return true
	end
end

function meta:CanAfford(amount)
	if math.floor(amount) < 0 or DB.RetrieveMoney(self) - math.floor(amount) < 0 then return false end

	return true
end

function meta:AddMoney(amount)
	DB.StoreMoney(self, DB.RetrieveMoney(self) + math.floor(amount))
end

function meta:PayDay()
	if not self:GetTable().Arrested then
		local amount = 0
		if not self:GetNWBool("employed") then
			Notify(self, 4, 4, "You are unemployed!")
			return
		elseif self:Team() == TEAM_CITIZEN then
			amount = math.random(35, 60)
		else
			amount = math.random(50, 80)
		end
		self:AddMoney(amount)
		Notify(self, 4, 4, "Payday! You received " .. CUR .. amount .. "!")
	else
		Notify(self, 4, 4, "Pay day missed! (arrested)")
	end
end

function meta:UpdateJob(job)
	self:SetNWString("job", job)
	self:GetTable().Pay = 1
	self:GetTable().LastPayDay = CurTime()

	local l = string.lower(job)

	if l == "unemployed" or l == "bum" or l == "hobo" then
		self:SetNWBool("employed", false)
	else
		self:SetNWBool("employed", true)
		timer.Create(self:SteamID() .. "jobtimer", CfgVars["paydelay"], 0, function()
			self:PayDay()
		end)
	end
end

function meta:TeamUnBan(team)
	self.bannedfrom[team] = 0
end

function meta:TeamBan()
	self.bannedfrom[self:Team()] = 1
	local me = self
	timer.Simple(CfgVars["demotetime"], function() me:TeamUnBan(me:Team()) end)
end

function meta:Arrest(time)
	if self:GetNWBool("wanted") then
		self:SetNetworkedBool("wanted", false)
	end
	-- Always get sent to jail when Arrest() is called, even when already under arrest
	if CfgVars["teletojail"] == 1 then
		self:SetPos(DB.RetrieveJailPos())
	end
	if not self:GetTable().Arrested then
		self:StripWeapons()
		self:GetTable().Arrested = true
		self.LastJailed = CurTime()

		-- If the player has no remaining jail time,
		-- set it back to the max for this new sentence
		if not time or time == 0 then
			time = GetGlobalInt("jailtimer")
		end
		DB.StoreJailStatus(self, time)
		self:PrintMessage(HUD_PRINTCENTER, "You have been arrested for " .. time .. " seconds!")
		for k, v in pairs(player.GetAll()) do
			if v ~= self then
				v:PrintMessage(HUD_PRINTCENTER, self:Name() .. " has been arrested for " .. time .. " seconds!")
			end
		end
		timer.Create(self:SteamID() .. "jailtimer", time, 1, function() self.Unarrest() end)
	end
end

function meta:Unarrest()
	if self and self:GetTable().Arrested then
		self:GetTable().Arrested = false
		if CfgVars["telefromjail"] == 1 then
			self:SetPos(GAMEMODE:PlayerSelectSpawn(self):GetPos())
		end
		GAMEMODE:PlayerLoadout(self)
		DB.StoreJailStatus(self, 0)
		timer.Stop(self:SteamID() .. "jailtimer")
		timer.Destroy(self:SteamID() .. "jailtimer")
		NotifyAll(1, 4, self:Name() .. " has been released from jail!")
	end
end

function meta:CompleteSentence()
	if not IsValid(ply) or not self:SteamID() then return end
	
	local time = DB.RetrieveJailStatus(self)

	if time == 0 or not DB.RetrieveJailPos() then
		-- No outstanding jail time to be done
		return ""
	else
		-- Don't pick up the soap this time
		self:Arrest(time)
		Notify(self, 0, 5, "Punishment for disconnecting! Jailed for: " .. time .. " seconds.")
	end
end

function meta:UnownAll()
	for k, v in pairs(ents.GetAll()) do
		if v:IsOwnable() and v:OwnedBy(self) == true then
			v:Fire("unlock", "", 0.6)
		end
	end

	for k, v in pairs(self:GetTable().Owned) do
		v:UnOwn(self)
		self:GetTable().Owned[v:EntIndex()] = nil
	end

	for k, v in pairs(player.GetAll()) do	
		for n, m in pairs(v:GetTable().Owned) do
			if m:AllowedToOwn(self) then
				m:RemoveAllowed(self)
			end
		end
	end

	self:GetTable().OwnedNum = 0
end

function meta:DoPropertyTax()
	if CfgVars["propertytax"] == 0 then return end
	if (self:Team() == TEAM_POLICE or self:Team() == TEAM_OVERWATCH) and CfgVars["cit_propertytax"] == 1 then return end

	local numowned = self:GetTable().OwnedNum
	if numowned <= 0 then return end

	local price = 10
	local tax = price * numowned + math.random(-10, 10)

	if self:CanAfford(tax) then
		if tax == 0 then
			Notify(self, 1, 5, "No Property Tax - You don't own anything.")
		else
			self:AddMoney(-tax)
			Notify(self, 1, 5, "Property tax! " .. CUR .. tax)
		end
	else
		Notify(self, 1, 8, "Can't pay the taxes! Your property has been taken away from you!")
		self:UnownAll()
	end
end

function GM:CanTool(ply, trace, mode)
	if not self.BaseClass:CanTool(ply, trace, mode) then return false end

	if IsValid(trace.Entity) then
		if trace.Entity.onlyremover then
			if mode == "remover" then
				return (ply:IsAdmin() or ply:IsSuperAdmin())
			else
				return false
			end
		end

		if trace.Entity.nodupe and (mode == "weld" or
					mode == "weld_ez" or
					mode == "spawner" or
					mode == "duplicator" or
					mode == "adv_duplicator") then
			return false
		end

		if trace.Entity:IsVehicle() and mode == "nocollide" and CfgVars["allowvnocollide"] == 0 then
			return false
		end
	end
	return true
end

function GM:CanPlayerSuicide(ply)
	if ply:GetTable().Arrested then
		Notify(ply, 4, 4, "You are on suicide watch!")
		return false
	end
	return true
end

function GM:PlayerDeath(ply, weapon, killer)
	--[[
	if ply:HasWeapon("weapon_physcannon") then
		ply:DropWeapon(ply:GetWeapon("weapon_physcannon"))
	end
	]]
	for _, wep in ipairs( ply:GetWeapons() ) do
		ply:DropWeapon( wep )
	end

	if weapon:IsVehicle() and weapon:GetDriver():IsPlayer() then killer = weapon:GetDriver() end
	if GetGlobalInt("deathnotice") == 1 then
		self.BaseClass:PlayerDeath(ply, weapon, killer)
	end

	ply:Extinguish()

	if ply:InVehicle() then ply:ExitVehicle() end

	if ply:GetTable().Arrested == true then
		-- If the player died in jail, make sure they can't respawn until their jail sentance is over
		ply.NextSpawnTime = CurTime() + math.ceil(GetGlobalInt("jailtimer") - (CurTime() - ply.LastJailed)) + 1
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, ply:Nick() .. " has died in jail!")
		end
		Notify(ply, 4, 4, "You now are dead until your jail time is up!")
	else
		-- Normal death, respawn allowed in 4 seconds
		ply.NextSpawnTime = CurTime() + 4
	end
	ply:GetTable().DeathPos = ply:GetPos()

	if CfgVars["dmautokick"] == 1 and killer:IsPlayer() and killer ~= ply then
		if not killer.kills or killer.kills == 0 then
			killer.kills = 1
			timer.Simple(CfgVars["dmgracetime"], function() killer:ResetDMCounter() end)
		else
			-- if this player is going over their limit, kick their ass
			if killer.kills + 1 > CfgVars["dmmaxkills"] then
				game.ConsoleCommand("kickid " .. killer:UserID() .. " Auto-kicked. Go and play HL2:DM\n")
			else
				-- killed another player
				killer.kills = killer.kills + 1
			end
		end
	end

	if ply ~= killer or ply:GetTable().Slayed  then
		ply:GetTable().Arrested = false
		ply:GetTable().DeathPos = nil
		ply:GetTable().Slayed = false
	end
end

function GM:PlayerCanPickupWeapon(ply, class)
	if ply:GetTable().Arrested then return false end

	return true
end

function GM:PlayerCanPickupWeapon(ply, class)
	if ply:GetTable().Arrested then return false end

	return true
end

function GM:GravGunPunt(ply, ent)
	if ent:IsVehicle() then return false end

	local entphys = ent:GetPhysicsObject()

	if ply:KeyDown(IN_ATTACK) then
		-- it was launched
		entphys:EnableMotion(false)
		local curpos = ent:GetPos()
		timer.Simple(.01, function() entphys:EnableMotion(true) end)
		timer.Simple(.01, function() entphys:Wake() end)
		timer.Simple(.01, function() ent:SetPos(curpos) end)
	else
		return true
	end
end

function GM:GravGunOnDropped(ply, ent)
	local entphys = ent:GetPhysicsObject()
	if ply:KeyDown(IN_ATTACK) then
		-- it was launched
		entphys:EnableMotion(false)
		local curpos = ent:GetPos()
		timer.Simple(.01, function() entphys:EnableMotion(true) end)
		timer.Simple(.01, function() entphys:Wake() end)
		timer.Simple(.01, function() ent:SetPos(curpos) end)
	else
		return true
	end
end

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn(ply)
	ply:CrosshairEnable()

	if CfgVars["crosshair"] == 0 then
		ply:CrosshairDisable()
	end

	if CfgVars["strictsuicide"] == 1 and ply:GetTable().DeathPos then
		if not (ply:GetTable().Arrested) then
			ply:SetPos(ply:GetTable().DeathPos)
		end
	end

	-- If the player for some magical reason managed to respawn while jailed then re-jail the bastard.
	if ply:GetTable().Arrested and ply:GetTable().DeathPos then
		-- For when CfgVars["teletojail"] == 0
		ply:SetPos(ply:GetTable().DeathPos)
		-- Not getting away that easily, Sonny Jim.
		if DB.RetrieveJailPos() then
			ply:Arrest()
		else
			Notify(ply, 1, 4, "You're no longer under arrest because no jail positions are set!")
		end
	end

	if ply:Team() == TEAM_CITIZEN and CfgVars["enforceplayermodel"] == 1 then
		local validmodel = false

		for k, v in pairs(CivModels) do
			if ply:GetTable().PlayerModel == v then
				validmodel = true
				break
			end
		end

		if not validmodel then
			ply:GetTable().PlayerModel = nil
		end

		local model = ply:GetModel()

		if model ~= ply:GetTable().PlayerModel then
			for k, v in pairs(CivModels) do
				if v == model then
					ply:GetTable().PlayerModel = model
					validmodel = true
					break
				end
			end

			if not validmodel and not ply:GetTable().PlayerModel then
				ply:GetTable().PlayerModel = CivModels[math.random(1, #CivModels)]
			end

			ply:SetModel(ply:GetTable().PlayerModel)
		end
	elseif ply:Team() == TEAM_POLICE then
		ply:SetModel("models/player/police.mdl")
	elseif ply:Team() == TEAM_OVERWATCH then
		ply:SetModel("models/player/combine_super_soldier.mdl")
	end

	if CfgVars["customspawns"] == 1 then
		if not ply:GetTable().Arrested then
			local pos = DB.RetrieveTeamSpawnPos(ply)
			if pos then
				ply:SetPos(pos)
			end
		end
	end

	ply:Extinguish()

	if ply.demotedWhileDead then
		ply.demotedWhileDead = nil
		ply:ChangeTeam(TEAM_CITIZEN)
	end
end

function GM:PlayerLoadout(ply)
	if ply:GetTable().Arrested then return end

	local team = ply:Team()

	ply:Give("keys")
	ply:Give("weapon_physcannon")
	ply:Give("gmod_camera")

	if CfgVars["toolgun"] == 1 or ply:HasPriv(TOOL) or ply:HasPriv(ADMIN) then
		ply:Give("gmod_tool")
	end

	if CfgVars["physgun"] == 1 or ply:HasPriv(PHYS) or ply:HasPriv(ADMIN) then
		ply:Give("weapon_physgun")
	end
	
	if CfgVars["toolgun"] == 1 or ply:HasPriv(TOOL) or ply:HasPriv(ADMIN) then
		ply:Give("gmod_tool")
	end

	if team == TEAM_POLICE or team == TEAM_OVERWATCH or ply:HasPriv(ADMIN) then
		ply:Give("door_ram")
	end

	--CPs
	if team == TEAM_POLICE then
		ply:Give("weapon_pistol")
		ply:Give("weapon_smg1")

		ply:Give("door_ram")
		ply:Give("arrest_stick")
		ply:Give("stunstick")

		ply:GiveAmmo(32, "Pistol")
		ply:GiveAmmo(40, "SMG1")

	--OW
	elseif team == TEAM_OVERWATCH then
		ply:Give("weapon_pistol")
		ply:Give("weapon_smg1")
		ply:Give("weapon_ar2")
		ply:Give("weapon_shotgun")

		ply:Give("door_ram")
		ply:Give("arrest_stick")
		ply:Give("stunstick")

		ply:GiveAmmo(32, "Pistol")
		ply:GiveAmmo(80, "SMG1")
		ply:GiveAmmo(64, "AR2")
		ply:GiveAmmo(16, "Buckshot")
	end
end

function GM:PlayerInitialSpawn(ply)
	self.BaseClass:PlayerInitialSpawn(ply)
	ply:NewData()
	ply:InitSID()
	NetworkHelpLabels(ply)
	DB.RetrieveMoney(ply)
	DB.SetUpNonOwnableDoors()
	ply:PrintMessage(HUD_PRINTTALK, "This server is running LightRP Reloaded!")
	timer.Simple(10, function() ply.CompleteSentence() end)
end

function GM:PlayerDisconnected(ply)
	self.BaseClass:PlayerDisconnected(ply)

	ply:UnownAll()
	timer.Destroy(ply:SteamID() .. "jobtimer")
	timer.Destroy(ply:SteamID() .. "propertytax")
	for k, v in pairs(ents.FindByClass("letter")) do
		if v.SID == ply.SID then v:Remove() end
	end
	vote.DestroyVotesWithEnt(ply)
	-- If you're arrested when you disconnect, you will serve your time again when you reconnect!
	if ply:GetTable().Arrested then
		DB.StoreJailStatus(ply, math.ceil(GetGlobalInt("jailtimer")))
	end
end

VoteCopOn = false

function RemoveItem(ply)
	local trace = ply:GetEyeTrace()
	if IsValid(trace.Entity) and trace.Entity.SID and (trace.Entity.SID == ply.SID or ply:HasPriv(ADMIN)) then
		trace.Entity:Remove()
	end
	return ""
end
AddChatCommand("/rm", RemoveItem)

function RemoveLetters(ply)
	for k, v in pairs(ents.FindByClass("letter")) do
		print("Letter SID: " .. tostring(v.SID) .. "\nPlayer SID: " .. tostring(ply.SID))
		if v.SID == ply.SID then v:Remove() end
	end
	Notify(ply, 1, 4, "Your letters were cleaned up.")
	return ""
end
AddChatCommand("/removeletters", RemoveLetters)

function JailPos(ply)
	-- Admin can set the main Jail Position
	if ply:HasPriv(ADMIN) then
		DB.StoreJailPos(ply)
	else
		Notify(ply, 1, 4, "Admin only!")
	end
	return ""
end
AddChatCommand("/jailpos", JailPos)

function AddJailPos(ply)
	-- Admin can add additional Jail Positions
	if ply:HasPriv(ADMIN) then
		DB.StoreJailPos(ply, true)
	else
		Notify(ply, 1, 4, "Admin only!")
	end
	return ""
end
AddChatCommand("/addjailpos", AddJailPos)

function SetSpawnPos(ply, args)
	if not ply:HasPriv(ADMIN) and not ply:IsAdmin() and not ply:IsSuperAdmin() then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t = 99

	if args == "citizen" then
		t = TEAM_CITIZEN
		Notify(ply, 1, 4,  "Citizen Spawn Position set.")
	elseif args == "cp" then
		t = TEAM_POLICE
		Notify(ply, 1, 4,  "CP Spawn Position set.")
	elseif args == "ow" then
		Notify(ply, 1, 4,  "Overwatch Spawn Position set.")
	end

	if t ~= 99 then
		DB.StoreTeamSpawnPos(t, pos)
	end

	return ""
end

function QueryVar(ply, args)
	if not CfgVars[args] then
		Notify(ply, 1, 4, "CfgVar " .. args .. " not found.")
	else
		Notify(ply, 1, 4, args .. " = " .. CfgVars[args])
	end
	return ""
end
AddChatCommand("/queryvar", QueryVar)

function GetHelp(ply, args)
	umsg.Start("ToggleHelp", ply)
	umsg.End()
	return ""
end
AddChatCommand("/help", GetHelp)

function WriteLetter(ply, args)
	if CfgVars["letters"] == 0 then
		Notify(ply, 1, 4, "Letter writing disabled")
		return ""
	end

	if CurTime() - ply:GetTable().LastLetterMade < 3 then
		Notify(ply, 1, 4, "Wait another " .. math.ceil(3 - (CurTime() - ply:GetTable().LastLetterMade)) .. " seconds to make a letter")
		return ""
	end

	ply:GetTable().LastLetterMade = CurTime()

	local ftext = string.gsub(args, "//", "\n")

	local tr = {}
	tr.start = ply:EyePos()
	tr.endpos = ply:EyePos() + 95 * ply:GetAimVector()
	tr.filter = ply
	local trace = util.TraceLine(tr)

	local letter = ents.Create("prop_physics")
		letter:SetModel("models/props_c17/paper01.mdl")
		letter:SetPos(trace.HitPos)
	letter:Spawn()

	letter:GetTable().Letter = true
	letter:SetNWInt("type", 1)
	letter:SetNWString("content", ftext)

	PrintMessageAll(2, ply:Nick() .. " created a letter.")
	ply:PrintMessage(2, "CREATED LETTER:\n" .. args)

	return ""
end
AddChatCommand("/write", WriteLetter)

function TypeLetter(ply, args)
	if CfgVars["letters"] == 0 then
		Notify(ply, 1, 4, "Letter typing disabled")
		return ""
	end

	if CurTime() - ply:GetTable().LastLetterMade < 3 then
		Notify(ply, 1, 4, "Wait another " .. math.ceil(3 - (CurTime() - ply:GetTable().LastLetterMade)) .. " seconds to make a letter")
		return ""
	end

	ply:GetTable().LastLetterMade = CurTime()

	local ftext = string.gsub(args, "//", "\n")

	local tr = {}
	tr.start = ply:EyePos()
	tr.endpos = ply:EyePos() + 95 * ply:GetAimVector()
	tr.filter = ply
	local trace = util.TraceLine(tr)

	local letter = ents.Create("prop_physics")
		letter:SetModel("models/props_c17/paper01.mdl")
		letter:SetPos(trace.HitPos)
	letter:Spawn()

	letter:GetTable().Letter = true
	letter:SetNWInt("type", 2)
	letter:SetNWString("content", ftext)

	PrintMessageAll(2, ply:Nick() .. " created a letter.")
	ply:PrintMessage(2, "CREATED LETTER:\n" .. args)

	return ""
end
AddChatCommand("/type", TypeLetter)

function ChangeJob(ply, args)
	if args == "" then return "" end

	local len = string.len(args)

	if len < 3 then
		Notify(ply, 1, 4, "Job must be at least 3 characters!")
		return ""
	end

	if len > 25 then
		Notify(ply, 1, 4, "Job is restricted to 25 characters!")
		return ""
	end

	local jl = string.lower(args)
	local t = ply:Team()

	if (jl == "cp" or jl == "cop" or jl == "police" or jl == "civil protection" or jl == "civilprotection") and t ~= TEAM_POLICE then
		if ply:HasPriv(CP) or ply:HasPriv(ADMIN) then
			if VoteCopOn then
				Notify(ply, 1, 4,  "Please wait for the vote to finish first.")
			else
				ply:ChangeTeam(TEAM_POLICE)
			end
		else
			Notify(ply, 1, 4, "You have to be on the CP List or Admin!")
		end
		return ""
	elseif jl == "ow" or jl == "overwatch" and t ~= TEAM_OVERWATCH then
		if ply:HasPriv(OW) or ply:HasPriv(ADMIN) then
			if VoteCopOn then
				Notify(ply, 1, 4,  "Please wait for the vote to finish first.")
			else
				ply:ChangeTeam(TEAM_OVERWATCH)
			end
		else
			Notify(ply, 1, 4, "You Must be on the Overwatch List or Admin!")
		end
		return ""
	elseif jl == "citizen" and t ~= TEAM_CITIZEN then
		ply:ChangeTeam(TEAM_CITIZEN)
		return ""
	elseif (jl == "hobo" or jl == "bum" or jl == "unemployed") and t ~= TEAM_CITIZEN then
		ply:ChangeTeam(TEAM_CITIZEN)
		-- Don't return here because we want to run the notify below.
	end

	NotifyAll(2, 4, ply:Nick() .. " has set their job to '" .. args .. "'")
	ply:UpdateJob(args)
	return ""
end
AddChatCommand("/job", ChangeJob)

function GroupMsg(ply, args)
	local t = ply:Team()
	local audience = {}

	if t == TEAM_POLICE then
		for k, v in pairs(player.GetAll()) do
			local vt = v:Team()
			if vt == TEAM_POLICE then table.insert(audience, v) end
		end
	elseif t == TEAM_OVERWATCH then
		for k, v in pairs(player.GetAll()) do
			local vt = v:Team()
			if vt == TEAM_OVERWATCH then table.insert(audience, v) end
		end
	end

	for k, v in pairs(audience) do
		v:PrintMessage(2, ply:Nick() .. ": (GROUP) " .. args)
		v:PrintMessage(3, ply:Nick() .. ": (GROUP) " .. args)
	end
	return ""
end
AddChatCommand("/g", GroupMsg)

function PM(ply, args)
	local namepos = string.find(args, " ")
	if not namepos then return "" end

	local name = string.sub(args, 1, namepos - 1)
	local msg = string.sub(args, namepos + 1)

	target = FindPlayer(name)

	if target then
		target:PrintMessage(2, ply:Nick() .. ": (PM) " .. msg)
		target:PrintMessage(3, ply:Nick() .. ": (PM) " .. msg)

		ply:PrintMessage(2, ply:Nick() .. ": (PM) " .. msg)
		ply:PrintMessage(3, ply:Nick() .. ": (PM) " .. msg)
	else
		Notify(ply, 1, 3, "Could not find player: " .. name)
	end

	return ""
end
AddChatCommand("/pm", PM)

function Whisper(ply, args)
	TalkToRange("(WHISPER)" .. ply:Nick() .. ": " .. args, ply:EyePos(), 90)

	return ""
end
AddChatCommand("/w", Whisper)

function Yell(ply, args)
	TalkToRange("(YELL)" .. ply:Nick() .. ": " .. args, ply:EyePos(), 550)

	return ""
end
AddChatCommand("/y", Yell)

function OOC(ply, args)
	if CfgVars["ooc"] == 0 then 
		Notify(ply, 1, 3, "OOC is disabled")
		return ""
	end

	return "(OOC) " .. args
end
AddChatCommand("//", OOC, true)
AddChatCommand("/a ", OOC, true)
AddChatCommand("/ooc", OOC, true)

function GiveMoney(ply, args)
	if args == "" then return "" end

	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(ply:GetPos()) < 150 then
		local amount = math.floor(tonumber(args))

		if amount <= 1 then
			Notify(ply, 1, 4, "Invalid amount of money! Must be at least " .. CUR .. "2!")
			return
		end

		if not ply:CanAfford(amount) then
			Notify(ply, 1, 4, "Can not afford this!")
			return ""
		end

		DB.PayPlayer(ply, trace.Entity, amount)

		Notify(trace.Entity, 0, 4, ply:Nick() .. " has given you " .. CUR .. tostring(amount))
		Notify(ply, 0, 4, "Gave " .. trace.Entity:Nick() .. " " .. CUR .. tostring(amount))
	else
		Notify(ply, 1, 4, "Must be looking at and standing close to another player!")
	end
	return ""
end
AddChatCommand("/give", GiveMoney)

function DropMoney(ply, args)
	if args == "" then return "" end

	local amount = math.floor(tonumber(args))

	if amount <= 1 then
		Notify(ply, 1, 4, "Invalid amount of money! Must be at least " .. CUR .. "2!")
		return ""
	end

	if not ply:CanAfford(amount) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end

	ply:AddMoney(-amount)

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	local moneybag = ents.Create("prop_physics")
	moneybag:SetModel("models/props/cs_assault/money.mdl")
	moneybag:SetNWString("Owner", "Shared")
	moneybag:SetPos(tr.HitPos)
	moneybag.nodupe = true
	moneybag:Spawn()
	moneybag:GetTable().MoneyBag = true
	moneybag:GetTable().Amount = amount

	return ""
end
AddChatCommand("/dropmoney", DropMoney)
AddChatCommand("/moneydrop", DropMoney)

function SetDoorTitle(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		if ply:IsSuperAdmin() then
			if trace.Entity:GetNWBool("nonOwnable") then
				DB.StoreNonOwnableDoorTitle(trace.Entity, args)
				return ""
			end
		else
			if trace.Entity:GetNWBool("nonOwnable") then
				Notify(ply, 1, 4, "Admin only!")
			end
		end

		if trace.Entity:OwnedBy(ply) then
			trace.Entity:SetNWString("title", args)
		else
			Notify(ply, 1, 4, "You don't own this!")
		end
	end

	return ""
end
AddChatCommand("/title", SetDoorTitle)

function RemoveDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		target = FindPlayer(args)

		if trace.Entity:GetNWBool("nonOwnable") then
			Notify(ply, 1, 4, "Can not remove owners while Door is non-ownable!")
		end

		if target then
			if trace.Entity:OwnedBy(ply) then
				if trace.Entity:AllowedToOwn(target) then
					trace.Entity:RemoveAllowed(target)
				end

				if trace.Entity:OwnedBy(target) then
					trace.Entity:RemoveOwner(target)
				end
			else
				Notify(ply, 1, 4, "You don't own this!")
			end
		else
			Notify(ply, 1, 4, "Could not find player: " .. args)
		end
	end
	return ""
end
AddChatCommand("/removeowner", RemoveDoorOwner)
AddChatCommand("/ro", RemoveDoorOwner)

function AddDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		target = FindPlayer(args)
		if target then
			if trace.Entity:GetNWBool("nonOwnable") then
				Notify(ply, 1, 4, "Can not add owners while Door is non-ownable!")
				return ""
			end

			if trace.Entity:OwnedBy(ply) then
				if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
					trace.Entity:AddAllowed(target)
				else
					Notify(ply, 1, 4, "Player already owns (or is allowed to own) this door!")
				end
			else
				Notify(ply, 1, 4, "You don't own this!")
			end
		else
			Notify(ply, 1, 4, "Could not find player: " .. args)
		end
	end
	return ""
end
AddChatCommand("/addowner", AddDoorOwner)
AddChatCommand("/ao", AddDoorOwner)

function Demote(ply, args)
	local p = FindPlayer(args)
	if p then
		if CurTime() - ply:GetTable().LastVoteCop < 80 then
			Notify(ply, 1, 4, "Please wait another " .. math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)) .. " seconds before demoting.")
			return ""
		end
		if p:Team() == TEAM_CITIZEN then
			Notify(ply, 1, 4,  p:Nick() .." is a Citizen - can't be demoted any further!")
		else
			NotifyAll(1, 4, ply:Nick() .. " has started a vote for the demotion of " .. p:Nick())
			vote:Create(p:Nick() .. ":\n Demotion Nominee", p:EntIndex() .. "votecop", p, 12, FinishDemote)
			ply:GetTable().LastVoteCop = CurTime()
			VoteCopOn = true
			Notify(ply, 1, 4, "Demotion Vote started!")
		end
		return ""
	else
		Notify(ply, 1, 4, "Player does not exist!")
		return ""
	end
end
AddChatCommand("/demote", Demote)

function FinishDemote(choice, v)
	VoteCopOn = false

	if choice == 1 then
		v:TeamBan()
		if v:Alive() then
			v:ChangeTeam(TEAM_CITIZEN)
		else
			v.demotedWhileDead = true
		end

		NotifyAll(1, 4, v:Nick() .. " has been demoted!")
	else
		NotifyAll(1, 4, v:Nick() .. " has not been demoted!")
	end
end

function FinishVoteOW(choice, ply)
	VoteCopOn = false

	if choice == 1 then
		ply:SetTeam(TEAM_OVERWATCH)
		ply:UpdateJob("Overwatch")
		ply:KillSilent()

		NotifyAll(1, 4, ply:Nick() .. " has been made Overwatch!")
	else
		NotifyAll(1, 4, ply:Nick() .. " has not been made Overwatch!")
	end
end

function FinishVoteCop(choice, ply)
	VoteCopOn = false

	if choice == 1 then
		ply:SetTeam(TEAM_POLICE)
		ply:UpdateJob("Civil Protection")
		ply:KillSilent()
		
		NotifyAll(1, 4, ply:Nick() .. " has been made Civil Protection!")
	else
		NotifyAll(1, 4, ply:Nick() .. " has not been made Civil Protection!")
	end
end

function DoVoteOW(ply, args)
	if CfgVars["owvoting"] == 0 then
		Notify(ply, 1, 4,  "OW voting is disabled!")
		return ""
	end

	if CurTime() - ply:GetTable().LastVoteCop < 80 then
		Notify(ply, 1, 4, "Wait another " .. math.ceil(80 - (CurTime() - ply:GetTable().LastVoteCop)) .. " seconds to voteow!")
		return ""
	end

	if VoteCopOn then
		Notify(ply, 1, 4,  "There is already a vote!")
		return ""
	end

	if CfgVars["cptoowonly"] == 1 then
		if ply:Team() == TEAM_CITIZEN then
			Notify(ply, 1, 4,  "You have to be in the civil protection!")
			return ""
		end
	end

	if ply:Team() == TEAM_OVERWATCH then
		Notify(ply, 1, 4,  "You're already in the Overwatch!")
		return ""
	end

	if team.NumPlayers(TEAM_OVERWATCH) >= CfgVars["maxow"] then
		Notify(ply, 1, 4,  "Max number of Overwatch jobs is: " .. CfgVars["maxow"])
		return ""	
	end

	vote:Create(ply:Nick() .. ":\nwants to be Overwatch", ply:EntIndex() .. "votecop", ply, 12, FinishVoteOW)
	ply:GetTable().LastVoteCop = CurTime()
	VoteCopOn = true

	return ""
end
AddChatCommand("/voteow", DoVoteOW)

function DoVoteCop(ply, args)
	if CfgVars["cpvoting"] == 0 then
		Notify(ply, 1, 4,  "Copvoting is disabled!")
		return ""
	end

	if CurTime() - ply:GetTable().LastVoteCop < 60 then
		Notify(ply, 1, 4, "Wait another " .. math.ceil(60 - (CurTime() - ply:GetTable().LastVoteCop)) .. " seconds to votecop!")
		return ""
	end

	if VoteCopOn then
		Notify(ply, 1, 4,  "There is already a vote!")
		return ""
	end

	if ply:Team() == TEAM_POLICE or ply:Team() == TEAM_OVERWATCH then
		Notify(ply, 1, 4,  "You're already in the Combine!")
		return ""
	end

	if team.NumPlayers(TEAM_POLICE) >= CfgVars["maxcps"] then
		Notify(ply, 1, 4,  "Max number of Civil Protections is: " .. CfgVars["maxcps"])
		return ""
	end

	vote:Create(ply:Nick() .. ":\nwants to be a Civil Protection", ply:EntIndex() .. "votecop", ply, 12, FinishVoteCop)
	ply:GetTable().LastVoteCop = CurTime()
	VoteCopOn = true

	return ""
end
AddChatCommand("/votecop", DoVoteCop)

function MakeCitizen(ply, args)
	if ply:Team() ~= TEAM_CITIZEN then
		ply:SetTeam(TEAM_CITIZEN)
		ply:UpdateJob("Citizen")
		ply:KillSilent()
	else
		Notify(ply, 0, 3, "You're already a citizen!")
	end

	return ""
end
AddChatCommand("/citizen", MakeCitizen)

function MakeOW(ply, args)
	if ply:HasPriv(OW) or ply:HasPriv(ADMIN) then
		if VoteCopOn then
			Notify(ply, 1, 4,  "Please wait for the vote to finish first.")
		else
			ply:ChangeTeam(TEAM_OVERWATCH)
		end
	else
		Notify(ply, 1, 4, "You must be on the Overwatch list or Admin!")
	end
	return ""
end
AddChatCommand("/ow", MakeOW)

function MakeCP(ply, args)
	if ply:HasPriv(CP) or ply:HasPriv(ADMIN) then
		if VoteCopOn then
			Notify(ply, 1, 4,  "Please wait for the vote to finish first.")
		else
			ply:ChangeTeam(TEAM_POLICE)
		end
	else
		Notify(ply, 1, 4, "You must be on the Civil Protection or the Mayor list or Admin!")
	end
	return ""
end
AddChatCommand("/cp", MakeCP)

function CombineRadio(ply, args)
	if ply:Team() == TEAM_POLICE or ply:Team() == TEAM_OVERWATCH then
		for k, v in pairs(player.GetAll()) do
			if v:Team() == TEAM_POLICE or v:Team() == TEAM_OVERWATCH then
				v:ChatPrint(ply:Nick() .. ": (RADIO) " .. args)
				v:PrintMessage(2, ply:Nick() .. ": (RADIO) " .. args)
			end
		end
	end

	return ""
end
AddChatCommand("/r", CombineRadio)

function CombineRequest(ply, args)
	if ply:Team() ~= TEAM_POLICE and ply:Team() ~= TEAM_OVERWATCH then
		ply:ChatPrint(ply:Nick() .. ": (REQUEST!) " .. args)
		ply:PrintMessage(2, ply:Nick() .. ": (REQUEST!) " .. args)
	end

	for k, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_POLICE or v:Team() == TEAM_OVERWATCH then
			v:ChatPrint(ply:Nick() .. ": (REQUEST!) " .. args)
			v:PrintMessage(2, ply:Nick() .. ": (REQUEST!) " .. args)
		end
	end

	return ""
end
AddChatCommand("/cr", CombineRequest)

function RefreshGlobals()
	if CfgVars["refreshglobals"] ~= 1 then
		SetGlobalInt("nametag", 1)
		SetGlobalInt("jobtag", 1)
		SetGlobalInt("globalshow", 0)
		SetGlobalInt("jailtimer", 120)
	end
	CfgVars["refreshglobals"] = 1
	timer.Simple(30, function() refwait() end)
end

function VerifyGlobals(ply)
	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "Must be an Admin to refresh the Global Variables!")
		return
	else
		local nick = ""
		if ply:EntIndex() == 0 then
			nick = "Console"
		else
			nick = ply:Nick()
		end
		NotifyAll(0, 6, nick .. " refreshed the Global Variables.")
		RefreshGlobals()
	end
end

function refwait()
	CfgVars["refreshglobals"] = 0
end

function GM:PhysgunPickup(ply, ent)
	if (ent:IsPlayer() or ent:IsDoor()) then return false end

	local class = ent:GetClass()

	if ply:HasPriv(ADMIN) then return true end

	if (class ~= "func_physbox" and class ~= "prop_physics" and class ~= "prop_physics_multiplayer" and class ~= "prop_vehicle_prisoner_pod") then
		return false
	end
	return true
end

function GM:PlayerSpawnProp(ply, model)
	if not self.BaseClass:PlayerSpawnProp(ply, model) then return false end

	local allowed = false

	if ply:GetTable().Arrested then return false end

	-- Banned props take precedence over allowed props
	if CfgVars["banprops"] == 1 then
		for k, v in pairs(BannedProps) do
			if v == model then return false end
		end
	end

	-- If prop spawning is enabled or the user has admin or prop privileges
	if CfgVars["propspawning"] == 1 or ply:HasPriv(ADMIN) or ply:HasPriv(PROP) then
		-- If we are specifically allowing certain props, if it's not in the list, allowed will remain false
		if CfgVars["allowedprops"] == 1 then
			for k, v in pairs(AllowedProps) do
				if v == model then allowed = true end
			end
		else
			-- allowedprops is not enabled, so assume that if it wasn't banned above, it's allowed
			allowed = true
		end
	end

	if allowed then
		if CfgVars["proppaying"] == 1 then
			if ply:CanAfford(CfgVars["propcost"]) then
				Notify(ply, 1, 4, "Deducted " .. CUR .. CfgVars["propcost"])
				ply:AddMoney(-CfgVars["propcost"])
				return true
			else
				Notify(ply, 1, 4, "Need " .. CUR .. CfgVars["propcost"])
				return false
			end
		else
			return true
		end
	else
		return false
	end
end

function GM:PlayerSpawnSENT(ply, model)
	return ply:HasPriv(ADMIN) and self.BaseClass:PlayerSpawnSENT(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnSWEP(ply, model)
	return self.BaseClass:PlayerSpawnSWEP(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnEffect(ply, model)
	return self.BaseClass:PlayerSpawnEffect(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnVehicle(ply, model)
	return self.BaseClass:PlayerSpawnVehicle(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnNPC(ply, model)
	return self.BaseClass:PlayerSpawnNPC(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnRagdoll(ply, model)
	return self.BaseClass:PlayerSpawnRagdoll(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnedProp(ply, model, ent)
	self.BaseClass:PlayerSpawnedProp(ply, model, ent)
	ent.SID = ply.SID
end

function GM:PlayerSpawnedSWEP(ply, model, ent)
	self.BaseClass:PlayerSpawnedSWEP(ply, model, ent)
	--ent.SID = ply.SID
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
	self.BaseClass:PlayerSpawnedRagdoll(ply, model, ent)
	ent.SID = ply.SID
end

function GM:SetupMove(ply, move)
	if ply == nil or not ply:Alive() then
		return
	end
	
	if ply:Crouching() then
		move:SetMaxClientSpeed(180)
		return
	end

	if ply:GetTable().Arrested then
		move:SetMaxClientSpeed(120)
		return
	end

	if ply:KeyDown(IN_SPEED) then
		move:SetMaxClientSpeed(230)
		return
	elseif ply:GetVelocity():Length() > 10 then
		move:SetMaxClientSpeed(155)
		return
	end
end

function GM:ShowSpare1(ply)
	umsg.Start("ToggleClicker", ply)
	umsg.End()
end

function GM:ShowSpare2(ply)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 115 then
		if ply:GetTable().Arrested then
			Notify(ply, 1, 5, "Can not own or unown things while arrested!")
			return
		end

		if trace.Entity:GetNWBool("nonOwnable") then
			Notify(ply, 1, 5, "This Door can not be owned or unowned!")
			return
		end

		if trace.Entity:OwnedBy(ply) then
			Notify(ply, 1, 4, "Sold for " .. CUR .. math.floor(((CfgVars["doorcost"] * 0.66666666666666)+0.5)) .. "!")
			trace.Entity:Fire("unlock", "", 0)
			trace.Entity:UnOwn(ply)
			ply:GetTable().Owned[trace.Entity:EntIndex()] = nil
			ply:GetTable().OwnedNum = ply:GetTable().OwnedNum - 1
			ply:AddMoney(math.floor(((CfgVars["doorcost"] * 0.66666666666666)+0.5)))
		else
			if trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(ply) then
				Notify(ply, 1, 4, "Already owned!")
				return
			end
			if trace.Entity:GetClass() == "prop_vehicle_jeep" or trace.Entity:GetClass() == "prop_vehicle_airboat" then
				if not ply:CanAfford(CfgVars["vehiclecost"]) then
					Notify(ply, 1, 4, "You can not afford this vehicle!")
					return
				end
			else
				if not ply:CanAfford(CfgVars["doorcost"]) then
					Notify(ply, 1, 4, "You can not afford this door!")
					return
				end
			end

			if trace.Entity:GetClass() == "prop_vehicle_jeep" or trace.Entity:GetClass() == "prop_vehicle_airboat" then
				ply:AddMoney(-CfgVars["vehiclecost"])
				Notify(ply, 1, 4, "You've bought this vehicle for " .. CUR .. math.floor(CfgVars["vehiclecost"]) .. "!")
			else
				ply:AddMoney(-CfgVars["doorcost"])
				Notify(ply, 1, 4, "You've bought this door for " .. CUR .. math.floor(CfgVars["doorcost"]) .. "!")
			end
			trace.Entity:Own(ply)

			if ply:GetTable().OwnedNum == 0 then
				timer.Create(ply:SteamID() .. "propertytax", 270, 0, function() ply:DoPropertyTax() end)
			end

			ply:GetTable().OwnedNum = ply:GetTable().OwnedNum + 1

			ply:GetTable().Owned[trace.Entity:EntIndex()] = trace.Entity
		end
	end
end

function GM:OnNPCKilled(victim, ent, weapon)
	-- If something killed the npc
	if ent then
		if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end

		-- if it wasn't a player directly, find out who owns the prop that did the killing
		if not ent:IsPlayer() then
			ent = FindPlayerBySID(ent.SID)
		end
	end
end

function GM:KeyPress(ply, code)
	self.BaseClass:KeyPress(ply, code)

	if code == IN_USE then
		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 95
		trace.filter = ply
		local tr = util.TraceLine(trace)

		if IsValid(tr.Entity) and not ply:KeyDown(IN_ATTACK) then
			if tr.Entity:GetTable().Letter then
				umsg.Start("ShowLetter", ply)
					umsg.Short(tr.Entity:GetNWInt("type"))
					umsg.Vector(tr.Entity:GetPos())
					umsg.String(tr.Entity:GetNWString("content"))
				umsg.End()
			end

			if tr.Entity:GetTable().MoneyBag then
				Notify(ply, 0, 4, "You found " .. CUR .. tostring(tr.Entity:GetTable().Amount))
				ply:AddMoney(tr.Entity:GetTable().Amount)

				tr.Entity:Remove()
			end
		else
			umsg.Start("KillLetter", ply)
			umsg.End()
		end
	end
end

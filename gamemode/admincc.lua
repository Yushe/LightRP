ValueCmds = {}
function AddValueCommand(cmd, cfgvar, global)
	ValueCmds[cmd] = { var = cfgvar, global = global }
	concommand.Add(cmd, ccValueCommand)
end

function ccValueCommand(ply, cmd, args)
	local valuecmd = ValueCmds[cmd]

	if not valuecmd then return end

	if #args < 1 then
		if valuecmd.global then
			if ply:EntIndex() == 0 then
				Msg(cmd .. " = " .. GetGlobalInt(valuecmd.var))
			else
				ply:PrintMessage(2, cmd .. " = " .. GetGlobalInt(valuecmd.var))
			end
		else
			if ply:EntIndex() == 0 then
				Msg(cmd .. " = " .. CfgVars[valuecmd.var])
			else
				ply:PrintMessage(2, cmd .. " = " .. CfgVars[valuecmd.var])
			end
		end
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin")
		return
	end

	local amount = math.floor(tonumber(args[1]))

	if valuecmd.global then
		SetGlobalInt(valuecmd.var, amount)
	else
		CfgVars[valuecmd.var] = amount
	end

	local nick = ""

	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick()
	end

	NotifyAll(0, 4, nick .. " set " .. cmd .. " to " .. amount)
end

ToggleCmds = {}
function AddToggleCommand(cmd, cfgvar, global)
	ToggleCmds[cmd] = {var = cfgvar, global = global}
	concommand.Add(cmd, ccToggleCommand)
end

function ccToggleCommand(ply, cmd, args)
	local togglecmd = ToggleCmds[cmd]

	if not togglecmd then return end

	if #args < 1 then
		if togglecmd.global then
			if ply:EntIndex() == 0 then
				Msg(cmd .. " = " .. GetGlobalInt(togglecmd.var))
			else
				ply:PrintMessage(2, cmd .. " = " .. GetGlobalInt(togglecmd.var))
			end
		else
			if ply:EntIndex() == 0 then
				Msg(cmd .. " = " .. CfgVars[togglecmd.var])
			else
				ply:PrintMessage(2, cmd .. " = " .. CfgVars[togglecmd.var])
			end
		end
		return
	end

	if not DB.HasPriv(ply, ADMIN) then
		ply:PrintMessage(2, "Admin only!")
		return
	end

	local toggle = tonumber(args[1])

	if not toggle or (toggle ~= 1 and toggle ~= 0) then
		if ply:EntIndex() == 0 then
			Msg("Invalid number; must be 1 or 0.")
		else
			ply:PrintMessage(2, "Invalid number; must be 1 or 0.")
		end
		return
	end

	if togglecmd.global then
		SetGlobalInt(togglecmd.var, toggle)
	else
		CfgVars[togglecmd.var] = toggle
	end

	local nick = ""

	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick()
	end

	NotifyAll(0, 4, nick .. " set " .. cmd .. " to " .. toggle)
end

--------------------------------------------------------------------------------------------------
--Cfg Var Toggling
--------------------------------------------------------------------------------------------------

-- Usage of AddToggleCommand
-- (command name,  cfg variable name, is it a global variable or a cfg variable?)

AddToggleCommand("rp_propertytax", "propertytax", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_propertytax - Enable/disable property tax")

AddToggleCommand("rp_citpropertytax", "cit_propertytax", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_citpropertytax - Enable/disable property tax that is exclusive only for citizens")

AddToggleCommand("rp_bannedprops", "banprops", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_bannedprops - Enable/disable certain props being banned (overrides rp_allowedprops)")

AddToggleCommand("rp_allowedprops", "allowedprops", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allowedprops - Enable/disable certain props being allowed")

AddToggleCommand("rp_strictsuicide", "strictsuicide", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_strictsuicide - Enable/disable whether players should spawn where they suicided (regardless if they're arrested.")

AddToggleCommand("rp_ooc", "ooc", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_ooc - Enable/disable if OOC tags are enabled")

AddToggleCommand("rp_alltalk", "alltalk", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_alltalk - Enable for global chat, disable for local chat")

AddToggleCommand("rp_globaltags", "globalshow", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_globaltags - Enable/disable player info (Name/Job/etc) from being displayed across the map")

AddToggleCommand("rp_showcrosshairs", "crosshair", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_showcrosshairs - Enable/disable if crosshairs are visible")

AddToggleCommand("rp_showjob", "jobtag", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_showjob - Enable/disable if job information should be public to other players")

AddToggleCommand("rp_showname", "nametag", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_showname - Enable/disable if other players can see your name")

AddValueCommand("rp_jailtimer", "jailtimer", true)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_jailtimer <Number> - Sets the jailtimer. (in seconds)")

AddToggleCommand("rp_physgun", "physgun", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_physgun - Enable/disable Players spawning with physguns.")

AddValueCommand("rp_doorcost", "doorcost", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_doorcost <Number> - Sets the cost of a door.")

AddValueCommand("rp_vehiclecost", "vehiclecost", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_vehiclecost <Number> - Sets the cost of a vehicle (To own it).")

AddValueCommand("rp_dm_gracetime", "dmgracetime", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_dm_gracetime <Number> - Number of seconds after killing a player that the killer will be watched for DM.")

AddValueCommand("rp_dm_maxkills", "dmmaxkills", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_dm_maxkills <Number> - Max number of kills allowed during rp_dm_gracetime to avoid being auto-kicked for DM.")

AddValueCommand("rp_demotetime", "demotetime", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_demotetime <Number> - Number of seconds before a player can rejoin a team after demotion from that team.")

AddToggleCommand("rp_allowvehiclenocollide", "allowvnocollide", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_allowvehiclenocollide - Enable/disable the ability to no-collide a vehicle (for security).")

AddToggleCommand("rp_toolgun", "toolgun", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_toolgun - Enable/disable if players spawn with toolguns.  (Excluding admins) ")

AddToggleCommand("rp_propspawning", "propspawning", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_propspawning - Enable/disable if players can spawn props.  (Excluding admins)")

AddToggleCommand("rp_proppaying", "proppaying", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_proppaying - Enable/disable if players should pay for props")

AddToggleCommand("rp_adminsweps", "adminsweps", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_adminsweps - Enable/disable if SWEPs should be admin-only.")

AddToggleCommand("rp_adminsents", "adminsents", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_adminsents - Enable/disable if SENTs should be admin-only.")

AddToggleCommand("rp_enforcemodels", "enforceplayermodel", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_enforcemodels - Enable/disable is players should not be able to use player models like Combine/Zombies.")

AddToggleCommand("rp_letters", "letters", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_letters - Enable/disable letter writing/typing.")

AddToggleCommand("rp_cpvoting", "cpvoting", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_cpvoting - Enable/disable player's ability to do a vote cop")

AddToggleCommand("rp_owvoting", "owvoting", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_owvoting - Enable/disable player's ability to do a vote OW")

AddToggleCommand("rp_cptoow", "cptoowonly", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_cptoow - Enable/disable if only the civil protection can do /voteow")

AddToggleCommand("rp_customspawns", "customspawns", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_customspawns - Enable/disable whether custom spawns should be used.")

AddToggleCommand("rp_dm_autokick", "dmautokick", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINTOGGLE, "rp_dm_autokick - Enable/disable Auto-kick of deathmatchers.")

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function ccDoorOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin")
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	trace.Entity:Own(ply)
end
concommand.Add("rp_own", ccDoorOwn)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_own - Own the door you're looking at.")

function ccDoorUnOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
end
concommand.Add("rp_unown", ccDoorUnOwn)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_unown - Remove ownership from the door you're looking at.")

function ccAddOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = FindPlayer(args[1])

	if target then
		if trace.Entity:IsOwned() then
			if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
				trace.Entity:AddAllowed(target)
			else
				ply:PrintMessage(2, "Player already owns (or is already allowed to own) this door!")
			end
		else
			trace.Entity:Own(target)
		end
	else
		ply:PrintMessage(2, "Could not find player: " .. args)
	end
end
concommand.Add("rp_addowner", ccAddOwner)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_addowner [Nick|SteamID|UserID] - Add a co-owner to the door you're looking at.")

function ccRemoveOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = FindPlayer(args[1])

	if target then
		if trace.Entity:AllowedToOwn(target) then
			trace.Entity:RemoveAllowed(target)
		end

		if trace.Entity:OwnedBy(target) then
			trace.Entity:RemoveOwner(target)
		end
	else
		ply:PrintMessage(2, "Could not find player: " .. args)
	end
end
concommand.Add("rp_removeowner", ccRemoveOwner)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_removeowner [Nick|SteamID|UserID] - Remove co-owner from door you're looking at.")

function ccLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	ply:PrintMessage(2, "Locked.")

	trace.Entity:Fire("lock", "", 0)
end
concommand.Add("rp_lock", ccLock)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_lock - Lock the door you're looking at.")

function ccUnLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	ply:PrintMessage(2, "Unlocked.")
	trace.Entity:Fire("unlock", "", 0)
end
concommand.Add("rp_unlock", ccUnLock)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_unlock - Unlock the door you're looking at.")

AddValueCommand("rp_propcost", "propcost", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_propcost <Number> - How much props should cost if prop paying is on")

AddValueCommand("rp_maxcps", "maxcps", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxcps <Number> - Maximum amount of CPs that can be on the server")

AddValueCommand("rp_maxow", "maxow", false)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_maxow <Number> - Maximum amount of OW that can be on the server")

function ccTell(ply, cmd, args)
	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		local msg = ""

		for n = 2, #args do
			msg = msg .. args[n] .. " "
		end

		umsg.Start("AdminTell", target)
			umsg.String(msg)
		umsg.End()
	else
		if ply:EntIndex() == 0 then
			Msg("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
	end
end
concommand.Add("rp_tell", ccTell)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_tell [Nick|SteamID|UserID] <Message> - Send a noticeable message to a named player.")

function ccRemoveLetters(ply, cmd, args)
	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		for k, v in pairs(ents.FindByClass("letter")) do
			if v.SID == target.SID then v:Remove() end
		end
	else
		-- Remove ALL letters
		for k, v in pairs(ents.FindByClass("letter")) do
			v:Remove()
		end
	end
end
concommand.Add("rp_removeletters", ccRemoveLetters)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_removeletters [Nick|SteamID|UserID] - Remove all letters for a given player (or all if none specified).")

function ccSetChatCmdPrefix(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsAdmin() and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You're not a server admin!")
		return
	end

	local oldprefix = GetGlobalString("cmdprefix")
	SetGlobalString("cmdprefix", args[1])

	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick()
	end

	NotifyAll(0, 4, nick .. " set rp_chatprefix to " .. args[1])

	GenerateChatCommandHelp()

	for k, v in pairs(ChatCommands) do
		if not v.prefixconst then
			v.cmd = string.gsub(v.cmd, oldprefix, args[1])
		end
	end

	umsg.Start("UpdateHelp")
	umsg.End()
end
concommand.Add("rp_chatprefix", ccSetChatCmdPrefix)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_chatprefix <Prefix> - Set the chat prefix for commands (like the / in /votecop or /job).")

function ccPayDayTime(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsAdmin() and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You're not a server admin")
		return
	end

	local amount = math.floor(tonumber(args[1]))

	if not amount then return end

	CfgVars["paydelay"] = amount

	for k, v in pairs(player.GetAll()) do
		v:UpdateJob(v:GetNWString("job"))
	end

	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick()
	end

	NotifyAll(0, 4, nick .. " set rp_paydaytime to " .. amount)
end
concommand.Add("rp_paydaytime", ccPayDayTime)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_paydaytime <Delay> - Pay interval. (in seconds)")

function ccArrest(ply, cmd, args)
	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin")
		return
	end

	if DB.CountJailPos() == 0 then
		if ply:EntIndex() == 0 then
			Msg("No jail positions yet!\n")
		else
			ply:PrintMessage(2, "No jail positions yet!")
		end
		return
	end

	local target = FindPlayer(args[1])
	if target then
		local length = tonumber(args[2])
		if length then
			target:Arrest(length)
		else
			target:Arrest()
		end
	else
		if ply:EntIndex() == 0 then
			Msg("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
	end
end
concommand.Add("rp_arrest", ccArrest)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_arrest [Nick|SteamID|UserID] <Length> - Arrest a player for a custom amount of time. If no time is specified, it will default to " .. GetGlobalInt("jailtimer") .. " seconds.")

function ccUnarrest(ply, cmd, args)
	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:Unarrest()
	else
		if ply:EntIndex() == 0 then
			Msg("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_unarrest", ccUnarrest)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_unarrest [Nick|SteamID|UserID] - Unarrest a player.")

function ccOW(ply, cmd, args)
	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:SetTeam(TEAM_OVERWATCH)
		target:UpdateJob("Overwatch")
		target:KillSilent()

		local nick = ""

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:PrintMessage(2, nick .. " made you OverWatch")
	else
		if(ply:EntIndex() == 0) then
			Msg("Did not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Did not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_ow", ccOW)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_ow <Name/Partial Name> - Turn a player into the OverWatch")

function ccCP(ply, cmd, args)
	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:ChangeTeam(TEAM_POLICE)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:PrintMessage(2, nick .. " made you a CP!")
	else
		if ply:EntIndex() == 0 then
			Msg("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_cp", ccCP)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_cp [Nick|SteamID|UserID] - Make a player into a CP.")

function ccCitizen(ply, cmd, args)
	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		target:ChangeTeam(TEAM_CITIZEN)

		if ply:EntIndex() ~= 0 then
			nick = ply:Nick()
		else
			nick = "Console"
		end

		target:PrintMessage(2, nick .. " made you a Citizen!")
	else
		if ply:EntIndex() == 0 then
			Msg("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_citizen", ccCitizen)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_citizen [Nick|SteamID|UserID] - Make a player become a Citizen.")

function ccKickBan(ply, cmd, args)
	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		if not args[2] then
			args[2] = 0
		end

		if (target:HasPriv(ADMIN) or target:IsAdmin() or target:IsSuperAdmin()) and (not ply:IsAdmin() or not ply:IsSuperAdmin()) then
			ply:PrintMessage(2, "Normal RP admins can not kick or ban another admin!")
			return
		end

		game.ConsoleCommand("banid " .. args[2] .. " " .. target:UserID() .. "\n")
		game.ConsoleCommand("kickid " .. target:UserID() .. " \"Kicked and Banned\"\n")
	else
		if ply:EntIndex() == 0 then
			Msg("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_kickban", ccKickBan)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_kickban [Nick|SteamID|UserID] <Length in minutes> - Kick and ban a player.")

function ccKick(ply, cmd, args)
	if not ply:HasPriv(ADMIN) then
		ply:PrintMessage(2, "You're not an admin!")
		return
	end

	local target = FindPlayer(args[1])

	if target then
		if (target:HasPriv(ADMIN) or target:IsAdmin() or target:IsSuperAdmin()) and (not ply:IsAdmin() or not ply:IsSuperAdmin()) then
			ply:PrintMessage(2, "Normal RP admins can not kick or ban another admin!")
			return
		end

		local reason = ""

		if args[2] then
			for n = 2, #args do
				reason = reason .. args[n]
				reason = reason .. " "
			end
		end

		game.ConsoleCommand("kickid " .. target:UserID() .. " \"" .. reason .. "\"\n")
	else
		if ply:EntIndex() == 0 then
			Msg("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_kick", ccKick)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_kick [Nick|SteamID|UserID] <Kick reason> - Kick a player. The reason is optional.")

function ccSetMoney(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:IsAdmin() and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You're not a server admin!")
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if not amount then
		if ply:EntIndex() == 0 then
			Msg("Invalid amount of money: " .. args[2])
		else
			ply:PrintMessage(2, "Invalid amount of money: " .. args[2])
		end
		return
	end

	local target = FindPlayer(args[1])

	if target then
		local nick = ""
		target:SetNWInt("money", amount)
		target:SetNWString("moneyshow", amount)
		DB.StoreMoney(target, amount)

		if ply:EntIndex() == 0 then
			Msg("Set " .. target:Nick() .. "'s money to: " .. CUR .. amount)
			nick = "Console"
		else
			ply:PrintMessage(2, "Set " .. target:Nick() .. "'s money to: " .. CUR .. amount)
			nick = ply:Nick()
		end
		target:PrintMessage(2, nick .. " set your money to: " .. CUR .. amount)
	else
		if ply:EntIndex() == 0 then
			Msg("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_setmoney", ccSetMoney)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_setmoney [Nick|SteamID|UserID] <Amount> - Set a player's money to a specific amount.")

function ccGrantPriv(ply, cmd, args)
	if not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You're not a super admin!")
		return
	end

	local target = FindPlayer(args[2])

	if target then
		if args[1] == "tool" then
			DB.GrantPriv(target, TOOL)
			Notify(target, 1, 4, ply:Nick() .. " has granted you toolgun priveleges.")
		elseif args[1] == "admin" then
			DB.GrantPriv(target, ADMIN)
			Notify(target, 1, 4, ply:Nick() .. " has granted you admin priveleges.")
		elseif args[1] == "phys" then
			DB.GrantPriv(target, PHYS)
			Notify(target, 1, 4, ply:Nick() .. " has granted you physgun priveleges.")
		elseif args[1] == "prop" then
			DB.GrantPriv(target, PROP)
			Notify(target, 1, 4, ply:Nick() .. " has granted you prop spawn priveleges.")
		elseif args[1] == "ow" then
			DB.GrantPriv(target, OW)
			Notify(target, 1, 4, ply:Nick() .. " has granted you /ow priveleges.")
		elseif args[1] == "cp" then
			DB.GrantPriv(target, CP)
			Notify(target, 1, 4, ply:Nick() .. " has granted you /cp priveleges.")
		else
			if ply:EntIndex() == 0 then
				Msg("There is not a " .. args[1] .. " privilege!")
			else
				ply:PrintMessage(2, "There is not a " .. args[1] .. " privilege!")
			end
		end
	else
		if ply:EntIndex() == 0 then
			Msg("Could not find player: " .. args[2])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[2])
		end
		return
	end
end
concommand.Add("rp_grant", ccGrantPriv)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_grant [tool|phys|admin|prop|cp|ow] [Nick|SteamID|UserID] - Gives a privilege to a player.")

function ccRevokePriv(ply, cmd, args)
	if not ply:IsSuperAdmin() then
		ply:PrintMessage(2, "You're not a super admin!")
		return
	end

	local target = FindPlayer(args[2])

	if target then
		if args[1] == "tool" then
			DB.RevokePriv(target, TOOL)
			Notify(target, 1, 4, ply:Nick() .. " has revoked your toolgun priveleges.")
		elseif args[1] == "admin" then
			DB.RevokePriv(target, ADMIN)
			Notify(target, 1, 4, ply:Nick() .. " has revoked your admin priveleges.")
		elseif args[1] == "phys" then
			DB.RevokePriv(target, PHYS)
			Notify(target, 1, 4, ply:Nick() .. " has revoked your physgun priveleges.")
		elseif args[1] == "prop" then
			DB.RevokePriv(target, PROP)
			Notify(target, 1, 4, ply:Nick() .. " has revoked your prop spawn priveleges.")
		elseif args[1] == "ow" then
			DB.RevokePriv(target, OW)
			Notify(target, 1, 4, ply:Nick() .. " has revoked your /ow priveleges.")
		elseif args[1] == "cp" then
			DB.RevokePriv(target, CP)
			Notify(target, 1, 4, ply:Nick() .. " has revoked your /cp priveleges.")
		else
			if ply:EntIndex() == 0 then
				Msg("There is not a " .. args[1] .. " privilege!")
			else
				ply:PrintMessage(2, "There is not a " .. args[1] .. " privilege!")
			end
		end
	else
		if ply:EntIndex() == 0 then
			Msg("Could not find player: " .. args[2])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[2])
		end
		return
	end
end
concommand.Add("rp_revoke", ccRevokePriv)
AddHelpLabel(-1, HELP_CATEGORY_ADMINCMD, "rp_revoke [tool|phys|admin|prop|cp|ow] [Nick|SteamID|UserID] - Revokes a privilege from a player.")

function ccSWEPSpawn(ply, cmd, args)
	if CfgVars["adminsweps"] == 1 then
		if not (ply:EntIndex() == 0 or ply:IsAdmin() or ply:IsSuperAdmin()) then
			Notify(ply, 1, 2, "You're not an admin!")
			return
		end
	end
	--CCSpawnSWEP(ply, cmd, args)
end
concommand.Add("gm_giveswep", ccSWEPSpawn)

function ccSWEPGive(ply, cmd, args)
	if CfgVars["adminsweps"] == 1 then
		if not (ply:EntIndex() == 0 or ply:IsAdmin() or ply:IsSuperAdmin()) then
			Notify(ply, 1, 2, "You're not an admin!")
			return
		end
	else
		
	end
	--CCSpawnSWEP(ply, cmd, args)
end
concommand.Add("gm_spawnswep", ccSWEPGive)

function ccSENTSPawn(ply, cmd, args)
	if CfgVars["adminsents"] == 1 then
		if not (ply:EntIndex() == 0 or ply:IsAdmin() or ply:IsSuperAdmin()) then
			Notify(ply, 1, 2, "You're not an admin!")
			return
		end
	end
	--CCSpawnSENT(ply, cmd, args)
end
concommand.Add("gm_spawnsent", ccSENTSPawn)
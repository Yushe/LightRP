-------------
-- LightRP Reloaded
-- philxyz
-- Nov 1, 2008

-- This edit isn't a representation of my skillz
-------------
-- LightRP
-- Rick Darkaliono aka DarkCybo1
-- Jan 22, 2007
-- Done Jan 26, 2007

-- This script isn't a representation of my skillz
-------------

DeriveGamemode("sandbox")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_vgui.lua")
AddCSLuaFile("entity.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("scoreboard/admin_buttons.lua")
AddCSLuaFile("scoreboard/player_frame.lua")
AddCSLuaFile("scoreboard/player_infocard.lua")
AddCSLuaFile("scoreboard/player_row.lua")
AddCSLuaFile("scoreboard/scoreboard.lua")
AddCSLuaFile("scoreboard/vote_button.lua")
AddCSLuaFile("cl_helpvgui.lua")

DB = {}
CSFiles = {}
LRP = {}
CfgVars = {}

include("help.lua")
include("shared.lua")
include("data.lua")
include("player.lua")
include("chat.lua")
include("main.lua")
include("util.lua")
include("votes.lua")
include("admins.lua")
include("admincc.lua")
include("entity.lua")
include("bannedprops.lua")

AddHelpCategory(HELP_CATEGORY_CHATCMD, "Chat Commands")
AddHelpCategory(HELP_CATEGORY_CONCMD, "Console Commands")
AddHelpCategory(HELP_CATEGORY_ADMINTOGGLE, "Admin Toggle Commands (1 or 0!)")
AddHelpCategory(HELP_CATEGORY_ADMINCMD, "Admin Console Commands")

function includeCS(dir)
	AddCSLuaFile(dir)
	table.insert(CSFiles, dir)
end

local files = file.Find(GM.FolderName.."/gamemode/modules/*.lua", "LUA")
for k, v in pairs(files) do
	include("modules/" .. v)
end

-- You can toggle the below items:

-- 1 for YES
-- 0 for NO

CfgVars["ooc"] = 1 --OOC allowed
CfgVars["alltalk"] = 1 --All talk allowed
CfgVars["crosshair"] = 1 --Crosshairs enabled?
CfgVars["strictsuicide"] = 0 --Should players respawn where they suicided (regardless of they're arrested or not)
CfgVars["propertytax"] = 0 --Property taxes
CfgVars["teletojail"] = 1 --Should Criminals Be AUTOMATICALLY Teleported TO jail?
CfgVars["telefromjail"] = 1 --Should Jailed People be automatically Teleported FROM jail?
CfgVars["cit_propertytax"] = 0 --Just citizens have to pay property tax?
CfgVars["paydelay"] = 150 --Pay day delay (in seconds)
CfgVars["banprops"] = 1 --Prop banning
CfgVars["toolgun"] = 1 --Tool gun enabled?
CfgVars["physgun"] = 0 --Phys gun enabled?
CfgVars["allowedprops"] = 0 --Should players be only able to spawn "allowed" props?
CfgVars["propspawning"] = 1 --Prop spawning enabled?
CfgVars["adminsents"] = 0 --Should all SENTs be admin only?
CfgVars["adminsweps"] = 0 --Should all sweps be admin only?
CfgVars["cpvote"] = 1 --Should people be able to use /votecop?
CfgVars["owvote"] = 0 --Should people be able to use /voteow?
CfgVars["enforceplayermodel"] = 1 --Should player models be enforced? (Blocks using player models like zombie/combine/etc)
CfgVars["proppaying"] = 0 --Should players pay for props
CfgVars["letters"] = 1 --Allow letter writing
CfgVars["customspawns"] = 1 -- Custom spawn points enabled?
CfgVars["dmautokick"] = 1 -- Enable deathmatch auto-kick
CfgVars["allowvnocollide"] = 0 -- Whether or not to allow players to no-collide their vehicles (security)
CfgVars["cpvoting"] = 1 --Allow CP voting
CfgVars["owvoting"] = 0 --Allow OW voting
CfgVars["cptoowonly"] = 1 --Only CPs can do /voteow
CfgVars["demotetime"] = 120 -- Amount of time a player is banned from rejoining a team after being demoted

-- You can set the exact value of the below items:

CfgVars["maxow"] = 3 --Maximum amount of OW you can have
CfgVars["maxcps"] = 99 --Max number of CPs you can have
CfgVars["propcost"] = 10 --Prop cost
CfgVars["doorcost"] = 30 -- Cost to buy a door.
CfgVars["vehiclecost"] = 40 -- Car/Airboat Cost
CfgVars["dmgracetime"] = 30 -- Players have a 30 second grace time by default
CfgVars["dmmaxkills"] = 3 -- ...in which they can make a maximum of 3 kills

CfgVars["refreshglobals"] = 0

SetGlobalInt("nametag", 1) --Should names show?
SetGlobalInt("jobtag", 1) --Should jobs show?
SetGlobalInt("globalshow", 0) --Should we see player info from across the map?
SetGlobalInt("jailtimer", 120) --Jail time
SetGlobalString("cmdprefix", "/") --Prefix before any chat commands

GenerateChatCommandHelp()

function GM:Initialize()
	self.BaseClass:Initialize()
	DB.Init()
	timer.Simple(20, RefreshGlobals)
end

function GM:ShowTeam(ply)
	local trace = {}

	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	local ent = tr.Entity

	if ply:IsSuperAdmin() and IsValid(ent) and ent:IsDoor() and ply:EyePos():Distance(ent:GetPos()) <= 65 then
		-- Toggle the door's ownability
		ent:SetNWBool("nonOwnable", not ent:GetNWBool("nonOwnable"))

		-- Save it for future map loads
		DB.StoreDoorOwnability(ent)
	end
end

function GM:PlayerNoClip(ply, on)
	if ply:IsAdmin() then
		return true
	end

	return false
end

hook.Add( "PhysgunPickup", "AllowPlayerPickup", function( ply, ent )
	if ( ply:IsAdmin() and ent:IsPlayer() ) then
		return true
	end
end )

function GM:GetFallDamage(ply, speed)
	return(speed * 0.0275)
end


for k, v in pairs(player.GetAll()) do
	v:NewData()
end

AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showhelp - Toggle help menu (bind this to F1 if you haven't already)")
AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showspare1 - Toggle vote clicker (bind this to F3 if you haven't already)")
AddHelpLabel(-1, HELP_CATEGORY_CONCMD, "gm_showspare2 - Own/unown doors (bind this to F4 if you haven't already)")

function ShowSpare1(ply)
	ply:ConCommand("gm_showspare1\n")
end
concommand.Add("gm_spare1", ShowSpare1)

function ShowSpare2(ply)
	ply:ConCommand("gm_showspare2\n")
end
concommand.Add("gm_spare2", ShowSpare2)

function GM:ShowHelp(sender)
	--umsg.Start("ToggleHelp", ply) umsg.End()
	
	--This isn't the best way of doing this but oh well its temporary
	sender:PrintMessage(HUD_PRINTTALK, "A list of LightRP's commands & features has been printed to your console.")
	sender:PrintMessage(HUD_PRINTTALK, "To enable console go to Options->Advanced->Enable developer console.")
	sender:PrintMessage(HUD_PRINTTALK, "This is just temporary until I can figure out why the <f1> refuses to work.")
	
	sender:PrintMessage(HUD_PRINTCONSOLE, "======================================================================================================".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "LightRP Commands".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "======================================================================================================".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/job <Job Name> - Set your job".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/w <Message> - Whisper a message".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/y <Message> - Yell a message".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/g <Message> - Group message".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/r <Message> - Cop radio, Civil Protection & Overwatch only".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "// or /ooc - OOC speak".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/pm <Name/Partial Name> <Message> - Send another player a PM.".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "Letters - Press use key to read a letter.  Look away and press use key again to stop reading a letter.".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/write <Message> - Write a letter. Use // to go down a line.".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/type <Message> - Type a letter.  Use // to go down a line.".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/give <Amount> - Give a money amount".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/moneydrop <Amount> - Drop a money amount".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/title <Name> - Give a door you own, a title".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/addowner or /ao <Name> - Allow another to player to own your door".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/removeowner or /ro <Name> - Remove an owner from your door".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/demote <Name> - Start a vote to demote a player.".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/votecop - Vote to be a Cop".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/voteow - Vote to be Overwatch".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/citizen - Become a Citizen".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/cp - Become a Civil Protection if you're on the admin's Cop list".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/ow - Become a Combine Overwatch if you're on the admin's Cop list".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "/cr <Message> - Request the Combine".."\n")
	sender:PrintMessage(HUD_PRINTCONSOLE, "======================================================================================================".."\n")
	if sender:IsAdmin() then
		sender:PrintMessage(HUD_PRINTCONSOLE, "LightRP Admin Console Commands".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "======================================================================================================".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_propertytax - Enable/disable property tax".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_citpropertytax - Enable/disable property tax that is exclusive only for citizens")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_bannedprops - Enable/disable certain props being banned (overrides rp_allowedprops)".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_allowedprops - Enable/disable certain props being allowed".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_strictsuicide - Enable/disable whether players should spawn where they suicided (regardless if they're arrested.".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_ooc - Enable/disable if OOC tags are enabled".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_alltalk - Enable for global chat, disable for local chat".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_globaltags - Enable/disable player info (Name/Job/etc) from being displayed across the map".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_showcrosshairs - Enable/disable if crosshairs are visible".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_showjob - Enable/disable if job information should be public to other players".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_showname - Enable/disable if other players can see your name".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_jailtimer <Number> - Sets the jailtimer. (in seconds)".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_physgun - Enable/disable Players spawning with physguns.".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_doorcost <Number> - Sets the cost of a door.".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_vehiclecost <Number> - Sets the cost of a vehicle (To own it).".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_dm_gracetime <Number> - Number of seconds after killing a player that the killer will be watched for DM.".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_dm_maxkills <Number> - Max number of kills allowed during rp_dm_gracetime to avoid being auto-kicked for DM".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_demotetime <Number> - Number of seconds before a player can rejoin a team after demotion from that team.".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_allowvehiclenocollide - Enable/disable the ability to no-collide a vehicle (for security).".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_toolgun - Enable/disable if players spawn with toolguns.  (Excluding admins)".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_propspawning - Enable/disable if players can spawn props.  (Excluding admins)".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_proppaying - Enable/disable if players should pay for props".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_adminsweps - Enable/disable if SWEPs should be admin-only.".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_adminsents - Enable/disable if SENTs should be admin-only.".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_enforcemodels - Enable/disable is players should not be able to use player models like Combine/Zombies.".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_letters - Enable/disable letter writing/typing.".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_cpvoting - Enable/disable player's ability to do a vote cop".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_owvoting - Enable/disable player's ability to do a vote OW".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_cptoow - Enable/disable if only the civil protection can do /voteow".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_customspawns - Enable/disable whether custom spawns should be used.".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "rp_dm_autokick - Enable/disable Auto-kick of deathmatchers.".."\n")
		sender:PrintMessage(HUD_PRINTCONSOLE, "======================================================================================================".."\n")
	end
end

GM.Name = "LightRP"
GM.Author = "Fixed by Yushe. Created by: Rick Darkaliono + philxyz"

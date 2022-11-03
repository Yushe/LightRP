DeriveGamemode("sandbox")

GUIToggled = false
HelpToggled = false

HelpLabels = {}
HelpCategories = {}

AdminTellAlpha = -1
AdminTellStartTime = 0
AdminTellMsg = ""

if HelpVGUI then HelpVGUI:Remove() end

HelpVGUI = nil

StunStickFlashAlpha = -1

function GM:Initialize()
	self.BaseClass:Initialize()
end

function DisplayNotify(msg)
	local txt = msg:ReadString()
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())

	-- Log to client console
	print(txt)
end
usermessage.Hook("_Notify", DisplayNotify)

function LoadModules(msg)
	local num = msg:ReadShort()

	for n = 1, num do
		include("LightRP/gamemode/modules/" .. msg:ReadString())
	end
end
usermessage.Hook("LoadModules", LoadModules)

include("shared.lua")
include("cl_vgui.lua")
include("entity.lua")
include("cl_scoreboard.lua")
include("cl_helpvgui.lua")

surface.CreateFont("AckBarWriting",{font = "akbar", size = 20, weight = 500, true, false})

function GetTextHeight(font, str)
	surface.SetFont(font)
	local w, h = surface.GetTextSize(str)
	
	return h
end

function DrawPlayerInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()

	pos.z = pos.z + 14
	pos = pos:ToScreen()

	if GetGlobalInt("nametag") == 1 then
		draw.DrawText(ply:Nick(), "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:Nick(), "TargetID", pos.x, pos.y, team.GetColor(ply:Team()), 1)
	end

	if GetGlobalInt("jobtag") == 1 then
		draw.DrawText(ply:GetNWString("job"), "TargetID", pos.x + 1, pos.y + 21, Color(0, 0, 0, 255), 1)
		draw.DrawText(ply:GetNWString("job"), "TargetID", pos.x, pos.y + 20, Color(255, 255, 255, 200), 1)
	end
end

function GM:HUDPaint()
	self.BaseClass:HUDPaint()
	
	local hx = 9
	local hy = ScrH() - 25
	local hw = 190
	local hh = 10

	draw.RoundedBox(6, hx - 4, hy - 4, hw + 8, hh + 8, Color(0, 0, 0, 200))

	if LocalPlayer():Health() > 0 then
		draw.RoundedBox(4, hx, hy, math.Clamp(hw * (LocalPlayer():Health() / 100), 0, 190), hh, Color(140, 0, 0, 180))
	end

	draw.DrawText(LocalPlayer():Health(), "TargetID", hx + hw / 2, hy - 6, Color(255, 255, 255, 200), 1)

	draw.DrawText("Job: " .. LocalPlayer():GetNWString("job").. "\n" .. CUR .. LocalPlayer():GetNWInt("money"), "TargetID", hx + 2, hy - 49, Color(0, 0, 0, 200), 0)
	draw.DrawText("Job: " .. LocalPlayer():GetNWString("job").. "\n" .. CUR .. LocalPlayer():GetNWInt("money"), "TargetID", hx, hy - 50, Color(255, 255, 255, 200), 0)

	local function DrawDisplay()

		local tr = LocalPlayer():GetEyeTrace()
		local superAdmin = LocalPlayer():IsSuperAdmin()

		if GetGlobalInt("globalshow") == 1 then
			for k, v in pairs(player.GetAll()) do
				DrawPlayerInfo(v)
			end
		end

		if IsValid(tr.Entity) and tr.Entity:GetPos():Distance(LocalPlayer():GetPos()) < 400 then
			local pos = LocalPlayer():GetEyeTrace().HitPos:ToScreen()
			
			if GetGlobalInt("globalshow") == 0 then
				if tr.Entity:IsPlayer() then DrawPlayerInfo(tr.Entity) end
			end

			if tr.Entity:IsOwnable() then
				local ownerstr = ""
				local ent = ents.GetByIndex(tr.Entity:EntIndex())

				if ent:GetNWInt("Ownerz") > 0 then
					if IsValid(player.GetByID(ent:GetNWInt("Ownerz"))) then
						ownerstr = player.GetByID(ent:GetNWInt("Ownerz")):Nick() .. "\n"
					end
				end

				local num = ent:GetNWInt("OwnerNum")

				for n = 1, num do
					if (ent:GetNWInt("Owners" .. n) or -1) > -1 then
						if IsValid(player.GetByID(ent:GetNWInt("Owners" .. n))) then
							ownerstr = ownerstr .. player.GetByID(ent:GetNWInt("Owners" .. n)):Nick() .. "\n"
						end
					end
				end

				num = ent:GetNWInt("AllowedNum")

				for n = 1, num do
					if ent:GetNWInt("Allowed" .. n) == LocalPlayer():EntIndex() then
						ownerstr = ownerstr .. "You are allowed to co-own this door\n(Press F4 to own)"
					elseif ent:GetNWInt("Allowed" .. n) > -1 then
						if IsValid(player.GetByID(ent:GetNWInt("Allowed" .. n))) then
							ownerstr = ownerstr .. player.GetByID(ent:GetNWInt("Allowed" .. n)):Name() .. " is allowed to co-own this door\n"
						end
					end
				end

				if not LocalPlayer():InVehicle() then
					local blocked = ent:GetNWBool("nonOwnable")
					local st = nil
					local whiteText = false -- false for red, true for white text

					if ent:IsOwned() then
						whiteText = true

						if superAdmin then
							if blocked then
								st = ent:GetNWString("dTitle") .. "\n(Press F2 to allow ownership)"
							else
								if ownerstr == "" then
									st = ent:GetNWString("title") .. "\n(Press F2 to disallow ownership)"
								else
									st = ent:GetNWString("title") .. "\nOwned by:\n" .. ownerstr .. "(Press F2 to disallow ownership)"
								end
							end
						else
							if blocked then
								st = ent:GetNWString("dTitle")
							else
								if ownerstr == "" then
									st = ent:GetNWString("title")
								else
									st = ent:GetNWString("title") .. "\nOwned by:\n" .. ownerstr
								end
							end
						end
					else
						if superAdmin then
							if blocked then
								whiteText = true
								st = ent:GetNWString("dTitle") .. "\n(Press F2 to allow ownership)"
							else
								st = "Unowned\n(Press F4 to own)\n(Press F2 to disallow ownership)"
							end
						else
							if blocked then
								whiteText = true
								st = ent:GetNWString("dTitle")
							else
								st = "Unowned\n(Press F4 to own)"
							end
						end
					end

					if whiteText then
						draw.DrawText(st, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 200), 1)
						draw.DrawText(st, "TargetID", pos.x, pos.y, Color(255, 255, 255, 200), 1)
					else
						draw.DrawText(st, "TargetID", pos.x + 1, pos.y + 1, Color(0, 0, 0, 255), 1)
						draw.DrawText(st, "TargetID", pos.x, pos.y, Color(128, 30, 30, 255), 1)
					end
				end
			end
		end

		if PanelNum > 0 then
			draw.RoundedBox(2, 0, 0, 100, 20, Color(0, 0, 0, 128))
			draw.DrawText("Hit F3 to vote", "ChatFont", 2, 2, Color(255, 255, 255, 200), 0)
		end
	end

	if LetterAlpha > -1 then
		if LetterY > ScrH() * .25 then
			LetterY = math.Clamp(LetterY - 300 * FrameTime(), ScrH() * .25, ScrH() / 2)
		end

		if LetterAlpha < 255 then
			LetterAlpha = math.Clamp(LetterAlpha + 400 * FrameTime(), 0, 255)
		end

		local font = ""

		if LetterType == 1 then
			font = "AckBarWriting"
		else
			font = "Default"
		end

		draw.RoundedBox(2, ScrW() * .2, LetterY, ScrW() * .8 - (ScrW() * .2), ScrH(), Color(255, 255, 255, math.Clamp(LetterAlpha, 0, 200)))
		draw.DrawText(LetterMsg, font, ScrW() * .25 + 20, LetterY + 80, Color(0, 0, 0, LetterAlpha), 0)
	end

	DrawDisplay()

	if StunStickFlashAlpha > -1 then
		surface.SetDrawColor(255, 255, 255, StunStickFlashAlpha)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		StunStickFlashAlpha = math.Clamp(StunStickFlashAlpha + 1500 * FrameTime(), 0, 255)
	end

	if AdminTellAlpha > -1 then
		local dir = 1

		if CurTime() - AdminTellStartTime > 10 then
			dir = -1

			if AdminTellAlpha <= 0 then
				AdminTellAlpha = -1
			end
		end

		if AdminTellAlpha > -1 then
			AdminTellAlpha = math.Clamp(AdminTellAlpha + FrameTime() * dir * 300, 0, 190)
			draw.RoundedBox(4, 10, 10, ScrW() - 20, 100, Color(0, 0, 0, AdminTellAlpha))
			draw.DrawText("The Admin Tells You:", "GModToolName", ScrW() / 2 + 10, 10, Color(255, 255, 255, AdminTellAlpha), 1)
			draw.DrawText(AdminTellMsg, "ChatFont", ScrW() / 2 + 10, 65, Color(200, 30, 30, AdminTellAlpha), 1)
		end
	end
end

function GM:HUDShouldDraw(name)
	if name == "CHudHealth" or name == "CHudBattery" or name == "CHudSuitPower" then return false end
	if HelpToggled and name == "CHudChat" then return false end

	return true
end

function EndStunStickFlash()
	StunStickFlashAlpha = -1
end

function StunStickFlash()
	if StunStickFlashAlpha == -1 then
		StunStickFlashAlpha = 0
	end

	timer.Create(LocalPlayer():EntIndex() .. "StunStickFlashTimer", .3, 1, EndStunStickFlash)
end
usermessage.Hook("StunStickFlash", StunStickFlash)

function ToggleHelp()
	if not HelpVGUI then
		HelpVGUI = vgui.Create("HelpVGUI")
	end

	HelpToggled = not HelpToggled

	HelpVGUI.HelpX = HelpVGUI.StartHelpX
	HelpVGUI:SetVisible(HelpToggled)
	gui.EnableScreenClicker(HelpToggled)
end
usermessage.Hook("ToggleHelp", ToggleHelp)

function AdminTell(msg)
	AdminTellStartTime = CurTime()
	AdminTellAlpha = 0
	AdminTellMsg = msg:ReadString()
end
usermessage.Hook("AdminTell", AdminTell)

LetterY = 0
LetterAlpha = -1
LetterMsg = ""
LetterType = 0
LetterStartTime = 0
LetterPos = Vector(0, 0, 0)

function ShowLetter(msg)
	LetterType = msg:ReadShort()
	LetterPos = msg:ReadVector()
	LetterMsg = msg:ReadString()
	LetterY = ScrH() / 2
	LetterAlpha = 0
	LetterStartTime = CurTime()
end
usermessage.Hook("ShowLetter", ShowLetter)

function GM:Think()
	if LetterAlpha > -1 and LocalPlayer():GetPos():Distance(LetterPos) > 125 then
		LetterAlpha = -1
	end
end

function KillLetter(msg)
	LetterAlpha = -1
end
usermessage.Hook("KillLetter", KillLetter)

function UpdateHelp()
	function tDelayHelp()
		if HelpVGUI then
			HelpVGUI:Remove()

			if HelpToggled then
				HelpVGUI = vgui.Create("HelpVGUI")
			end
		end
	end
	timer.Simple(.5, tDelayHelp)
end
usermessage.Hook("UpdateHelp", UpdateHelp)

function ToggleClicker()
	GUIToggled =  not GUIToggled
	gui.EnableScreenClicker(GUIToggled)

	for k, v in pairs(VoteVGUI) do
		v:SetMouseInputEnabled(GUIToggled)
	end
end
usermessage.Hook("ToggleClicker", ToggleClicker)

function AddHelpLabel(msg)
	local id = msg:ReadShort()
	local category = msg:ReadShort()
	local text = msg:ReadString()
	local constant = msg:ReadShort()

	local function tAddHelpLabel(id, category, text, constant)
		for k, v in pairs(HelpLabels) do
			if v.id == id then
				v.text = text
				return
			end
		end

		table.insert(HelpLabels, { id = id, category = category, text = text, constant = constant })
	end

	timer.Simple(.01, tAddHelpLabel, id, category, text, constant)
end
usermessage.Hook("AddHelpLabel", AddHelpLabel)

function ChangeHelpLabel(msg)
	local id = msg:ReadShort()
	local text = msg:ReadString()

	local function tChangeHelpLabel(id, text)
		for k, v in pairs(HelpLabels) do
			if v.id == id then
				v.text = text
				return
			end
		end
	end

	timer.Simple(.01, tChangeHelpLabel, id, text)
end
usermessage.Hook("ChangeHelpLabel", ChangeHelpLabel)

function AddHelpCategory(msg)
	local id = msg:ReadShort()
	local text = msg:ReadString()
	local function tAddHelpCategory(id, text)
		table.insert(HelpCategories, { id = id, text = text })
	end

	timer.Simple(.01, tAddHelpCategory, id, text)
end
usermessage.Hook("AddHelpCategory", AddHelpCategory)

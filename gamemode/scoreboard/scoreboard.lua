include( "player_row.lua" )
include( "player_frame.lua" )

surface.CreateFont("ScoreboardHeader", {font = "coolvetica", size = 32, weight = 500, antialias = true})
surface.CreateFont("ScoreboardSubtitle", {font = "coolvetica", size = 22, weight = 500, antialias = true})

local texGradient 	= surface.GetTextureID( "gui/center_gradient" )
local texLogo 		= surface.GetTextureID( "gui/gmod_logo" )


local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	SCOREBOARD = self

	self.Hostname = vgui.Create( "DLabel", self )
	self.Hostname:SetText( GetHostName() )
	
	self.Description = vgui.Create( "DLabel", self )
	self.Description:SetText("LightRP Reloaded - Rick Darkaliono, philxyz, Fixed by Yushe.")
	
	self.PlayerFrame = vgui.Create( "PlayerFrame", self )
	
	self.PlayerRows = {}

	self:UpdateScoreboard()
	
	// Update the scoreboard every 1 second
	timer.Create( "ScoreboardUpdater", 1, 0, self.UpdateScoreboard, self )
	
	if GM10_IsDarkRP then
		self.lblJobName = vgui.Create( "DLabel", self )
		self.lblJobName:SetText( "Job" )	
	end
	
	self.lblPing = vgui.Create( "DLabel", self )
	self.lblPing:SetText( "Ping" )
	
	self.lblKills = vgui.Create( "DLabel", self )
	self.lblKills:SetText( "Kills" )
	
	self.lblDeaths = vgui.Create( "DLabel", self )
	self.lblDeaths:SetText( "Deaths" )

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:AddPlayerRow( ply )

	local button = vgui.Create( "ScorePlayerRow", self.PlayerFrame:GetCanvas() )
	button:SetPlayer( ply )
	self.PlayerRows[ ply ] = button

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:GetPlayerRow( ply )

	return self.PlayerRows[ ply ]

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

	draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 170, 170, 170, 255 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() ) 
	
	// White Inner Box
	draw.RoundedBox( 4, 4, self.Description.y - 4, self:GetWide() - 8, self:GetTall() - self.Description.y - 4, Color( 230, 230, 230, 200 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 4, self.Description.y - 4, self:GetWide() - 8, self:GetTall() - self.Description.y - 4 )
	
	// Sub Header
	draw.RoundedBox( 4, 5, self.Description.y - 3, self:GetWide() - 10, self.Description:GetTall() + 5, Color( 150, 200, 50, 200 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 4, self.Description.y - 4, self:GetWide() - 8, self.Description:GetTall() + 8 ) 
	
	// Logo!
	surface.SetTexture( texLogo )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, 0, 128, 128 ) 
	
	
	
	//draw.RoundedBox( 4, 10, self.Description.y + self.Description:GetTall() + 6, self:GetWide() - 20, 12, Color( 0, 0, 0, 50 ) )

end


/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	self:SetSize(640, ScrH() * 0.95)
	
	self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2)
	
	self.Hostname:SizeToContents()
	self.Hostname:SetPos(115, 16)
	
	self.Description:SizeToContents()
	self.Description:SetPos(128, 64)
	
	self.PlayerFrame:SetPos(5, self.Description.y + self.Description:GetTall() + 20)
	self.PlayerFrame:SetSize(self:GetWide() - 10, self:GetTall() - self.PlayerFrame.y - 10)
	
	local y = 0
	
	local PlayerSorted = {}
	
	for k, v in pairs(self.PlayerRows) do
		table.insert(PlayerSorted, v)
	end
	
	table.sort(PlayerSorted, function (a , b) return a:HigherOrLower(b) end)
	
	for k, v in ipairs(PlayerSorted) do
		v:SetPos(0, y)	
		v:SetSize(self.PlayerFrame:GetWide(), v:GetTall())
		
		self.PlayerFrame:GetCanvas():SetSize(self.PlayerFrame:GetCanvas():GetWide(), y + v:GetTall())
		
		y = y + v:GetTall() + 1
	end
	
	self.Hostname:SetText(GetGlobalString("ServerName"))
	
	self.lblPing:SizeToContents()
	self.lblKills:SizeToContents()
	self.lblDeaths:SizeToContents()
	
	self.lblPing:SetPos(self:GetWide() - 50 - self.lblPing:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3 )
	self.lblDeaths:SetPos(self:GetWide() - 50*2 - self.lblDeaths:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3 )
	self.lblKills:SetPos(self:GetWide() - 50*3 - self.lblKills:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3 )
	
	--self.lblKills:SetFont("DefaultSmall")
	--self.lblDeaths:SetFont("DefaultSmall")
end

/*---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.Hostname:SetFont( "ScoreboardHeader" )
	self.Description:SetFont( "ScoreboardSubtitle" )
	
	self.Hostname:SetTextColor( Color( 0, 0, 0, 200 ) )
	self.Description:SetTextColor( color_white )
	
	self.lblPing:SetFont( "DefaultSmall" )
	self.lblKills:SetFont( "DefaultSmall" )
	self.lblDeaths:SetFont( "DefaultSmall" )
	
	self.lblPing:SetTextColor( Color( 0, 0, 0, 100 ) )
	self.lblKills:SetTextColor( Color( 0, 0, 0, 100 ) )
	self.lblDeaths:SetTextColor( Color( 0, 0, 0, 100 ) )

	if GM10_IsDarkRP then
		self.lblJobName:SetFont( "DefaultSmall" )
		self.lblJobName:SetTextColor( Color( 0, 0, 0, 100 ) )
	end
end


function PANEL:UpdateScoreboard( force )

	if ( !force && !SCOREBOARD:IsVisible() ) then return end

	for k, v in pairs( SCOREBOARD.PlayerRows ) do
	
		if ( !k:IsValid() ) then
		
			v:Remove()
			SCOREBOARD.PlayerRows[ k ] = nil
			
		end
	
	end
	
	local PlayerList = player.GetAll()	
	for id, pl in pairs( PlayerList ) do
		
		if ( !SCOREBOARD:GetPlayerRow( pl ) ) then
		
			SCOREBOARD:AddPlayerRow( pl )
		
		end
		
	end
	
	// Always invalidate the layout so the order gets updated
	SCOREBOARD:InvalidateLayout()

end

vgui.Register( "ScoreBoard", PANEL, "Panel" )
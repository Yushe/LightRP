
include( "player_infocard.lua" )

surface.CreateFont("ScoreboardPlayerName", {font = "coolvetica", size = 20, weight = 500, antialias = true})

local texGradient = surface.GetTextureID( "gui/center_gradient" )

local texRatings = {}
texRatings[ 'none' ] 		= Material("icon16/user.png")
texRatings[ 'smile' ] 		= Material("icon16/emoticon_smile.png")
texRatings[ 'bad' ] 		= Material("icon16/exclamation.png")
texRatings[ 'love' ] 		= Material("icon16/heart.png")
texRatings[ 'artistic' ] 	= Material("icon16/palette.png")
texRatings[ 'star' ] 		= Material("icon16/star.png")
texRatings[ 'builder' ] 	= Material("icon16/wrench.png")

Material("icon16/emoticon_smile.png")
local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/

function PANEL:Paint()

	if ( !IsValid( self.Player ) ) then return end

	local color = color_white
	
	if GM10_IsDarkRP then	
		color = team.GetColor(self.Player:Team())
	else
		color = Color( 100, 150, 245, 255 )		
		
		if ( self.Player:Team() == TEAM_CONNECTING ) then
			color = Color( 200, 120, 50, 255 )
		elseif ( self.Player:IsAdmin() ) then
			color = Color( 30, 200, 50, 255 )		
		elseif ( self.Player:SteamID() == "STEAM_0:1:16806171" ) then //just a little pink color for me, i hope that's okay with you.
			color = Color( 255, 105, 180, 255 )
		end	
	end
	
	if ( self.Armed ) then
		color = Color( 110, 160, 245, 255 )
	end
	
	if ( self.Selected ) then
		color = Color( 50, 100, 245, 255 )
	end
	
	if ( self.Player == LocalPlayer() ) then
	
		color.r = color.r + math.sin( CurTime() * 8 ) * 10
		color.g = color.g + math.sin( CurTime() * 8 ) * 10
		color.b = color.b + math.sin( CurTime() * 8 ) * 10
	
	end

	if ( self.Open || self.Size != self.TargetSize ) then
	
		draw.RoundedBox( 4, 0, 16, self:GetWide(), self:GetTall() - 16, color )
		draw.RoundedBox( 4, 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2, Color( 250, 250, 245, 255 ) )
		
		surface.SetTexture( texGradient )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( 2, 16, self:GetWide()-4, self:GetTall() - 16 - 2 ) 
	
	end
	
	draw.RoundedBox( 4, 0, 0, self:GetWide(), 24, color )
	
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), 24 ) 
	
	surface.SetMaterial( self.texRating )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 4, 4, 16, 16 ) 	
	
	return true

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )

	self.Player = ply
	
	self.infoCard:SetPlayer( ply )
	
	self:UpdatePlayerData()

end

function PANEL:CheckRating( name, count )

	if ( self.Player:GetNW2Int( "Rating."..name, 0 ) > count ) then
		count = self.Player:GetNW2Int( "Rating."..name, 0 )
		self.texRating = texRatings[ name ]
	end
	
	return count

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()

	if ( !self.Player ) then return end
	if ( !IsValid( self.Player) ) then return end

	self.lblName:SetText( self.Player:Nick() )
	if GM10_IsDarkRP then		
		self.lblJob:SetText( team.GetName( self.Player:Team() ) )
	end
	self.lblFrags:SetText( self.Player:Frags() )
	self.lblDeaths:SetText( self.Player:Deaths() )
	self.lblPing:SetText( self.Player:Ping() )
	
	// Work out what icon to draw
	self.texRating = Material("icon16/emoticon_smile.png")
	
	self.texRating = texRatings[ 'none' ]
	local count = 0
	
	count = self:CheckRating( 'smile', count )
	count = self:CheckRating( 'love', count )
	count = self:CheckRating( 'artistic', count )
	count = self:CheckRating( 'star', count )
	count = self:CheckRating( 'builder', count )
	
	count = self:CheckRating( 'bad', count )
	
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()

	self.Size = 24
	self:OpenInfo( false )
	
	self.infoCard	= vgui.Create( "ScorePlayerInfoCard", self )
	
	self.lblName 	= vgui.Create( "DLabel", self )
	if GM10_IsDarkRP then		
		self.lblJob 	= vgui.Create( "DLabel", self )
		self.lblJob:SetMouseInputEnabled( false )
	end
	self.lblFrags 	= vgui.Create( "DLabel", self )
	self.lblDeaths 	= vgui.Create( "DLabel", self )
	self.lblPing 	= vgui.Create( "DLabel", self )
	
	// If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( false )
	self.lblFrags:SetMouseInputEnabled( false )
	self.lblDeaths:SetMouseInputEnabled( false )
	self.lblPing:SetMouseInputEnabled( false )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.lblName:SetFont( "ScoreboardPlayerName" )
	if GM10_IsDarkRP then		
		self.lblJob:SetFont( "ScoreboardPlayerName" )
		self.lblJob:SetTextColor( color_white )
	end
	self.lblFrags:SetFont( "ScoreboardPlayerName" )
	self.lblDeaths:SetFont( "ScoreboardPlayerName" )
	self.lblPing:SetFont( "ScoreboardPlayerName" )
	
	self.lblName:SetTextColor( color_white )
	self.lblFrags:SetTextColor( color_white )
	self.lblDeaths:SetTextColor( color_white )
	self.lblPing:SetTextColor( color_white )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:DoClick( x, y )

	if ( self.Open ) then
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	else
		surface.PlaySound( "ui/buttonclick.wav" )
	end

	self:OpenInfo( !self.Open )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:OpenInfo( bool )

	if ( bool ) then
		self.TargetSize = 150
	else
		self.TargetSize = 24
	end
	
	self.Open = bool

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()

	if ( self.Size != self.TargetSize ) then
	
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	//	self:GetParent():InvalidateLayout()
	
	end
	
	if ( !self.PlayerUpdate || self.PlayerUpdate < CurTime() ) then
	
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
		
	end

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( self:GetWide(), self.Size )
	
	self.lblName:SizeToContents()
	self.lblName:SetPos( 24, 3 )
	
	if GM10_IsDarkRP then
		self.lblJob:SizeToContents()
	
		local jobW, jobH = surface.GetTextSize( self.lblJob:GetText() )
		
		self.lblJob:SetPos( self:GetWide()/2 - jobW/2.5, 3 )	
	end
	
	local COLUMN_SIZE = 50
	
	self.lblPing:SetPos( self:GetWide() - COLUMN_SIZE * 1, 3 )
	self.lblDeaths:SetPos( self:GetWide() - COLUMN_SIZE * 2, 3 )
	self.lblFrags:SetPos( self:GetWide() - COLUMN_SIZE * 3, 3 )
	
	if ( self.Open || self.Size != self.TargetSize ) then
	
		self.infoCard:SetVisible( true )
		self.infoCard:SetPos( 4, self.lblName:GetTall() + 10 )
		self.infoCard:SetSize( self:GetWide() - 8, self:GetTall() - self.lblName:GetTall() - 10 )
	
	else
	
		self.infoCard:SetVisible( false )
	
	end
	
	

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:HigherOrLower( row )

	if ( !IsValid( self.Player ) || self.Player:Team() == TEAM_CONNECTING ) then return false end
	if ( !IsValid( row.Player ) || row.Player:Team() == TEAM_CONNECTING ) then return true end
	
	if ( self.Player:Frags() == row.Player:Frags() ) then
	
		return self.Player:Deaths() < row.Player:Deaths()
	
	end

	return self.Player:Frags() > row.Player:Frags()

end


vgui.Register( "ScorePlayerRow", PANEL, "Button" )
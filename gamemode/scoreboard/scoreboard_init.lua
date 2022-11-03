
hook.Add( "Initialize", "GM10RemoveOldScoreboard", function()
	GAMEMODE.ScoreboardShow = nil 
    GAMEMODE.ScoreboardHide = nil
    GAMEMODE.HUDDrawScoreBoard = nil
	
	if GAMEMODE.Name == "DarkRP" then
		hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
		hook.Remove("ScoreboardShow", "FAdmin_scoreboard")		
		
		GM10_IsDarkRP = true
	end
end )

include( "scoreboard.lua" )

local pScoreBoard = nil


/*---------------------------------------------------------
   Name: gamemode:CreateScoreboard( )
   Desc: Creates/Recreates the scoreboard
---------------------------------------------------------*/
function CreateGM10Scoreboard()

	if ( pScoreBoard ) then
	
		pScoreBoard:Remove()
		pScoreBoard = nil
	
	end

	pScoreBoard = vgui.Create( "ScoreBoard" )
	
end

/*---------------------------------------------------------
   Name: gamemode:ScoreboardShow( )
   Desc: Sets the scoreboard to visible
---------------------------------------------------------*/
hook.Add( "ScoreboardShow", "GM10ScoreboardShow", function()

	GAMEMODE.ShowScoreboard = true
	gui.EnableScreenClicker( true )
	
	if ( !pScoreBoard ) then
		CreateGM10Scoreboard()
	end
	
	pScoreBoard:SetVisible( true )
	pScoreBoard:UpdateScoreboard( true )
	
end )

/*---------------------------------------------------------
   Name: gamemode:ScoreboardHide( )
   Desc: Hides the scoreboard
---------------------------------------------------------*/
hook.Add( "ScoreboardHide", "GM10ScoreboardHide", function()	

	GAMEMODE.ShowScoreboard = false
	gui.EnableScreenClicker( false )
	
	if ( pScoreBoard ) then pScoreBoard:SetVisible( false ) end
	
end )


includeCS( "HungerMod/cl_init.lua" );
 
include( "HungerMod/entity.lua" );
include( "HungerMod/player.lua" );
 
HM = { }
FoodItems = { }
 
SetGlobalInt( "hungermod", 1 ); --Hunger mod is enabled or disabled
 
CfgVars["starverate"] = 3; --How much health is taken away per second when starving
CfgVars["hungerspeed"] = 2; --How much energy should deteriate every second
CfgVars["foodcost"] = 12; --Cost of food
CfgVars["foodpay"] = 1; --Whether there's a special spawning price for food
CfgVars["foodspawn"] = 1; --If players can spawn food props or not
 
function AddFoodItem( mdl, amount )
 
    table.insert( FoodItems, { model = mdl, amount = amount } );
 
end
 
function HM.PlayerSpawn( ply )
 
    ply:SetNWInt( "Energy", 100 );
 
end
hook.Add( "PlayerSpawn", "HM.PlayerSpawn", HM.PlayerSpawn );
 
function HM.PlayerSpawnProp( ply, model )
 
    for k, v in pairs( FoodItems ) do
   
        if( v.model == model ) then
       
            if( CfgVars["foodspawn"] == 0 ) then return false; end
           
            if( CfgVars["foodpay"] == 1 ) then
           
                if( not GAMEMODE.BaseClass:PlayerSpawnProp( ply, model ) ) then return false; end
               
                if( ply:GetTable().Arrested ) then return false; end
                if( ( CfgVars["allowedprops"] == 0 and CfgVars["banprops"] == 0 ) or ply:IsAdmin() ) then allowed = true; end
                if( CfgVars["propspawning"] == 0 ) then return false; end
   
                if( CfgVars["allowedprops"] == 1 ) then
               
                    for n, m in pairs( AllowedProps ) do
                   
                        if( m == model ) then allowed = true; end
                   
                    end
                   
                end
               
                if( CfgVars["banprops"] == 1 ) then
               
                    for n, m in pairs( BannedProps ) do
                   
                        if( m == model ) then return false; end
                   
                    end
                   
                end
   
                local cost = CfgVars["foodcost"];
               
                if( ply:CanAfford( cost ) ) then
               
                    ply:AddMoney( -cost );
               
                else
               
                    Notify( ply, 1, 3, "Need " .. cost .. " bucks!" );
                    return false;
               
                end
               
                return true;
           
            end
       
        end
   
    end
 
end
hook.Add( "PlayerSpawnProp", "HM.PlayerSpawnProp", HM.PlayerSpawnProp );
 
function HM.PlayerSpawnedProp( ply, model, ent )
 
    for k, v in pairs( FoodItems ) do
 
        if( string.gsub( v.model, "/", "\\" ) == model ) then
 
            ent:GetTable().FoodItem = 1;
            ent:GetTable().FoodEnergy = v.amount;
            return;
           
        end
   
    end
 
end
hook.Add( "PlayerSpawnedProp", "HM.PlayerSpawnedProp", HM.PlayerSpawnedProp );
 
function HM.KeyPress( ply, code )
 
    if( GetGlobalInt( "hungermod" ) == 0 ) then return; end
 
    if( code ~= IN_USE ) then return; end
   
    local tr = ply:GetEyeTrace();
   
    if( tr.Entity:IsValid() and tr.Entity:GetPos():Distance( ply:GetPos() ) < 90 ) then
   
        if( tr.Entity:GetTable().FoodItem == 1 ) then
       
            ply:SetNWInt( "Energy", math.Clamp( ply:GetNWInt( "Energy" ) + tr.Entity:GetTable().FoodEnergy, 0, 100 ) );
           
            umsg.Start( "AteFoodIcon" ); umsg.End();
           
            tr.Entity:Remove();
       
        else
       
            for k, v in pairs( FoodItems ) do
           
                if( v.model == tr.Entity:GetModel() ) then
               
                    tr.Entity:GetTable().FoodItem = 1;
                    tr.Entity:GetTable().FoodEnergy = v.amount;
                   
                    HM.KeyPress( ply, code );
               
                end
           
            end
       
        end
   
    end
 
end
hook.Add( "KeyPress", "HM.KeyPress", HM.KeyPress );
 
function HM.Think()
 
    if( GetGlobalInt( "hungermod" ) == 0 ) then return; end
    if( CfgVars["hungerspeed"] == 0 ) then return; end
 
    for k, v in pairs( player.GetAll() ) do
   
        if( v:Alive() and CurTime() - v:GetTable().LastHungerUpdate > 1 ) then
            v:HungerUpdate();
        end
   
    end
 
end
hook.Add( "Think", "HM.Think", HM.Think );
 
function HM.PlayerInitialSpawn( ply )
 
    ply:NewHungerData();
 
end
hook.Add( "PlayerInitialSpawn", "HM.PlayerInitialSpawn", HM.PlayerInitialSpawn );
 
for k, v in pairs( player.GetAll() ) do
 
    v:NewHungerData();
 
end
 
HELP_CATEGORY_HUNGERMOD = #HelpCategories + 1;
 
AddHelpCategory( HELP_CATEGORY_HUNGERMOD, "HungerMod - Rick Darkaliono" );
 
AddToggleCommand( "rp_hungermod", "hungermod", true );
AddHelpLabel( -1, HELP_CATEGORY_HUNGERMOD, "rp_hungermod <1 or 0> - Enable/disable hunger mod" );
 
AddToggleCommand( "rp_spawnfood", "foodspawn", false );
AddHelpLabel( -1, HELP_CATEGORY_HUNGERMOD, "rp_spawnfood <1 or 0> - Enable/disable whether players can spawn food props" );
 
AddToggleCommand( "rp_foodspecialcost", "foodpay", false );
AddHelpLabel( -1, HELP_CATEGORY_HUNGERMOD, "rp_foodspecialcost <1 or 0> - Enable/disable whether spawning food props have a special cost" );
 
AddValueCommand( "rp_foodcost", "foodcost", false );
AddHelpLabel( -1, HELP_CATEGORY_HUNGERMOD, "rp_foodcost <Amount> - Set food cost" );
 
AddValueCommand( "rp_hungerspeed", "hungerspeed", false );
AddHelpLabel( -1, HELP_CATEGORY_HUNGERMOD, "rp_hungerspeed <Amount> - Set the rate at which players will become hungry ( 2 is the default )" );
 
AddValueCommand( "rp_starverate", "starverate", false );
AddHelpLabel( -1, HELP_CATEGORY_HUNGERMOD, "rp_starverate <Amount> - How much health that is taken away every second the player is starving  ( 3 is the default )" );
 
 
AddFoodItem( "models/props/cs_italy/bananna.mdl", 6 );
AddFoodItem( "models/propscs_italy/bananna_bunch.mdl", 9 );
AddFoodItem( "models/props_junk/watermelon01.mdl", 9 );
AddFoodItem( "models/props_junk/GlassBottle01a.mdl", 3 );
AddFoodItem( "models/props_junk/PopCan01a.mdl", 2 );
AddFoodItem( "models/props_junk/glassjug01.mdl", 3 );
AddFoodItem( "models/props_junk/garbage_plasticbottle003a.mdl", 3 );
AddFoodItem( "models/props_junk/garbage_milkcarton002a.mdl", 3 );
AddFoodItem( "models/props_junk/garbage_glassbottle001a.mdl", 2 );
AddFoodItem( "models/props_junk/garbage_glassbottle002a.mdl", 2 );
AddFoodItem( "models/props_junk/garbage_glassbottle003a.mdl", 2 ); 
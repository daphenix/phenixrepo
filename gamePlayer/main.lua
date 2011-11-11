--[[
	Casino Client
	
	Author: Keller  aka "Jak the Coder"
]]

declare ("gamePlayer", {})
gamePlayer.version = "0.7"
gamePlayer.config = "gamePlayer"
dofile ("data/data.lua")
dofile ("games/games.lua")
if not messaging then
	dofile ("messaging.lua")
end
dofile ("util.lua")
dofile ("ui/ui.lua")

gamePlayer.arguments = {
}
function gamePlayer.Start (obj, args)
	if args and #args > 0 then
		gamePlayer.data.isDebug = (args [1] == "true")
	end
	if not gamePlayer.data.isActive then
		gamePlayer.ui:CreateLauncherUI ()
	end
end
RegisterUserCommand ("gamePlayer", gamePlayer.Start)
RegisterUserCommand ("games", gamePlayer.Start)
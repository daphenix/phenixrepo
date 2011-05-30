--[[
	Casino Client
	
	Author: Keller  aka "Jak the Coder"
]]

declare ("casinoClient", {})
casinoClient.version = "0.1"
dofile ("data/data.lua")
dofile ("games/games.lua")
dofile ("util.lua")
dofile ("ui/ui.lua")

function casinoClient:OpenLauncher ()
	casinoClient.ui:CreateLauncherUI ()
end

casinoClient.arguments = {
}
function casinoClient.Start (obj, args)
end
RegisterUserCommand ("casinoClient", casinoClient.Start)
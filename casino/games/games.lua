--[[
	Games modules installed
]]

casino.games = {}

-- All games installable
dofile ("games/dummy.lua")
dofile ("games/slots.lua")

casino.games.gamesList = {
	["Dummy"] = casino.games.Dummy,
	["Slots"] = casino.games.Slots
}

function casino.games:Game (gameData)
	local base = {
	}
	function base:Play (req) end
	function base.ProcessRequest (table)
		if table.request then
			base:Play (table.request)
			table.request = nil
		end
	end
	
	return base
end

function casino.games:CreateGame (gameName, playerName)
	local gameData = {
		name = gameName,
		player = playerName,
		request = nil,
		isDone = false
	}
	local game = casino.games.gamesList [gameName] or casino.games.Dummy
	gameData.controller = game (gameData)
	
	return gameData
end

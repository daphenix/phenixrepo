--[[
	Debugging Code
]]

function casino:AddGame (args)
	local gameName = args [2]
	local playerName = args [3]
	casino.data.tables [playerName] = casino.games:CreateGame (gameName, playerName)
end

function casino:RemoveGame (args)
	local playerName = args [2]
	casino.data.tables [playerName] = nil
end
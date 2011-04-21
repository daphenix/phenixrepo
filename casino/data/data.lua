casino.data = {}
dofile ("data/bank.lua")

casino.data.isInitialized = false
casino.data.tablesOpen = false
casino.data.delay = 25
casino.data.chunkSize = 10
casino.data.stepCounter = 0
casino.data.houseThread = nil
casino.data.tables = {}

-- Data Handling
function casino.data:SaveUserSettings ()
end

-- Event Handling and Initialization
casino.data.initialize = {}
function casino.data.initialize:OnEvent (event, id)
	if not casino.data.isInitialized then
		UnregisterEvent (casino.data.initialize, "PLAYER_ENTERED_GAME")
		RegisterEvent (casino.data, "CHAT_MSG_PRIVATE")
		
		casino.data.isInitialized = true
	end
end

-- Lua ReloadInterface ()
casino.data.restart = {}
function casino.data.restart:OnEvent (event, data)
	casino.data.isInitialized = false
	UnregisterEvent (casino.data, "CHAT_MSG_PRIVATE")
	RegisterEvent (casino.data.initialize , "PLAYER_ENTERED_GAME")
end

-- Logout procedure
casino.data.logout = {}
function casino.data.logout:OnEvent (event, id)
	casino.data:SaveUserSettings ()
	casino.data.restart:OnEvent (event, id)
end

-- Main Event Handler
function casino.data:OnEvent (event, data)
	local key, args = string.match (data.msg:lower (), "^!(%w+) (.+)$")
	if key == "casino" and casino.data.tables [data.name] then
		casino.data.tables [data.name].request = args
	else
		-- Check for "play" keyword and add game
		local gameName
		key, gameName = string.match (args, "^(play) (.+)$")
		if key then
			casino.data.tables [data.name] = casino.games:CreateGame (gameName, data.name)
		else
			print ("You must send !casino play <gamename> in order to play")
		end
	end
end
RegisterEvent (casino.data.initialize , "PLAYER_ENTERED_GAME")
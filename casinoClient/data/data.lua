--[[
	Data Elements and Event handling
]]
casinoClient.data = {}
casinoClient.data.id = 314159265359
casinoClient.data.settingsOffset = 102
casinoClient.data.isInitialized = false
casinoClient.data.delay = 25
casinoClient.data.chunkSize = 10
casinoClient.data.stepCounter = 0

-- Data Handling
function casinoClient.data:LoadUserSettings ()
	local charId = casinoClient.data.id + casinoClient.data.settingsOffset
end

function casinoClient.data:SaveUserSettings ()
	local charId = casinoClient.data.id + casinoClient.data.settingsOffset
end

-- Event Handling and Initialization
casinoClient.data.initialize = {}
function casinoClient.data.initialize:OnEvent (event, id)
	if not casinoClient.data.isInitialized then
		UnregisterEvent (casinoClient.data.initialize, "PLAYER_ENTERED_GAME")
		casinoClient.data:LoadUserSettings ()
		
		-- Set up Games
		casinoClient.games:SetupGames ()
		
		-- Event Registration
		RegisterEvent (casinoClient.data.logout, "PLAYER_LOGGED_OUT")
		casinoClient.data.isInitialized = true
	end
end

-- Lua ReloadInterface ()
casinoClient.data.restart = {}
function casinoClient.data.restart:OnEvent (event, data)
	casinoClient.data:SaveUserSettings ()
	casinoClient.data.isInitialized = false
	UnregisterEvent (casinoClient.data.logout, "PLAYER_LOGGED_OUT")
	RegisterEvent (casinoClient.data.initialize , "PLAYER_ENTERED_GAME")
end

-- Logout procedure
casinoClient.data.logout = {}
function casinoClient.data.logout:OnEvent (event, id)
	casinoClient.data:SaveUserSettings ()
	casinoClient.data.restart:OnEvent (event, id)
end

-- Main Event Handler
function casinoClient.data:OnEvent (event, data)
	if event == "CHAT_MSG_PRIVATE" or event == "CHAT_MSG_GROUP" then
	elseif event == "CHAT_MSG_SECTORD" then
	end
end
RegisterEvent (casinoClient.data.initialize , "PLAYER_ENTERED_GAME")
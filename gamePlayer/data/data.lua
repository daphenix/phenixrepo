--[[
	Data Elements and Event handling
]]
gamePlayer.data = {}
gamePlayer.data.id = 314159265359
gamePlayer.data.settingsOffset = 102
gamePlayer.data.isInitialized = false
gamePlayer.data.isActive = false
gamePlayer.data.isDebug = false
gamePlayer.data.delay = 25
gamePlayer.data.chunkSize = 10
gamePlayer.data.stepCounter = 0
gamePlayer.data.casinoName = "PhoenixVoice"
gamePlayer.data.activeGame = nil
gamePlayer.data.gameSoundDir = "plugins/gamePlayer/games/sounds/"
gamePlayer.data.sounds = {}

-- Data Handling
function gamePlayer.data:LoadUserSettings ()
	local charId = gamePlayer.data.id + gamePlayer.data.settingsOffset
	gamePlayer.data.casinoName = gkini.ReadString (gamePlayer.config, "casinoName", "PhoenixVoice")
end

function gamePlayer.data:SaveUserSettings ()
	local charId = gamePlayer.data.id + gamePlayer.data.settingsOffset
	gkini.WriteString (gamePlayer.config, "casinoName", gamePlayer.data.casinoName)
end

-- Event Handling and Initialization
gamePlayer.data.initialize = {}
function gamePlayer.data.initialize:OnEvent (event, id)
	if not gamePlayer.data.isInitialized then
		UnregisterEvent (gamePlayer.data.initialize, "PLAYER_ENTERED_GAME")
		gamePlayer.data:LoadUserSettings ()
		
		-- Set up Games
		gamePlayer.games:SetupGames ()
		gksound.GKLoadSound {soundname = "gamePlayer-ambiance", filename = "plugins/gamePlayer/sounds/bar_ambiance.ogg"}
		gamePlayer.data.sounds ["gamePlayer-ambiance"] = {name="gamePlayer-ambiance", length=35000, file="bar_ambiance.ogg", volume=0.1}
		
		-- Build Bar Button set
		gamePlayer.pda:CreateBarUI (StationChatTab)
		
		-- Event Registration
		RegisterEvent (gamePlayer.data.logout, "PLAYER_LOGGED_OUT")
		gamePlayer.data.isInitialized = true
	end
end

-- Lua ReloadInterface ()
gamePlayer.data.restart = {}
function gamePlayer.data.restart:OnEvent (event, data)
	gamePlayer.data:SaveUserSettings ()
	gamePlayer.data.isInitialized = false
	UnregisterEvent (gamePlayer.data.logout, "PLAYER_LOGGED_OUT")
	RegisterEvent (gamePlayer.data.initialize , "PLAYER_ENTERED_GAME")
end

-- Logout procedure
gamePlayer.data.logout = {}
function gamePlayer.data.logout:OnEvent (event, id)
	gamePlayer.data.restart:OnEvent (event, id)
end

-- Main Event Handler
function gamePlayer.data:OnEvent (event, data)
	if event == "CHAT_MSG_PRIVATE" and data.name == gamePlayer.data.casinoName then
		if gamePlayer.data.activeGame then
			gamePlayer.data.activeGame.ui:ProcessResponse (data.msg)
		end
	end
end
RegisterEvent (gamePlayer.data.initialize , "PLAYER_ENTERED_GAME")
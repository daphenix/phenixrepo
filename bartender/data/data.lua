bartender.data = {}

bartender.data.id = 314159265359
bartender.data.settingsOffset = 102
bartender.data.isInitialized = false
bartender.data.barOpen = false
bartender.data.delay = 25
bartender.data.chunkSize = 10
bartender.data.stepCounter = 0
bartender.data.conversations = {}
bartender.data.users = {}
bartender.data.thread = nil

-- Data Handling
function bartender.data:LoadUserSettings ()
	local charId = bartender.data.id + bartender.data.settingsOffset
end

function bartender.data:SaveUserSettings ()
	local charId = bartender.data.id + bartender.data.settingsOffset
end

function bartender.data:SaveData ()
end

-- Event Handling and Initialization
bartender.data.initialize = {}
function bartender.data.initialize:OnEvent (event, id)
	if not bartender.data.isInitialized then
		UnregisterEvent (bartender.data.initialize, "PLAYER_ENTERED_GAME")
		
		bartender.data:LoadUserSettings ()
		
		-- Event Registration
		RegisterEvent (bartender.data.logout, "PLAYER_LOGGED_OUT")
		bartender.data.isInitialized = true
	end
end

-- Lua ReloadInterface ()
bartender.data.restart = {}
function bartender.data.restart:OnEvent (event, data)
	bartender.data:SaveUserSettings ()
	bartender.data.isInitialized = false
	UnregisterEvent (bartender.data.logout, "PLAYER_LOGGED_OUT")
	RegisterEvent (bartender.data.initialize , "PLAYER_ENTERED_GAME")
end

-- Logout procedure
bartender.data.logout = {}
function bartender.data.logout:OnEvent (event, id)
	bartender.data:SaveUserSettings ()
	bartender.data.restart:OnEvent (event, id)
end

-- Main Event Handler
function bartender.data:OnEvent (event, data)
	if event == "CHAT_MSG_BAR" then
		local key, args = string.match (data.msg:lower (), "^!(%w+)%s*(.*)$")
		local words
		if (key == "bartender" or key == "bt") and args then
			if bartender.data.conversations [data.name] then
				bartender.data.conversations [data.name].request = args
			else
				local parser = bartender.chat:CreateParser (data.name)
				bartender.data.conversations [data.name] = parser
				parser:Start ()
				parser.request = args
			end
		end
	end
end

-- Payoff Event Handler
bartender.data.pay = {}
function bartender.data.pay:OnEvent (event, data)
	if event == "BANK_DEPOSIT" then
		print ("Payment Received")
	end
end

-- Debug Handler
bartender.data.debug = {}
function bartender.data.debug:OnEvent (event, data)
	if event == "CHAT_MSG_GROUP" then
		event = "CHAT_MSG_BAR"
	end
	Timer ():SetTimeout (messaging.chatDelay, function ()
		bartender.data:OnEvent (event, data)
	end)
end
RegisterEvent (bartender.data.initialize , "PLAYER_ENTERED_GAME")

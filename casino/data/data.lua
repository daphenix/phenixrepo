casino.data = {}
dofile ("data/bank.lua")

casino.data.isInitialized = false
casino.data.tablesOpen = false
casino.data.delay = 25
casino.data.chunkSize = 10
casino.data.stepCounter = 0
casino.data.houseThread = nil
casino.data.tables = {}
casino.data.sectorList = {}

-- Data Handling
function casino.data:LoadUserSettings ()
end

function casino.data:SaveUserSettings ()
end

function casino.data:LoadAccountInfo ()
end

function casino.data:SaveAccountInfo ()
end

-- Event Handling and Initialization
casino.data.initialize = {}
function casino.data.initialize:OnEvent (event, id)
	if not casino.data.isInitialized then
		UnregisterEvent (casino.data.initialize, "PLAYER_ENTERED_GAME")
		casino.data:LoadUserSettings ()
		casino.data:LoadAccountInfo ()
		casino.data.isInitialized = true
	end
end

-- Lua ReloadInterface ()
casino.data.restart = {}
function casino.data.restart:OnEvent (event, data)
	casino.data:SaveUserSettings ()
	casino.data:SaveAccountInfo ()
	casino.data.isInitialized = false
	RegisterEvent (casino.data.initialize , "PLAYER_ENTERED_GAME")
end

-- Logout procedure
casino.data.logout = {}
function casino.data.logout:OnEvent (event, id)
	casino.data:SaveUserSettings ()
	casino.data.restart:OnEvent (event, id)
end

-- Main Event Handler
--[[
	From the base state, we have only 6 possible routes
	* Receive money from player -> Create a Trust Account or deposit into an existing one
	* !casino and player has current game running -> Hand over request arguments to game to handle
	* !casino play [game] -> Starts a game of the named type of plays an existing one
	* !casino balance -> Returns the current account balance for the player
	* !casino withdraw -> Allows the player to withdraw an amount upto his account balance
	* !casino close -> Allows the player to competely cashout his account and close it.
									He will receive his balance
]]
function casino.data:OnEvent (event, data)
	if event == "CHAT_MSG_PRIVATE" then
		local key, args = string.match (data.msg:lower (), "^!(%w+)%s*(.*)$")
		local vars
		if key == "casino" and args then
			key, vars = string.match (args, "^(%w+)%s*(%w*)$")
			if key == "balance" and casino.bank.trustAccount [data.name] then
				casino:SendMessage (data.name, string.format ("Current Balance: %d", casino.bank.trustAccount [data.name].balance))
				
			elseif key == "withdraw" then
				if casino.bank.trustAccount [data.name] then
					-- Make a withdrawal from the player's trust account
					casino.bank.trustAccount [data.name]:Withdraw (tonumber (vars))
				else
					casino:SendMessage (data.name, "You do not have an account to withraw!")
				end
				
			elseif key == "close" then
				-- Close out the player's trust account
				casino.bank:CloseAccount (data.name)
				
			elseif casino.data.tables [data.name] then
				-- If an active game is present for the player, set the request
				casino.data.tables [data.name].request = args
				
			elseif key == "play" then
				-- Create a new one
				casino.data.tables [data.name] = casino.games:CreateGame (vars, data.name)

			else
				casino:SendMessage (data.name, "Command not recognized")
			end
		end
	elseif event == "CHAT_MSG_SECTORD_SECTOR" then
		-- this is used for determining if a player is sending money for an account
		-- Form:  <playerName> sent you <amount> credits
		local playerName, amount = string.match (msg, "^(.+) sent you (%d+) credits$")
		if playerName then
			if not casino.bank.trustAccount [playerName] then
				casino.bank:OpenAccount (playerName, tonumber (amount))
				
			else
				casino.bank.trustAccount [playerName]:Deposit (tonumber (amount))
			end
		end
	end
end
RegisterEvent (casino.data.initialize , "PLAYER_ENTERED_GAME")
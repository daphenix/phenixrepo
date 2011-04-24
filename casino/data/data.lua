casino.data = {}
dofile ("data/bank.lua")

casino.data.id = 314159265359
casino.data.settingsOffset = 100
casino.data.isInitialized = false
casino.data.tablesOpen = false
casino.data.delay = 25
casino.data.chunkSize = 10
casino.data.stepCounter = 0
casino.data.backupDelay = 300000
casino.data.chatDelay = 350
casino.data.houseThread = nil
casino.data.numPlayers = 0
casino.data.maxPlayers = 25
casino.data.tables = {}
casino.data.messageQueue = {}
casino.data.waitQueue = {}

-- Data Handling
function casino.data:LoadUserSettings ()
end

function casino.data:SaveUserSettings ()
end

function casino.data:LoadAccountInfo ()
	local charId = casino.data.id + casino.data.settingsOffset
	local temp = unspickle (LoadSystemNotes (charId)) or {}
	local acct, set
	for _, set in pairs (temp) do
		-- Add back in each account and set up properties
		acct = casino.bank:OpenAccount (set.player, set.balance, false)
		acct.creditLine = set.creditLine
		acct.currentBet = set.currentBet
	end
end

function casino.data:SaveAccountInfo ()
	local charId = casino.data.id + casino.data.settingsOffset
	local temp = {}
	local acct
	for _, acct in pairs (casino.bank.trustAccount) do
		table.insert (temp, {
			player = acct.player,
			balance = acct.balance,
			creditLine = acct.creditLine,
			currentBet = acct.currentBet
		})
	end
	SaveSystemNotes (spickle (temp), charId)
end

-- Event Handling and Initialization
casino.data.initialize = {}
function casino.data.initialize:OnEvent (event, id)
	if not casino.data.isInitialized then
		UnregisterEvent (casino.data.initialize, "PLAYER_ENTERED_GAME")
		casino.data:LoadUserSettings ()
		casino.data:LoadAccountInfo ()
		
		-- Event Registration
		RegisterEvent (casino.data.logout, "PLAYER_LOGGED_OUT")
		casino.data.isInitialized = true
	end
end

-- Lua ReloadInterface ()
casino.data.restart = {}
function casino.data.restart:OnEvent (event, data)
	casino.data:SaveUserSettings ()
	casino.data:SaveAccountInfo ()
	casino.data.isInitialized = false
	UnregisterEvent (casino.data.logout, "PLAYER_LOGGED_OUT")
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
	--if event == "CHAT_MSG_GROUP" then
		local key, args = string.match (data.msg:lower (), "^!(%w+)%s*(.*)$")
		local vars
		if key == "casino" and args then
			key, vars = string.match (args, "^(%w+)%s*(%w*)$")
			if key == "help" then
				casino:ChatHelp (data.name)
			
			elseif key == "balance" and casino.bank.trustAccount [data.name] then
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
				if casino.data.numPlayers < casino.data.maxPlayers then
					-- Create a new one
					casino.data.tables [data.name] = casino.games:CreateGame (vars, data.name)
				else
					-- We're full up.
					-- Inform the player he will be placed in a wait queue and his position withn the queue
					local result = false
					local queue = "|" .. table.concat (casino.data.waitQueue, "|") .. "|"
					if not queue:find (data.name) then
						table.insert (casino.data.waitQueue, data.name)
					else
						casino:SendMessage (data.name, "You are already in the wait queue.  Please wait")
					end
				end

			else
				casino:SendMessage (data.name, "Command not recognized")
			end
		end
	elseif event == "CHAT_MSG_SECTORD" then
		-- this is used for determining if a player is sending money for an account
		-- Form:  <playerName> sent you <amount> credits
		local playerName, amount = string.match (data.msg, "^(.+) sent you (%d+) credits$")
		if playerName then
			if not casino.bank.trustAccount [playerName] then
				casino.bank:OpenAccount (playerName, tonumber (amount), true)
				
			else
				casino.bank.trustAccount [playerName]:Deposit (tonumber (amount))
			end
		end
	end
end
RegisterEvent (casino.data.initialize , "PLAYER_ENTERED_GAME")
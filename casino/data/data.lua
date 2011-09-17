casino.data = {}
dofile ("data/bank.lua")

casino.data.id = 314159265359
casino.data.bankOffset = 100
casino.data.settingsOffset = 101
casino.data.isInitialized = false
casino.data.name = "Phoenix Casino"
casino.data.tablesOpen = false
casino.data.delay = 25
casino.data.chunkSize = 10
casino.data.stepCounter = 0
casino.data.backupDelay = 300000
casino.data.refreshDelay = 10000
casino.data.chatDelay = 350
casino.data.adDelay = 600000
casino.data.houseThread = nil
casino.data.simulatorThread = nil
casino.data.numPlayers = 0
casino.data.maxPlayers = 25
casino.data.tables = {}
casino.data.messageQueue = {}
casino.data.waitQueue = {}
casino.data.bannedList = {}
casino.data.useAnnouncements = false
casino.data.announcementType = 1
casino.data.announcementType2 = 1
casino.data.announcementTypeList = {"CHANNEL", "SYSTEM", "SECTOR"}
casino.data.announcementChannel = 100
casino.data.announcementChannel2 = 100
casino.data.announcements = {}
casino.data.contactPlayers = false
casino.data.contactActive = false
casino.data.playerContactList = {}
casino.data.wins = 0
casino.data.losses = 0
casino.data.totalBet = 0
casino.data.totalPaidout = 0
casino.data.volume = 0
casino.data.profitTrigger = 0
casino.data.profitTransferAmount = 0
casino.data.lossTrigger = 0
casino.data.lossTransferAmount = 0

-- Data Handling
function casino.data:LoadUserSettings ()
	local charId = casino.data.id + casino.data.settingsOffset
	local temp = unspickle (LoadSystemNotes (charId)) or {
		maxPlayers = 25,
		banned = {},
		ads = {},
		useAds = "false",
		adType = 1,
		adChannel = 100,
		adType2 = 1,
		adChannel2 = 100,
		contactPlayers = "false",
		players = {},
		adDelay = 600000,
		wins = 0,
		losses = 0,
		totalBet = 0,
		totalPaidout = 0,
		volume = 0,
		profitTrigger = 0,
		profitTransferAmount = 0,
		lossTrigger = 0,
		lossTransferAmount = 0,
		--betTransfer = 0,
		--paidoutTransfer = 0,
		bankAssets = casino.bank:GetTotalAssets (),
		gameData = {}
	}
	casino.data.maxPlayers = temp.maxPlayers or 25
	casino.data.bannedList = temp.banned or {}
	casino.data.useAnnouncements = temp.useAds == "true"
	casino.data.announcementType = temp.adType or 1
	casino.data.announcementChannel = temp.adChannel or 100
	casino.data.announcementType2 = temp.adType2 or 1
	casino.data.announcementChannel2 = temp.adChannel2 or 100
	casino.data.announcements = temp.ads or {}
	casino.data.contactPlayers = temp.contactPlayers == "true"
	casino.data.playerContactList = temp.players or {}
	casino.data.adDelay = temp.adDelay or 600000
	casino.data.wins = temp.wins or 0
	casino.data.losses = temp.losses or 0
	casino.data.totalBet = temp.totalBet or 0
	casino.data.totalPaidout = temp.totalPaidout or 0
	casino.data.volume = temp.volume or 0
	casino.data.profitTrigger = temp.profitTrigger or 0
	casino.data.profitTransferAmount = temp.profitTransferAmount or 0
	casino.data.lossTrigger = temp.lossTrigger or 0
	casino.data.lossTransferAmount = temp.lossTransferAmount or 0
	casino.bank.assets = temp.bankAssets or casino.bank:GetTotalAssets ()
	if casino.bank.assets == 0 then
		casino.bank.assets = casino.bank:GetTotalAssets ()
	end
	casino.games:SetGameData (temp.gameData or {})
end

function casino.data:SaveUserSettings ()
	local charId = casino.data.id + casino.data.settingsOffset
	SaveSystemNotes (spickle ({
		maxPlayers = casino.data.maxPlayers,
		banned = casino.data.bannedList,
		ads = casino.data.announcements,
		useAds = tostring (casino.data.useAnnouncements),
		adType = casino.data.announcementType,
		adChannel = casino.data.announcementChannel,
		adType2 = casino.data.announcementType2,
		adChannel2 = casino.data.announcementChannel2,
		contactPlayers = tostring (casino.data.contactPlayers),
		players = casino.data.playerContactList,
		adDelay = casino.data.adDelay,
		wins = casino.data.wins,
		losses = casino.data.losses,
		totalBet = casino.data.totalBet,
		totalPaidout = casino.data.totalPaidout,
		volume = casino.data.volume,
		profitTrigger = casino.data.profitTrigger,
		profitTransferAmount = casino.data.profitTransferAmount,
		lossTrigger = casino.data.lossTrigger,
		lossTransferAmount = casino.data.lossTransferAmount,
		bankAssets = casino.bank.assets,
		gameData = casino.games:GetGameData ()
	}), charId)
end

function casino.data:LoadAccountInfo ()
	local charId = casino.data.id + casino.data.bankOffset
	local temp = unspickle (LoadSystemNotes (charId)) or {}
	local acct, set
	for _, set in pairs (temp) do
		-- Add back in each account and set up properties
		acct = casino.bank:OpenAccount (set.player, set.balance + set.currentBet, false)
		acct.creditLine = set.creditLine
		acct.currentBet = 0
	end
end

function casino.data:SaveAccountInfo ()
	local charId = casino.data.id + casino.data.bankOffset
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

function casino.data:SaveLog ()
end

-- Event Handling and Initialization
casino.data.initialize = {}
function casino.data.initialize:OnEvent (event, id)
	if not casino.data.isInitialized then
		UnregisterEvent (casino.data.initialize, "PLAYER_ENTERED_GAME")
		
		-- Set up Games
		casino.games:SetupGames ()
		
		-- Load settings and game data
		casino.data:LoadAccountInfo ()
		casino.data:LoadUserSettings ()
		
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

local function SetupGame (playerName, vars)
	casino.data.volume = casino.data.volume + 1
	if casino.data.numPlayers < casino.data.maxPlayers and not casino:IsWaiting (playerName) then
		if casino:IsBanned (playerName) then
			-- Player is banned
			casino:SendMessage (playerName, "You have been banned.  You may not play until you have been unbanned")
		else
			-- Create a new one
			casino.data.tables [playerName] = casino.games:CreateGame (vars, playerName)
		end
	else
		-- We're full up.
		-- Inform the player he will be placed in a wait queue and his position withn the queue
		local result = false
		if not casino:IsWaiting (playerName) then
			table.insert (casino.data.waitQueue, playerName)
		else
			casino:SendMessage (playerName, "You are already in the wait queue.  Please wait")
		end
	end
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
			key, vars = string.match (args, "^(%w+)%s*(.*)$")
			if key == "help" and not casino.data.tables [data.name] then
				casino:ChatHelp (data.name)
			
			elseif key == "balance" then
				if casino.bank.trustAccount [data.name] then
					casino:SendMessage (data.name, string.format ("Current Balance: %d", casino.bank.trustAccount [data.name].balance))
				else
					casino:SendMessage (data.name, "You don't have an account yet!")
				end
				
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
				--[[casino.data.volume = casino.data.volume + 1
				if casino.data.numPlayers < casino.data.maxPlayers and not casino:IsWaiting (data.name) then
					if casino:IsBanned (data.name) then
						-- Player is banned
						casino:SendMessage (data.name, "You have been banned.  You may not play until you have been unbanned")
					else
						-- Create a new one
						casino.data.tables [data.name] = casino.games:CreateGame (vars, data.name)
					end
				else
					-- We're full up.
					-- Inform the player he will be placed in a wait queue and his position withn the queue
					local result = false
					if not casino:IsWaiting (data.name) then
						table.insert (casino.data.waitQueue, data.name)
					else
						casino:SendMessage (data.name, "You are already in the wait queue.  Please wait")
					end
				end]]
				SetupGame (data.name, vars)
				
			elseif key == "front" and vars == "desk" then
				-- Start front desk "game"
				SetupGame (data.name, "front desk")

			else
				casino:SendMessage (data.name, "Command not recognized")
			end
		end
	elseif event == "CHAT_MSG_SECTORD" then
		-- this is used for determining if a player is sending money for an account
		-- Form:  <playerName> sent you <amount> credits
		local playerName, amount = string.match (data.msg, "(.+) sent you (%d+) credits")
		if playerName then
			if not casino.bank.trustAccount [playerName] then
				casino.bank:OpenAccount (playerName, tonumber (amount), true)
			else
				casino.bank.trustAccount [playerName]:Deposit (tonumber (amount))
			end
		end
	end
end

casino.data.com = {}
function casino.data.com:OnEvent (event, data)
	-- Event = PLAYER_ENTERED_SECTOR
	-- Get player, check if already contacted.  If not, send message, else ignore
	-- data is character ID.
	local id = tonumber (data)
	local factionId = GetPlayerFaction (id)
	if not factionId then factionId = 0 end
	if id ~= 0 and id ~= GetCharacterID () and factionId > 0 and factionId < 4 then
		local totalAds = #casino.data.announcements
		local playerName = GetPlayerName (id)
		if totalAds > 0 and not casino.data.playerContactList [playerName] then
			casino.data.playerContactList [playerName] = {contacted = 1}
			casino:SendMessage (playerName, casino.data.announcements [math.random (1, totalAds)])
		end
	end
end

-- Debug Handler
casino.data.debug = {}
function casino.data.debug:OnEvent (event, data)
	if event == "CHAT_MSG_GROUP" then
		event = "CHAT_MSG_PRIVATE"
	end
	Timer ():SetTimeout (casino.data.chatDelay, function ()
		casino.data:OnEvent (event, data)
	end)
end
RegisterEvent (casino.data.initialize , "PLAYER_ENTERED_GAME")
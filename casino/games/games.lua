--[[
	Games modules installed
]]

casino.games = {}
dofile ("games/deck.lua")

-- All games installable
dofile ("games/front_desk.lua")
dofile ("games/slots.lua")

casino.games.gamesList = {}

function casino.games:SetupGames ()
	-- Define list of games available
	local game
	casino.games.gamesList = {}
	for _, game in pairs (casino.games) do
		if type (game) == "table" and game.isPlayable then
			table.insert (casino.games.gamesList, game.name)
		end
	end
end

function casino.games:BaseController (game)
	local base = {
		-- Set this to true when all preconditions for play have been satisfied
		canPlay = false,
		
		-- Change this statement to what will be returned to the user when starting up
		startup = "You are now playing " .. game.name
	}
	
	--[[*************************************************
	
		Override these 3 functions for each game if desired
	]]
	
	-- How to play this game
	function base:Help (req) end
	
	-- Used for any additional processing that is needed but not in default key set
	-- e.g. raise or see in Poker
	function base:ParseKey (key, args) end
	
	-- Primary Play function
	function base:Play (req) end
	
	-- Clean up game and resources before shutting down
	function base:Close () end
	
	--[[
	
		End Override Section
		
	*****************************************************]]

	function base:SendMessage (msg)
		table.insert (casino.data.messageQueue, casino:Message (game.player, msg))
	end
	
	function base:Win (amt)
		base:SendMessage (string.format ("You Win %dc!", (game.acct.currentBet + amt)))
		game.acct:Deposit (game.acct.currentBet + amt)
		casino.data.wins = casino.data.wins + 1
		casino.data.totalPaidout = casino.data.totalPaidout + game.acct.currentBet + amt
		game.acct.currentBet = 0
	end
	
	function base:Lose ()
		base:SendMessage ("You Lose.  Better Luck Next Time")
		game.acct.currentBet = 0
		casino.data.losses = casino.data.losses + 1
	end
	
	function base:ProcessRequest (req)
		if req then
			local key, args = string.match (req:lower (), "^(%w+)%s*(.*)$")
			casino:Yield ()
			if not game.acct then
				base:SendMessage ("You must visit the casino sector and set up an account to be able to play.  Just /givemoney to the casino to set up an account.  Quitting game")
				game.isDone = true
				
			elseif key == "help" then
				base:Help ()
				
			elseif key == "quit" or key == "leave" then
				-- Return any current bet back to the player's bank account
				game.acct.balance = game.acct.balance + game.acct.currentBet
				game.isDone = true
				
			elseif key ~= "play" then
				base:ParseKey (key, args)
				
			elseif key == "bet" and not base.canPlay then
				base.canPlay = game.acct:MakeBet (tonumber (args), true)
				
			elseif key == "play" then
				if base.canPlay then
					base:Play (args)
				else
					base:SendMessage ("You must bet before you can play")
				end
			end
		end
	end
	
	return base
end

function casino.games:CreateGame (gameName, playerName)
	if gameName:len () > 0 then
		casino:Log ("Attempting to create game " .. tostring (gameName) .. " for player " .. playerName)
		local game = {
			name = gameName,
			player = playerName,
			acct = casino.bank.trustAccount [playerName],
			startdate = os.date (),
			isDone = false,
			request = nil
		}
		local controller = casino.games [gameName:lower ()] or casino.games.frontdesk
		game.name = controller.name
		game.controller = controller.GetController (game)
		
		-- Send Response to player
		game.controller:SendMessage (game.controller.startup)
		casino.data.numPlayers = casino.data.numPlayers + 1
		
		return game
	else
		casino:ChatHelp (playerName)
	end
end

function casino.games.CreateDefaultConfigUI (game)
	local saveButton = iup.stationbutton {title="Save", font=casino.ui.font}
	local cancelButton = iup.stationbutton {title="Cancel", font=casino.ui.font}
	
	local pda = iup.vbox {
		iup.label {title = game.name .. " v" .. game.version, font=casino.ui.font},
		iup.fill {size = 15},
		iup.hbox {
			iup.label {title = "Nothing to Configure", font=casino.ui.font},
			iup.fill {};
			expand = "YES"
		},
		iup.fill {size = 5},
		iup.fill {},
		iup.hbox {
			iup.fill {},
			saveButton,
			cancelButton; };
	}
	
	function pda:DoSave ()
	end
	
	function pda:DoCancel ()
	end
	
	function pda:GetSaveButton ()
		return saveButton
	end
	
	function pda:GetCancelButton ()
		return cancelButton
	end
	
	return pda
end

function casino.games:CreateConfigUI (game)
	local gui = game.CreateConfigUI or casino.games.CreateDefaultConfigUI
	local content = gui (game)
	
	local frame = iup.dialog {
		iup.pdarootframe {
			content;
		},
	    font = casino.ui.font,
		border = 'YES',
		topmost = 'YES',
		resize = 'YES',
		maxbox = 'NO',
		minbox = 'NO',
		modal = 'NO',
		fullscreen = 'NO',
		expand = 'YES',
		active = 'NO',
		menubox = 'NO',
		bgcolor = casino.ui.bgcolor,
		defaultesc = content:GetCancelButton ()
	}
	
	content:GetSaveButton ().action = function ()
		content:DoSave ()
		HideDialog (frame)
		frame.active = "YES"
	end
	
	content:GetCancelButton ().action = function ()
		content:DoCancel ()
		HideDialog (frame)
		frame.active = "NO"
	end
	
	ShowDialog (frame, iup.CENTER, iup.CENTER)
	frame.active = "YES"
end

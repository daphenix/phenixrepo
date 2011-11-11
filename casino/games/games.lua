--[[
	Games modules installed
]]

casino.games = {}
dofile ("games/deck.lua")

-- All games installable
dofile ("games/front_desk.lua")
dofile ("games/slots.lua")
dofile ("games/blackjack.lua")

casino.games.gamesList = {}
local availableGames = {}

function casino.games:SetupGames ()
	-- Define list of games available
	local game
	casino.games.gamesList = {}
	for _, game in pairs (casino.games) do
		if type (game) == "table" and game.isPlayable then
			table.insert (casino.games.gamesList, game.name)
			availableGames [game.name:lower ()] = game
		end
	end
end

function casino.games:GetGameData ()
	local game, name, data
	local saveData = {}
	for name, game in pairs (availableGames) do
		data = nil
		if game.GetGameData then
			data = game:GetGameData ()
		end
		if data then
			saveData [name] = data
		end
	end
	
	return saveData
end

function casino.games:SetGameData (gameData)
	local name, game, data
	for name, data in pairs (gameData) do
		game = availableGames [name]
		if game and game.SetGameData then game:SetGameData (data) end
	end
end

function casino.games:BaseController (game, config, simulator)
	local base = {
		-- Set this to true when all preconditions for play have been satisfied
		canPlay = false,
		
		-- Change this statement to what will be returned to the user when starting up
		startup = "You are now playing " .. game.name,
		
		-- This carries the state for whether the given instance of the game is a simulation or not
		simulator = simulator
	}
	
	--[[*************************************************
	
		Override these 3 functions for each game if desired
	]]
	
	-- How to play this game
	function base:Help (req) end
	
	-- Override this function to approve of a bet
	function base:IsValidBet (amt)
		if amt == 0 then
			return false, "You must bet something to play!"
			
		elseif game.acct.balance < amt then
			return false, "You cannot bet more money than you have!"
			
		else
			return true
		end
	end
	
	-- Override this function for special functionality in betting
	function base:Bet (amt)
		local isBet, msg = base:IsValidBet (amt)
		if isBet then
			base.canPlay = game.acct:MakeBet (amt, true)
		elseif not simulator then
			base:SendMessage (msg)
		end
	end
	
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

	function base:SendMessage (msg, playerName)
		if not simulator then
			local name = playerName or game.player
			casino.messaging:Send (name, msg)
		end
	end
	
	function base:Win (amt, msg)
		if not simulator then
			msg = msg or string.format ("You Win %dc!", (game.acct.currentBet + amt))
			base:SendMessage (msg)
			game.acct:Deposit (game.acct.currentBet + amt)
			casino.data.wins = casino.data.wins + 1
			casino.data.totalPaidout = casino.data.totalPaidout + game.acct.currentBet + amt
			game.acct.currentBet = 0
		else
			simulator:Win (game.acct.currentBet + amt)
		end
	end
	
	function base:Lose (msg)
		if not simulator then
			msg = msg or "You Lose.  Better Luck Next Time"
			base:SendMessage (msg)
			game.acct.currentBet = 0
			casino.data.losses = casino.data.losses + 1
		else
			simulator:Lose ()
		end
	end
	
	function base:Tie (msg)
		if not simulator then
			msg = msg or "You Tied"
			base:SendMessage (msg)
			casino.data.totalBet = casino.data.totalBet - game.acct.currentBet
			game.acct:Deposit (game.acct.currentBet)
			game.acct.currentBet = 0
		else
			simulator:Tie ()
		end
	end
	
	function base:ProcessRequest (req)
		if req then
			local key, args = string.match (req:lower (), "^(%w+)%s*(.*)$")
			casino:Yield ()
			if not game.acct then
				base:SendMessage ("You must visit the casino sector and set up an account to be able to play.  Just /givemoney to the casino to set up an account.  Quitting game")
				game.isDone = true
				
			elseif key == "help" then
				base:SendMessage ("help: Print this list")
				base:SendMessage ("balance: Get your current bank balance")
				base:SendMessage ("withdraw <amount>: Withdraw funds from your bank account (must be in the base sector)")
				base:SendMessage ("close: Close out your bank account and receive all remaining funds (must be in the casino sector)")
				base:Help ()
				
			elseif key == "quit" or key == "leave" then
				-- Clear any current bet
				-- This prevents a player from cheating the bank so he doesn't lose money'
				game.acct.currentBet = 0
				game.isDone = true
				
			elseif key == "bet" and not base.canPlay then
				local amt = tonumber (args) or 0
				if amt > 0 then
					base:Bet (tonumber (args))
				elseif not simulator then
					base:SendMessage ("You must make a bet in order to play")
				end
				
			elseif key ~= "play" then
				base:ParseKey (key, args)
				if simulator then simulator:ParseKey (key, args) end
				
			elseif key == "play" then
				if base.canPlay then
					base:Play (args)
					if simulator then simulator:Play (args) end
				else
					base:SendMessage ("You must bet before you can play")
				end
			end
		end
	end
	
	-- Copy any properties from config to base
	if config then
		local prop, value
		for prop, value in pairs (config) do
			base [prop] = value
		end
	end
	
	return base
end

function casino.games:CreateGame (gameName, playerName, config, simulator)
	if gameName:len () > 0 then
		casino:Log ("Attempting to create game " .. tostring (gameName) .. " for player " .. playerName)
		local game
		if not simulator then
				game = {
				name = gameName,
				player = playerName,
				acct = casino.bank.trustAccount [playerName],
				startdate = os.date (),
				isDone = false,
				request = nil
			}
		else
			game = {
				name = gameName,
				player = playerName,
				acct = simulator.acct,
				request = nil
			}
		end
		local controller = availableGames [gameName:lower ()] or casino.games.frontdesk
		game.name = controller.name
		game.controller = controller.GetController (game, config, simulator)
		
		-- Send Response to player
		if not simulator then
			game.controller:SendMessage (game.controller.startup)
			casino.data.numPlayers = casino.data.numPlayers + 1
		end
		
		return game
	else
		casino:ChatHelp (playerName)
	end
end

function casino.games:CreateSimulator (simulatorName, bankAmt, config)
	local simulator = {
		totalWins = 0,
		totalLosses = 0,
		totalBet = 0,
		totalPaidout = 0
	}
	simulator.acct = casino.bank:CreateSimulationAccount (simulatorName, bankAmt, simulator)
	simulator.Win = function (o, amt)
		simulator.totalWins = simulator.totalWins + 1
		simulator.totalPaidout = simulator.totalPaidout + amt
		simulator.acct.currentBet = 0
	end
	simulator.Lose = function ()
		simulator.totalLosses = simulator.totalLosses + 1
	end
	simulator.Tie = function () end
	simulator.Play = function (o, args) end
	simulator.ParseKey = function (o, key, args) end
	simulator.Reset = function ()
		simulator.totalWins = 0
		simulator.totalLosses = 0
		simulator.totalBet = 0
		simulator.totalPaidout = 0
	end
	
	if config then
		local	prop, value
		for prop, value in pairs (config) do
			simulator [prop] = value
		end
	end
	
	return simulator
end

function casino.games:CreateDefaultConfigUI (game)
	local ui = iup.vbox {
		iup.label {title = game.name .. " v" .. game.version, font=casino.ui.font},
		iup.fill {size = 15},
		iup.hbox {
			iup.label {title = "Nothing to Configure", font=casino.ui.font},
			iup.fill {};
			expand = "YES"
		},
		iup.fill {size = 5};
	}
	
	function ui:DoSave ()
	end
	
	function ui:DoCancel ()
	end
	
	return ui
end

function casino.games:CreateConfigUI (game)
	local saveButton = iup.stationbutton {title="Save", font=casino.ui.font}
	local cancelButton = iup.stationbutton {title="Cancel", font=casino.ui.font}
	local simulateButton = iup.stationbutton {title="Run Simulation", font=casino.ui.font}
	local gui = game.CreateConfigUI or casino.games.CreateDefaultConfigUI
	local content = gui (game, simulateButton)
	
	local frame = iup.dialog {
		iup.pdarootframe {
			iup.vbox {
				iup.label {title = game.name .. " v" .. game.version, font=casino.ui.font},
				iup.fill {size = 15},
				content,
				iup.fill {},
				iup.hbox {
					iup.fill {},
					saveButton,
					cancelButton; };
			}
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
		defaultesc = cancelButton
	}
	
	function simulateButton.action ()
		casino:Print ("Running Simulation")
		simulateButton.active = "NO"
		casino.data.simulatorThread = coroutine.create (function ()
			content:DoSimulation ()
			simulateButton.active = "YES"
		end)
		if not casino.data.tablesOpen then
			casino:RunThreads ()
		end
	end
	
	function saveButton.action ()
		content:DoSave ()
		HideDialog (frame)
		frame.active = "YES"
	end
	
	function cancelButton.action ()
		content:DoCancel ()
		HideDialog (frame)
		frame.active = "NO"
	end
	
	ShowDialog (frame, iup.CENTER, iup.CENTER)
	frame.active = "YES"
end

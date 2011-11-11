--[[
	New Game Template
	
	Use this template to create additional games
]]
casino.games.poker = {}
casino.games.poker.version = "0.1"
casino.games.poker.name = "Poker"
casino.games.poker.isPlayable = true

-- Define game controller.  Any defined functions which are not used may be removed
-- e.g. Close is defined in the generic game controller, it may be removed if not needed

function casino.games.poker.GetController (game, config, simulator)
	local poker = casino.games:BaseController  (game, config, simulator)
	
	poker.startup = "Welcome to My Game!  Remember, I'm watching, so don't cheat.  Have fun!"
	poker.canPlay = true 			-- No bets allowed.  Use ante command to start
	local startedPlay = false
	local isHost = false
	local isClient = false
	local betPool = 0
	local players = {}
	
	local function AddPlayer (name)
		players [name] = {
			hand = {},
			currentBet = 0
		}
	end
	
	-- Use this function to send basic help about the game interface back to the user
	function poker:Help ()
		poker:SendMessage ("Just send !casino play to play")
	end
	
	-- Used for processing any commands outside the basic command set (i.e. bet, play, and quit/leave)
	-- May set state variables for use by play
	function poker:ParseKey (key, args)
		if not startedPlay then
			if key == "join" then
				isClient = true
			elseif key == "host" then
				isHost = true
			end
		elseif key == "ante" then
		elseif key == "drop" or key == "discard" then
		elseif key == "raise" then
		elseif key == "see" then
		elseif key == "show" then
		elseif key == "fold" then
		end
	end
	
	-- This is the basic game function
	-- Runs the game for the player and changes any state variables being used by the game
	function poker:Play (req)
		-- Deal cards to all the players
	end
	
	-- Used to clean up any resources used by the game before being removed by the casino server
	function poker:Close ()
	end
	
	return poker
end

-- Use this functino to build a GUI to admin the game
function casino.games.poker.CreateConfigUI (game, simulateButton)
	
	-- Set up the UI content for the config screen.  All controls except the simulate button are already
	-- injected by the basic screen
	local ui = iup.vbox {
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
	
	-- Use this function to build a simulation to run in order to test game settings
	function ui:DoSimulation ()
		-- Set up test
		local simulator = casino.games:CreateSimulator ("test", 0, {
			-- put any game specific properties in here
		})
		-- Build any additional functions onto the resulting simulator object
		-- Use the config object to set custom configurations in your game
		local config = {}
		local simulation = casino.games:CreateGame ("poker", "test", config, simulator)
		
		-- Run your test by calling the various functions on the simulator as you would in a real game
		-- e.g. simulation.controller.ProcessRequest ("bet 3")
		-- or simulations.controller.ProcessRequest ("play")
		--
		-- Create a message result from the simulations and output to an information dialog
		-- e.g. local msg = "Just a Result"
		-- casino.ui:CreateInfoUI ("My Test", msg)
	end
	
	function ui:DoSave ()
	end
	
	function ui:DoCancel ()
	end
	
	return ui
end

-- If exists, returns any game data to be saved in the plugin configuration
function casino.games.poker:GetGameData ()
end

function casino.games.poker:SetGameData (data)
end
--[[
	Blackjack - Single person version
]]
casino.games.blackjack = {}
casino.games.blackjack.version = "0.1"
casino.games.blackjack.name = "Blackjack"
--casino.games.blackjack.isPlayable = true

-- Main Game Controller
function casino.games.blackjack.GetController (game, config, simulator)
	local blackjack = casino.games:BaseController  (game, config, simulator)
	blackjack.canPlay = false
	
	local deck = casino.games:CreateDeck ()
	local player = {}
	local playerTotal = 0
	local dealer = {}
	local dealerTotal = 0
	
	-- Determine the total value of the passed hand
	local function Value (hand)
		local total = 0
		local card
		for _, card in ipairs (hand) do
			if card.value < 11 then
				-- Handle normal card
				total = total + card.value
			elseif card.value > 10 then
				-- Handle face card
				total = total + 10
			end
			
			-- Ace is special case
			if card.value == 1 and total < 12 then
				total = total + 10
			end
		end
		
		return total
	end
	
	local function GetPlayerString (hand)
	end
	
	local function GetDealerString (hand)
	end
	
	-- Use this function to send basic help about the game interface back to the user
	function blackjack:Help ()
		blackjack:SendMessage ("Just send !casino play to play")
	end
	
	-- Used for processing any commands outside the basic command set (i.e. bet, play, quit)
	-- May set state variables for use by play
	function blackjack:ParseKey (key, args)
		if key == "hit" then
		elseif key == "stay" then
		end
	end
	
	-- Play starts a sequence of card deals, requires hit or stay to continue
	function blackjack:Play (req)
		-- Deal Initial 2 cards to player and dealer
		table.insert (player, deck:Draw ())
		table.insert (player, deck:Draw ())
		
		table.insert (dealer, deck:Draw ())
		table.insert (dealer, deck:Draw ())
		
		blackjack:SendMessage (string.format (""))
	end
	
	return blackjack
end

-- Configuration Screen
function casino.games.blackjack.CreateConfigUI (game)
	local saveButton = iup.stationbutton {title="Save", font=casino.ui.font}
	local cancelButton = iup.stationbutton {title="Cancel", font=casino.ui.font}
	
	local pda = iup.vbox {
		iup.label {title = game.name .. " v" .. game.version, font=casino.ui.font},
		iup.fill {size = 15},
		iup.hbox {
			iup.label {title = "Blackjack", font=casino.ui.font},
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
		local simulation = casino.games:CreateGame ("mygame", "test", config, simulator)
		
		-- Run your test by calling the various functions on the simulator as you would in a real game
		-- e.g. simulation.controller.ProcessRequest ("bet 3")
		-- or simulations.controller.ProcessRequest ("play")
		--
		-- Create a message result from the simulations and output to an information dialog
		-- e.g. local msg = "Just a Result"
		-- casino.ui:CreateInfoUI ("My Test", msg)
	end
	
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
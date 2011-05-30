--[[
	Blackjack - Single person version
]]
casino.games.blackjack = {}
casino.games.blackjack.version = "0.1"
casino.games.blackjack.name = "Blackjack"
casino.games.blackjack.isPlayable = true

-- Main Game Controller
function casino.games.blackjack.GetController (game)
	local blackjack = casino.games:BaseController  (game)
	blackjack.canPlay = false
	
	local deck = casino.games:CreateDeck ()
	local player = {}
	local playerTotal = 0
	local dealer = {}
	local dealerTotal = 0
	
	-- Determine the total value of the passed hand
	local function Value (hand)
		local total = {0, 0}
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
	
	-- Use this function to send basic help about the game interface back to the user
	function blackjack:Help ()
		blackjack:SendMessage ("Just send !casino play to play")
	end
	
	-- Used for processing any commands outside the basic command set (i.e. bet, play, quit)
	-- May set state variables for use by play
	function blackjack:ParseKey (key, args)
	end
	
	-- Play starts a sequence of card deals, requires hit or stay to continue
	function blackjack:Play (req)
		-- Deal Initial 2 cards to player and dealer
		table.insert (player, deck:Draw ())
		table.insert (player, deck:Draw ())
		
		table.insert (dealer, deck:Draw ())
		table.insert (dealer, deck:Draw ())
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
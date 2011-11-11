--[[
	Blackjack - Single person version
]]
casino.games.blackjack = {}
casino.games.blackjack.version = "0.5.1"
casino.games.blackjack.name = "Blackjack"
casino.games.blackjack.isPlayable = true

-- Probabilities for a difference of 1 or 17
-- This matrix is for a simulated player
local checkDraw = {
	drawCard = {
		[12] = 69,
		[13] = 62,
		[14] = 54,
		[15] = 46,
		[16] = 38
	}
}

-- Main Game Controller
function casino.games.blackjack.GetController (game, config, simulator)
	local blackjack = casino.games:BaseController  (game, config, simulator)
	blackjack.startup = "Welcome to Blackjack!  This is a 1000c minimum table with a maximum of 100,000c."
	blackjack.canPlay = false
	
	local deck = casino.games:CreateCardDeck (true)
	local player = {}
	local playerTotal = 0
	local dealer = {}
	local dealerTotal = 0
	local startedPlay = false
	
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
	
	local function CheckWin (playerHand, dealerHand)
		local pValue = Value (playerHand)
		if pValue <= 21 and pValue > Value (dealerHand) then return true
		else return false
		end
	end
	
	local function CheckPush (playerHand, dealerHand)
		if Value (playerHand) == Value (dealerHand) then return true
		else return false
		end
	end
	
	local function CheckBlackjack (hand)
		if Value (hand) == 21 then return true
		else return false
		end
	end
	
	local function DealerPlay ()
		while Value (dealer) < 17 and Value (dealer) < Value (player) do
			table.insert (dealer, deck:Draw ())
		end
	end
	
	local function EndHand ()
		blackjack.canPlay = false
		startedPlay  = false
	end
	
	local function Win ()
		blackjack:Win (game.acct.currentBet)
		EndHand ()
	end
	
	local function WinInitial ()
		blackjack:Win (1.5 * game.acct.currentBet)
		EndHand ()
	end
	
	local function Lose ()
		blackjack:Lose ()
		EndHand ()
	end
	
	local function Push ()
		blackjack:Tie ("Dealer Pushes")
		EndHand ()
	end
	
	-- Override this function to approve of a bet
	function blackjack:IsValidBet (amt)
		if amt == 0 then
			return false, "You must bet something to play!"
			
		elseif game.acct.balance < amt then
			return false, "You cannot bet more money than you have!"
			
		elseif amt < 1000 then
			return false, "This table requires a minimum bet of 1000c"
			
		elseif amt > 100000 then
			return false, "The bet limit at this table is 100,000c"
			
		else
			return true, ""
		end
	end
	
	-- Use this function to send basic help about the game interface back to the user
	function blackjack:Help ()
		blackjack:SendMessage ("Recognized Commands:")
		blackjack:SendMessage ("Set your Bet: !casino bet <num>")
		blackjack:SendMessage ("Start Play: !casino play")
		blackjack:SendMessage ("Show Hand: !casino show")
		blackjack:SendMessage ("Get another card: !casino hit")
		blackjack:SendMessage ("Stand on current hand: !casino stand or !casino stay")
		blackjack:SendMessage ("Leave Table: !casino quit")
	end
	
	-- Used for processing any commands outside the basic command set (i.e. bet, play, quit)
	-- May set state variables for use by play
	function blackjack:ParseKey (key, args)
		if startedPlay then
			if key == "hit" then
				table.insert (player, deck:Draw ())
				blackjack:SendMessage (string.format ("Dealer Hand: %s", deck:ShowHand (dealer, 1)))
				blackjack:SendMessage (string.format ("Player Hand: %s = %d", deck:ShowHand (player), Value (player)))
				
				-- Check if player hits 21
				if CheckBlackjack (player) then
					Win ()
				elseif Value (player) > 21 then
					Lose ()
				end
				
			elseif key == "stand" or key == "stay" then
				DealerPlay ()
				blackjack:SendMessage (string.format ("Dealer Hand: %s = %d", deck:ShowHand (dealer), Value (dealer)))
				blackjack:SendMessage (string.format ("Player Hand: %s = %d", deck:ShowHand (player), Value (player)))
				
				-- Check for blackjack win
				local pValue = Value (player)
				local dValue = Value (dealer)
				if dValue > 21 or dValue < pValue then
					Win ()
				elseif dValue <= 21 and dValue > pValue then
					Lose ()
				else
					Push ()
				end
			elseif key == "show" then
				blackjack:SendMessage (string.format ("Dealer Hand: %s", deck:ShowHand (dealer, 1)))
				blackjack:SendMessage (string.format ("Player Hand: %s = %d", deck:ShowHand (player), Value (player)))
			end
		end
	end
	
	-- Play starts a sequence of card deals, requires hit or stay to continue
	function blackjack:Play (req)
		if not startedPlay then
			-- Deal Initial 2 cards to player and dealer
			startedPlay = true
			player = {}
			table.insert (player, deck:Draw ())
			table.insert (player, deck:Draw ())
			
			dealer = {}
			table.insert (dealer, deck:Draw ())
			table.insert (dealer, deck:Draw ())
			
			-- Need to check for blackjack win
			if CheckBlackjack (player) and CheckBlackjack (dealer) then
				blackjack:SendMessage (string.format ("Dealer Hand: %s = %d", deck:ShowHand (dealer), Value (dealer)))
				blackjack:SendMessage (string.format ("Player Hand: %s = %d", deck:ShowHand (player), Value (player)))
				Push ()
			elseif CheckBlackjack (player) then
				blackjack:SendMessage (string.format ("Dealer Hand: %s", deck:ShowHand (dealer, 1)))
				blackjack:SendMessage (string.format ("Player Hand: %s = %d", deck:ShowHand (player), Value (player)))
				WinInitial ()
			elseif CheckBlackjack (dealer) then
				blackjack:SendMessage (string.format ("Dealer Hand: %s = %d", deck:ShowHand (dealer), Value (dealer)))
				blackjack:SendMessage (string.format ("Player Hand: %s = %d", deck:ShowHand (player), Value (player)))
				Lose ()
			else
				blackjack:SendMessage (string.format ("Dealer Hand: %s", deck:ShowHand (dealer, 1)))
				blackjack:SendMessage (string.format ("Player Hand: %s = %d", deck:ShowHand (player), Value (player)))
			end
		end
	end
	
	return blackjack
end

-- Configuration Screen
function casino.games.blackjack.CreateConfigUI (game, simulateButton)
	
	local ui = iup.vbox {
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
	
	function ui:DoSimulation ()
	end
	
	function ui:DoSave ()
	end
	
	function ui:DoCancel ()
	end
	
	return ui
end
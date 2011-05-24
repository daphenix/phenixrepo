--[[
	Slots Game
]]
casino.games.slots = {}
casino.games.slots.version = "0.7"
casino.games.slots.name = "Slots"
casino.games.slots.isPlayable = true

-- Game Data
casino.games.slots.slotBet = 5
casino.games.slots.payout2OfAKind = 15
casino.games.slots.payout3OfAKind =95
casino.games.slots.cylinders = {
	{
		assigned = {7, 7, 13, 7, 7, 6, 7, 6, 7, 13, 6, 7, 7}, -- Ca, Ap
		symbols = {"Aq", "Si", "Ca", "Fe", "Va", "Is", "Xi", "La", "Py", "Ap", "De", "Pe", "He"}
	},
	{
		assigned = {7, 7, 6, 7, 6, 13, 7, 6, 7, 13, 7, 7, 7}, -- Aq, Pe
		symbols = {"La", "Py", "Va", "Is", "Xi", "Aq", "Si", "Ca", "Fe", "Pe", "He", "Ap", "De"}
	},
	{
		assigned = {7, 6, 7, 6, 13, 7, 7, 13, 7, 6, 7, 7, 7}, -- Fe, Xi
		symbols = {"Si", "Py", "Ap", "Ca", "Fe", "Va", "Aq", "Xi", "La", "Pe", "He", "Is", "De"}
	}
}

-- Main Game Controller
function casino.games.slots.GetController (game)
	local slots = casino.games:BaseController  (game)
	slots.canPlay = true
	
	-- Game Data
	-- Set up payout data as bet + payout.  So if the automatic bet is 5c and you want a payout of 20c, the payout setting should be 15
	math.random (1, 100)
	local cylinders = {{}, {}, {}}
	
	function slots:Buildcylinders (source, stats)
		local j, k
		stats.assumed = {}
		stats.symbols = source.symbols
		for k=1, #source.symbols do
			stats.assumed [k] = 0
			for j=1, k-1 do
				stats.assumed [k] = stats.assumed [k] + source.assigned [j]
			end
		end
	end
	slots:Buildcylinders (casino.games.slots.cylinders [1], cylinders [1])
	slots:Buildcylinders (casino.games.slots.cylinders [2], cylinders [2])
	slots:Buildcylinders (casino.games.slots.cylinders [3], cylinders [3])
	slots.startup = string.format ("Welcome to Slots!  The price for play is %dc which is automatically deducted from your account.  Have fun!", casino.games.slots.slotBet)
	
	function slots:GetSlotSymbol (stats)
		local index = math.random (1, 100)
		local token = 0
		local j
		for j=1, #stats.symbols do
			if index > stats.assumed [j] then
				token = token + 1
			end
		end
	
		return stats.symbols [token]
	end
	
	function slots:CheckTwoOfAKind (roll)
		local a, b, c = string.match (roll, "|(%w+)|(%w+)|(%w+)|")
		return (a == b or a == c or b == c)
	end
	
	function slots:CheckThreeOfAKind (roll)
		local a, b, c = string.match (roll, "|(%w+)|(%w+)|(%w+)|")
		return (a == b and a == c)
	end
	
	function slots:Help (req)
		slots:SendMessage (string.format ("Just send !casino play to play.  Your bet of %dc is automatically deducted from your account", casino.games.slots.slotBet))
	end
	
	function slots:Play (req)
		slots:SendMessage ("Spin! Spin! Spin!")
		game.acct:MakeBet (casino.games.slots.slotBet, false)
		local result = "|"
		
		-- Cylinder 1
		result = result .. tostring (slots:GetSlotSymbol (cylinders [1])) .. "|"
		
		-- Cylinder 2
		result = result .. tostring (slots:GetSlotSymbol (cylinders [2])) .. "|"
		
		-- Cylinder 3
		result = result .. tostring (slots:GetSlotSymbol (cylinders [3])) .. "|"
		
		-- Check Result
		slots:SendMessage (string.format ("Result: %s", result))
		if slots:CheckThreeOfAKind (result) then
			slots:Win (casino.games.slots.payout3OfAKind)
		elseif slots:CheckTwoOfAKind (result) then
			slots:Win (casino.games.slots.payout2OfAKind)
		else
			slots:Lose ()
		end
	end
	
	return slots
end

function casino.games.slots.CreateConfigUI (game)
	local saveButton = iup.stationbutton {title="Save", font=casino.ui.font}
	local cancelButton = iup.stationbutton {title="Cancel", font=casino.ui.font}
	
	local pda = iup.vbox {
		iup.label {title = game.name .. " v" .. game.version, font=casino.ui.font},
		iup.fill {size = 15},
		iup.hbox {
			iup.label {title = "Let's adjust some probabilities'", font=casino.ui.font},
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

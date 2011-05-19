--[[
	Slots Game
]]
casino.games.slots = {}
casino.games.slots.version = "0.7"

function casino.games.slots.GetController (game)
	local slots = casino.games:BaseController  (game)
	slots.canPlay = true
	
	-- Game Data
	-- Set up payout data as bet + payout.  So if the automatic bet is 5c and you want a payout of 25c, the payout setting should be 20
	math.random (1, 100)
	local slotBet = 5
	local payout2OfAKind = 15
	local payout3OfAKind =95
	local cylinders = {
		{
			assigned = {7, 7, 13, 7, 7, 6, 7, 6, 7, 13, 6, 7, 7}, -- Ca, Ap
			assumed = {},
			symbols = {"Aq", "Si", "Ca", "Fe", "Va", "Is", "Xi", "La", "Py", "Ap", "De", "Pe", "He"}
		},
		{
			assigned = {7, 7, 6, 7, 6, 13, 7, 6, 7, 13, 7, 7, 7}, -- Aq, Pe
			assumed = {},
			symbols = {"La", "Py", "Va", "Is", "Xi", "Aq", "Si", "Ca", "Fe", "Pe", "He", "Ap", "De"}
		},
		{
			assigned = {7, 6, 7, 6, 13, 7, 7, 13, 7, 6, 7, 7, 7}, -- Fe, Xi
			assumed = {},
			symbols = {"Si", "Py", "Ap", "Ca", "Fe", "Va", "Aq", "Xi", "La", "Pe", "He", "Is", "De"}
		}
	}
	
	function slots:Buildcylinders (stats)
		local j, k
		for k=1, #stats.symbols do
			stats.assumed [k] = 0
			for j=1, k-1 do
				stats.assumed [k] = stats.assumed [k] + stats.assigned [j]
			end
		end
	end
	slots:Buildcylinders (cylinders [1])
	slots:Buildcylinders (cylinders [2])
	slots:Buildcylinders (cylinders [3])
	slots.startup = string.format ("Welcome to Slots!  The price for play is %dc which is automatically deducted from your account.  Have fun!", slotBet)
	
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
		if a == b or a == c or b == c then
			return true
		else
			return false
		end
	end
	
	function slots:CheckThreeOfAKind (roll)
		local a, b, c = string.match (roll, "|(%w+)|(%w+)|(%w+)|")
		if a == b and a == c then
			return true
		else
			return false
		end
	end
	
	function slots:Help (req)
		slots:SendMessage (string.format ("Just send !casino play to play.  Your bet of %dc is automatically deducted from your account", slotBet))
	end
	
	function slots:Play (req)
		slots:SendMessage ("Spin! Spin! Spin!")
		game.acct:MakeBet (slotBet, false)
		local result = "|"
		
		-- Cylinder 1
		result = result .. tostring (slots:GetSlotSymbol (cylinders [1])) .. "|"
		
		-- Cylinder 2
		result = result .. tostring (slots:GetSlotSymbol (cylinders [2])) .. "|"
		
		-- Cylinder 3
		result = result .. tostring (slots:GetSlotSymbol (cylinders [3])) .. "|"
		
		slots:SendMessage (string.format ("Result: %s", result))
		if slots:CheckThreeOfAKind (result) then
			slots:Win (payout3OfAKind)
		elseif slots:CheckTwoOfAKind (result) then
			slots:Win (payout2OfAKind)
		else
			slots:Lose ()
		end
	end
	
	return slots
end

function casino.games.slots.CreateConfigUI ()
end

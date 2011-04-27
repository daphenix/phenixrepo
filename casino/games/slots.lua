--[[
	Slots Game
]]

function casino.games.Slots (game)
	local slots = casino.games:BaseController  (game)
	slots.canPlay = true
	
	-- Game Data
	-- Set up payout data as bet + payout.  So if the automatic bet is 5c and you want a payout of 25c, the payout setting should be 20
	math.random (1, 100)
	local slotBet = 5
	local payout2OfAKind = 20
	local payout3OfAKind =95
	local probabilities1 = {
		assigned = {10, 10, 9, 11, 11, 9, 11, 9, 10, 10},
		assumed = {}
	}
	local probabilities2 = {
		assigned = {11, 11, 10, 9, 9, 10, 9, 10, 11, 10},
		assumed = {}
	}
	local probabilities3 = {
		assigned = {10, 9, 10, 10, 9, 11, 10, 11, 9, 11},
		assumed = {}
	}
	
	function slots:BuildProbabilities (stats)
		local j, k
		for k=1, 10 do
			stats.assumed [k] = 0
			for j=1, k-1 do
				stats.assumed [k] = stats.assumed [k] + stats.assigned [j]
			end
		end
	end
	slots:BuildProbabilities (probabilities1)
	slots:BuildProbabilities (probabilities2)
	slots:BuildProbabilities (probabilities3)
	slots.startup = string.format ("Welcome to Slots!  The price for play is %dc which is automatically deducted from your account.  Have fun!", slotBet)
	
	function slots:GetSlotSymbol (distribution)
		local index = math.random (1, 100)
		local token = 0
		local j
		for j=1, 10 do
			if index > distribution [j] then
				token = token + 1
			end
		end
	
		return token
	end
	
	function slots:CheckTwoOfAKind (roll)
		local a, b, c = string.match (roll, "|(%d+)|(%d+)|(%d+)|")
		if a == b or a == c or b == c then
			return true
		else
			return false
		end
	end
	
	function slots:CheckThreeOfAKind (roll)
		local a, b, c = string.match (roll, "|(%d+)|(%d+)|(%d+)|")
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
		result = result .. tostring (slots:GetSlotSymbol (probabilities1.assumed)) .. "|"
		
		-- Cylinder 2
		result = result .. tostring (slots:GetSlotSymbol (probabilities2.assumed)) .. "|"
		
		-- Cylinder 3
		result = result .. tostring (slots:GetSlotSymbol (probabilities3.assumed)) .. "|"
		
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

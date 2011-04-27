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
	local probabilities = {
		assigned = {5, 8, 10, 14, 15, 14, 12, 10, 7, 5},
		assumed = {}
	}
	local j, k
	for k=1, 10 do
		probabilities.assumed [k] = 0
		for j=1, k-1 do
			probabilities.assumed [k] = probabilities.assumed [k] + probabilities.assigned [j]
		end
	end
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
		local j
		for j=1, 3 do
			result = result .. tostring (slots:GetSlotSymbol (probabilities.assumed)) .. "|"
		end
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

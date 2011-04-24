--[[
	Slots Game
]]

function casino.games.Slots (game)
	local slots = casino.games:BaseController  (game)
	slots.canPlay = true
	
	-- Game Data
	math.random (1, 100)
	local payout2OfAKind = 5
	local payout3OfAKind =19
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
	
	function slots:Help ()
		slots:SendMessage ("Just send !casino play to play.  Your bet of 1c is automatically deducted from your account")
	end
	
	function slots:Play (req)
		slots:SendMessage ("Spin! Spin! Spin!")
		game.acct:MakeBet (1, false)
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

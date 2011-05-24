--[[
	Deck Class
]]

function casino.games:CreateCardDeck ()
	local suits = {"Spades", "Hearts", "Clubs", "Diamonds"}
	local faces = {"Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"}
	local value, suit, face
	
	-- Deck Variables
	local bottom = 52
	local deck = {}
	
	-- Build deck
	for _, suit in ipairs (suits) do
		value = 1
		for _, face in ipairs (faces) do
			table.insert (deck, {
				suit = suit,
				face = face,
				value = value
			})
			value = value + 1
		end
	end
	
	function deck:Shuffle ()
		bottom = 52
	end
	
	function deck:Draw ()
		local index = math.random (1, bottom)
		local card = deck [index]
		
		-- Shift all cards up and place newly drawn card to bottom
		-- Move up bottom
		local k
		for k=index, bottom-1 do
			deck [k] = deck [k+1]
		end
		deck [bottom] = card
		bottom = bottom - 1
		if bottom == 0 then
			deck:Shuffle ()
		end
		
		return card
	end
	
	return deck
end

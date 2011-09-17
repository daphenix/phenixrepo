--[[
	Deck Class
]]

math.random (1, 100)
function casino.games:CreateCardDeck (autoShuffle)
	autoShuffle = autoShuffle or false
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
				value = value,
				tostring = function ()
					return string.format ("%s of %s", face, suit)
				end
			})
			value = value + 1
		end
	end
	
	function deck:Shuffle ()
		bottom = 52
	end
	
	function deck:Draw ()
		if bottom == 0 then return nil end
		local index = math.random (1, bottom)
		local card = deck [index]
		
		-- Shift all cards up and place newly drawn card to bottom
		-- Move up bottom
		local k
		for k=index, 52 do
			deck [k] = deck [k+1]
		end
		deck [52] = card
		bottom = bottom - 1
		if autoShuffle and bottom == 0 then
			bottom = 51
		end
		
		return card
	end
	
	function deck:ShowHand (hand, numMask)
		numMask = numMask or 0
		local k, card
		local s = "| "
		if not hand or #hand == 0 then
			s = "| No Cards |"
		else
			for k, card in ipairs (hand) do
				if k <= numMask then
					s = s .. "* | "
				else
					s = s .. card:tostring () .. " | "
				end
			end
		end
		
		return s
	end
	
	return deck
end

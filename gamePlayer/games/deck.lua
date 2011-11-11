--[[
	Deck Class
]]

math.random (1, 100)
local suits = {"Spades", "Hearts", "Clubs", "Diamonds"}
local faces = {"Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"}
local images = {}

function Initialize ()
	local suit, face, id, imagePath
	for _, suit in ipairs (suits) do
		for _, face in ipairs (faces) do
			id = string.format ("%s of %s", face, suit)
			imagePath = string.format ("plugins/gamePlayer/games/images/%s-%s.png", suit, face)
			images [id] = iup.label {title="", image=imagePath}
		end
	end
	images ["back"] = iup.label {title="", image="plugins/gamePlayer/games/images/back.png"}
end

function gamePlayer.games:CreateCardDeck (autoShuffle, showIndex)
	-- Check for deck image initialization
	if #images == 0 then Initialize () end
	autoShuffle = autoShuffle or false
	showIndex = showIndex or false
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
		local s = "|"
		if not hand or #hand == 0 then
			s = "| No Cards |"
		else
			for k, card in ipairs (hand) do
				if k <= numMask then
					s = s .. " * |"
				elseif showIndex then
					s = string.format ("%s %d) %s |", s, k, card.tostring ())
				else
					s = string.format ("%s %s |", s, card.tostring ())
				end
			end
		end
		
		return s
	end
	
	function deck:ShowHandImages (hand, numMask)
		numMask = numMask or 0
		
		local k, id, face, suit
		local s = iup.hbox {}
		k = 0
		if type (hand) == "string" then
			for face, _, suit in string.gmatch (hand:sub (2), " ([%*%w]-)([ of ]-)([%w]-) |") do
				if face == "*" then
					-- Back
					iup.Append (s, images ["back"])
				else
					-- Append Card Image
					id = string.format ("%s of %s", face, suit)
					iup.Append (s, images [id])
				end
				iup.Append (s, iup.fill {size=-30})
			end
		elseif type (hand) == "table" then
		else
			-- No Cards
		end
		
		return s
	end
	
	return deck
end

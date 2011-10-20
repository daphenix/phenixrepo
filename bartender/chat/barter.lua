--[[
	Defines the negotiation skills of the Bartender


	The item object has the following structure:
	{
		name = <name of item>  -- This could be a trade item eventually
		askingPrice = <amt> -- The asking price for an item.  This is what the Bartender is current asking for
		finalPrice = <amt> -- The Bartender will refuse to go under this price, unless the player status is over 50 and passes a random check
		goodStatusAdjust = <amt> -- The adjustment made if the player does something positive for the Bartender during negotiation
		badStatusAdjust = <amt> -- Same as above, except for when doing bad things (like arguing or insulting)
	}

]]

bartender.chat.BarterParser (parser, item)
	p = {
		isParser = true,
		isDone = false,
		tree = nil
	}
	
	function p:GetResponse (grammar)
	end
end

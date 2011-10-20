function bartender.chat.TradeParser (parse)
	local p = {
		isParser = true,
		isDone = false,
		tree = nil
	}
	function p:GetResponse (grammar)
		self.isDone = true
		return "Trade?  What's that?"
	end
	
	return p
end

--[[
	Search Tree Trunk
]]

bartender.data.basic = {
	{keywords={"dock", "station"}, response="Turn the ship until the S is visible in the lower left circle (radar)//That's the station dock.  Enter the dock and press Enter to dock"},
	{keywords={"trade"}, response=bartender.chat.TradeParser},
	{keywords={"buy", "sell"}, response=bartender.chat.TradeParser},
	{keywords={}, response="Dummy"}
}

bartender.data.trunk = {
	{keywords={"hi", "hey", "heya", "yo"}, response=bartender.data.people.SayHello},
	{keywords={"bye", "cya", "later"}, response=bartender.data.people.SayGoodbye},
	{keywords={"how", "when", "where", "how", "do", "can"}, response=bartender.data.basic},
	{keywords={"what", "your", "name"}, response=bartender.data.people.Info}
}
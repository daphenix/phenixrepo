--[[
	Learning Intelligent Sentence Analyzer (LISA)
	
	Okay...it's still a cool acronym
]]

function bartender.chat.ElizaParser (parser)
	local p = {
		isParser = true,
		isDone = false
	}
	function p:GetResponse (grammar)
		self.isDone = true
		if parser.personality.statements then
			return parser.personality.statements [math.random (1, #parser.personality.statements)]
		else
			return bartender.data.statements [math.random (1, #bartender.data.statements)]
		end
	end
	
	return p
end
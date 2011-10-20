--[[
	Syntax parser
]]

local ignored = "|" .. table.concat (bartender.data.articles, "|") .. "|"
function bartender.chat:CreateSyntaxParser ()
	local p = {}
	
	function p:GetGrammar (s)
		print ("GetGrammar - start")
		bartender:Yield ()
		local g = {
			words = messaging:Split (s, " ", true),
			syntax = {},
			punctuation = {
				isQuestion = false
			}
		}
		if string.find (s, "?") then g.punctuation.isQuestion = true end
		
		-- Begin zeroing syntax
		local k, word
		for k, word in ipairs (g.words) do
			if string.find (ignored, word) then
				table.remove (g.words, k)
			end
		end
		
		print ("GetGrammar - end")
		return g
	end
	
	return p
end
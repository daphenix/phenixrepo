-- Random Statements

bartender.data.statements = {
	"What?",
	"I didn't quite catch that",
	"Could you repeat that in a full sentence?",
	"Huh?  I didn't get that.",
	"Could you repeat that please?",
	"I can't understand you."
}

-- Random Insults
bartender.data.insults = {
}

-- Different Bartender Personalities
bartender.data.people = {
	{name="Melanie", tolerance=5, anger=2},
	{name="Stacy", tolerance=5, anger=2},
	{name="Shonna", tolerance=5, anger=2},
	{name="Aster", tolerance=5, anger=2},
	{name="Helen", tolerance=5, anger=2},
	{name="Joanna", tolerance=5, anger=2},
	{name="Kylie", tolerance=5, anger=2}
}

function bartender.data.people.Info (parser)
	return string.format ("My name is %s", parser.personality.name)
end

function bartender.data.people.SayHello (parser)
	return "Hello.  May I help you?"
end

function bartender.data.people.SayGoodbye (parser)
	parser.context = nil
	parser.isDone = true
	
	return "Bye.  Come back later!"
end
--[[
	Slots Game
]]
casino.games.slots = {}
casino.games.slots.version = "1.0"
casino.games.slots.name = "Slots"
casino.games.slots.isPlayable = true

-- Game Data
local cylinderStats = {
	{
		assigned = {7, 7, 13, 7, 7, 6, 7, 6, 7, 13, 6, 7, 7}, -- Ca, Ap
		symbols = {"Aq", "Si", "Ca", "Fe", "Va", "Is", "Xi", "La", "Py", "Ap", "De", "Pe", "He"}
	},
	{
		assigned = {7, 7, 6, 7, 6, 13, 7, 6, 7, 13, 7, 7, 7}, -- Aq, Pe
		symbols = {"La", "Py", "Va", "Is", "Xi", "Aq", "Si", "Ca", "Fe", "Pe", "He", "Ap", "De"}
	},
	{
		assigned = {7, 6, 7, 6, 13, 7, 7, 13, 7, 6, 7, 7, 7}, -- Fe, Xi
		symbols = {"Si", "Py", "Ap", "Ca", "Fe", "Va", "Aq", "Xi", "La", "Pe", "He", "Is", "De"}
	}
}

-- Main Game Controller
function casino.games.slots.GetController (game, config, simulator)
	local slotBet = 5
	local payout2OfAKind = 3 * slotBet
	local payout3OfAKind = 20 * slotBet
	config = config or {}
	local slots = casino.games:BaseController  (game, config, simulator)
	slots.canPlay = true
	
	-- Game Data
	-- Set up payout data as bet + payout.  So if the automatic bet is 5c and you want a payout of 20c, the payout setting should be 15
	math.random (1, 100)
	local cylinders = {{}, {}, {}}
	
	local function Buildcylinders (source, stats)
		local j, k
		stats.assumed = {}
		stats.symbols = source.symbols
		for k=1, #source.assigned do
			stats.assumed [k] = 0
			for j=1, k-1 do
				stats.assumed [k] = stats.assumed [k] + source.assigned [j]
			end
		end
	end
	
	if config.cylinderStats then
		Buildcylinders (config.cylinderStats [1], cylinders [1])
		Buildcylinders (config.cylinderStats [2], cylinders [2])
		Buildcylinders (config.cylinderStats [3], cylinders [3])
	else
		Buildcylinders (cylinderStats [1], cylinders [1])
		Buildcylinders (cylinderStats [2], cylinders [2])
		Buildcylinders (cylinderStats [3], cylinders [3])
	end
	slots.startup = "Welcome to Slots!  The price for play is 5 tokens which is automatically deducted from your account.  Have fun!"
	
	local function GetSlotSymbol (stats)
		local index = math.random (1, 100)
		local token = 0
		local j
		for j=1, #stats.symbols do
			if index > stats.assumed [j] then
				token = token + 1
			end
		end
	
		return stats.symbols [token]
	end
	
	local function CheckTwoOfAKind (roll)
		local a, b, c = string.match (roll, "|(%w+)|(%w+)|(%w+)|")
		return (a == b or a == c or b == c)
	end
	
	local function CheckThreeOfAKind (roll)
		local a, b, c = string.match (roll, "|(%w+)|(%w+)|(%w+)|")
		return (a == b and a == c)
	end
	
	function slots:Help (req)
		slots:SendMessage ("Just send !casino play to play.  Your bet of 5 tokens is automatically deducted from your account")
		slots:SendMessage ("You may change the token size by sending the command !casino token <size> where size is 1, 10, 100, 1000, 10000, 100000, or 1000000.")
	end
	
	function slots:ParseKey (key, args)
		local level = tonumber (args)
		if key == "token" then
			if level and (level == 1 or level == 10 or level == 100 or 
								level == 1000 or level == 10000 or level == 100000 or 
								level == 1000000)  then
				slotBet = 5 * level
				payout2OfAKind = 3 * slotBet
				payout3OfAKind = 20 * slotBet
			else
				slots:SendMessage (string.format ("Token must be a power of 10 from 1c to 1Mc.  Current token value is %dc", slotBet/5))
			end
		end
	end
	
	function slots:Play (req)
		if game.acct:MakeBet (slotBet, false) then
			slots:SendMessage ("Spin! Spin! Spin!")
			local result = "|"
			
			-- Cylinder 1
			result = result .. tostring (GetSlotSymbol (cylinders [1])) .. "|"
			
			-- Cylinder 2
			result = result .. tostring (GetSlotSymbol (cylinders [2])) .. "|"
			
			-- Cylinder 3
			result = result .. tostring (GetSlotSymbol (cylinders [3])) .. "|"
			
			-- Check Result
			slots:SendMessage (string.format ("Result: %s", result))
			if CheckThreeOfAKind (result) then
				slots:Win (payout3OfAKind)
				if simulator then simulator:ThreeOfAKind () end
			elseif CheckTwoOfAKind (result) then
				slots:Win (payout2OfAKind)
			else
				slots:Lose ()
			end
		end
	end
	
	return slots
end

function casino.games.slots.CreateConfigUI (game, simulateButton)
	-- Set up Cylinder controls
	local sheet = {}
	sheet.cylinder = {
		{
			assigned = {},
			symbols = {},
			total = nil
		},
		{
			assigned = {},
			symbols = {},
			total = nil
		},
		{
			assigned = {},
			symbols = {},
			total = nil
		}
	}
	sheet.ui = {
		iup.vbox {
			iup.hbox {},
			iup.hbox {};
		},
		iup.vbox {
			iup.hbox {},
			iup.hbox {};
		},
		iup.vbox {
			iup.hbox {},
			iup.hbox {};
		}
	}
	
	local function GetCylinderStats (stats)
		-- Pull Stats data from fields
		stats = stats or {}
		local c, v, data, txt
		for c, data in ipairs (sheet.cylinder) do
			stats [c] = {}
			stats [c].symbols = {}
			stats [c].assigned = {}
			for v, txt in ipairs (data.symbols) do
				stats [c].symbols [v] = txt.value
			end
			for v, txt in ipairs (data.assigned) do
				if tonumber (txt.value) then
					stats [c].assigned [v] = tonumber (txt.value)
				else
					stats [c].assigned [v] = 0
				end
			end
		end
		
		return stats
	end
	
	local function TallyCylinderStats (c)
		local total = 0
		for _, prob in ipairs (sheet.cylinder [c].assigned) do
			if tonumber (prob.value) then
				total = total + tonumber (prob.value)
			end
		end
		
		return total
	end
	
	local c, v, data, value, total
	for c, data in ipairs (cylinderStats) do
		for v, value in ipairs (data.symbols) do
			sheet.cylinder [c].symbols [v] = iup.text {value=value, size="25x"}
			iup.Append (sheet.ui [c][1], sheet.cylinder [c].symbols [v])
		end
		iup.Append (sheet.ui [c][1], iup.fill {})
		total = 0
		for v, value in ipairs (data.assigned) do
			total = total + value
			sheet.cylinder [c].assigned [v] = iup.text {value=value, size="25x"}
			sheet.cylinder [c].assigned [v].action = function (col, newValue)
				sheet.cylinder [c].total.value = TallyCylinderStats (c)
				iup.Refresh (sheet.cylinder [c].total)
			end
			iup.Append (sheet.ui [c][2], sheet.cylinder [c].assigned [v])
		end
		sheet.cylinder [c].total = iup.text {value=total, size="35x", readonly="YES"}
		iup.Append (sheet.ui [c][2], sheet.cylinder [c].total)
		iup.Append (sheet.ui [c][2], iup.fill {size=5})
	end
	
	local numSimsText = iup.text {value="", size="50x"}
	local ui = iup.hbox {
		iup.fill {size = 5},
		iup.vbox {
			iup.label {title = "Cylinder Probabilities", font=casino.ui.font, fgcolor=casino.ui.fgcolor, expand="YES"},
			iup.fill {size = 5},
			iup.label {title = "Cylinder 1", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
			sheet.ui [1],
			iup.fill {size = 5},
			iup.label {title = "Cylinder 2", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
			sheet.ui [2],
			iup.fill {size = 5},
			iup.label {title = "Cylinder 3", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
			sheet.ui [3];
		},
		iup.fill {size = 5},
		iup.fill {size = 15, bgcolor=casino.ui.highlight},
		iup.fill {size = 5},
		iup.vbox {
			iup.label {title = "Random Token Test", font=casino.ui.font, fgcolor=casino.ui.fgcolor, expand="YES"},
			iup.fill {},
			iup.label {title="Number of Simulations?", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
			numSimsText,
			iup.fill {size = 25},
			simulateButton,
			iup.fill {size = 25};
			expand = "YES"
		},
		iup.fill {size = 5};
		expand = "YES"
	}
	
	function ui:DoSimulation ()
		-- Set up test
		local simulator = casino.games:CreateSimulator ("test", 0, {
			total3 = 0
		})
		simulator.total3 = 0
		simulator:Reset ()
		simulator.ThreeOfAKind = function ()
			simulator.total3 = simulator.total3 + 1
		end
		local config = {}
		config.cylinderStats = GetCylinderStats ()
		local simulation = casino.games:CreateGame ("slots", "test", config, simulator)
		
		-- Run Random Token Test
		math.random (1, 100)
		local k
		local numGames = tonumber (numSimsText.value)
		for k=1, numGames do
			simulation.controller:ProcessRequest ("token " .. tostring (math.pow (10, math.random (0, 6))))
			simulation.controller:ProcessRequest ("play")
		end
		local msg = string.format ("Total Games: %d", simulator.totalWins + simulator.totalLosses) .. "\n" ..
				string.format ("Total Wins: %d", simulator.totalWins) .. "\n" ..
				string.format ("Total Losses: %d", simulator.totalLosses) .. "\n" ..
				string.format ("Total 3 of a Kind: %d", simulator.total3) .. "\n" ..
				string.format ("Total Bet: %e", simulator.totalBet) .. "\n" ..
				string.format ("Total Paid: %e", simulator.totalPaidout) .. "\n" ..
				string.format ("House Earnings: %e", simulator.totalBet - simulator.totalPaidout) .. "\n" ..
				string.format ("House Percentage: %f\n", 100 - (simulator.totalPaidout/simulator.totalBet * 100))
		
		casino.ui:CreateInfoUI ("Random Token Test", msg)
	end
	
	function ui:DoSave ()
		GetCylinderStats (cylinderStats)
		casino.data:SaveUserSettings ()
	end
	
	function ui:DoCancel ()
	end
	
	return ui
end

function casino.games.slots:GetGameData ()
	return cylinderStats
end

function casino.games.slots:SetGameData (data)
	cylinderStats = data
end

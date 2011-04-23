--[[
	Debugging Code
]]

function casino:AddGame (args)
	local gameName, playerName = args [2], args [3]
	casino.data.tables [playerName] = casino.games:CreateGame (gameName, playerName)
end

function casino:RemoveGame (args)
	local playerName = args [2]
	casino.data.tables [playerName] = nil
end

function casino:AddAccount (args)
	local playerName, amount = args [2], args [3]
	casino.bank:OpenAccount (playerName, tonumber (amount))
end

function casino:RemoveAccount (args)
	local playerName = args [2]
	casino.bank:CloseAccount (playerName)
end

function casino:DisplayAccounts ()
	local acct
	local present = false
	for _, acct in pairs (casino.bank.trustAccount) do
		print (string.format ("%s:\tBalance: %d\tCredit: %d\tBet: %d", acct.player, acct.balance, acct.creditLine, acct.currentBet))
		present = true
	end
	if not present then print ("No Accounts Held") end
end

function casino:Status ()
	if casino.data.houseThread then
		print (coroutine.status (casino.data.houseThread))
	else
		print ("No Thread")
	end
end

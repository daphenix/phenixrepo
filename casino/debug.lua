--[[
	Debugging and Admin Code
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
	casino.bank:OpenAccount (playerName, tonumber (amount), true)
end

function casino:RemoveAccount (args)
	local playerName = args [2]
	casino.bank:CloseAccount (playerName)
end

function casino:DisplayAccounts ()
	local acct
	local present = false
	print ("\nBank Accounts")
	for _, acct in pairs (casino.bank.trustAccount) do
		print (string.format ("%s:\tBalance: %d\tCredit: %d\tBet: %d", acct.player, acct.balance, acct.creditLine, acct.currentBet))
		present = true
	end
	if not present then print ("No Accounts Held") end
end

function casino:DisplayGames ()
	local game
	local present = false
	print ("\nOpen Games")
	for _, game in pairs (casino.data.tables) do
		print (string.format ("%s:\tGame: %s", game.player, game.name))
		present = true
	end
	if not present then print ("No Games Open") end
end

function casino:DisplayWaitQueue ()
	local k, player
	local present = false
	print ("\nPlayers Waiting")
	for k, player in ipairs (casino.data.waitQueue) do
		print (string.format ("%d:\tName: %s", k, player))
		present = true
	end
	if not present then print ("No One") end
end

function casino:Status ()
	if casino.data.houseThread then
		print (string.format ("House Thread: %s", coroutine.status (casino.data.houseThread)))
	else
		print ("No Thread")
	end
	local game, acct
	casino:DisplayAccounts ()
	casino:DisplayGames ()
	casino:DisplayWaitQueue ()
end

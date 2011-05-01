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
	print ("\n\12700ff00Bank Accounts\127o")
	for _, acct in pairs (casino.bank.trustAccount) do
		print (string.format ("\127888822%s:\tBalance: %d\tCredit: %d\tBet: %d\127o", acct.player, acct.balance, acct.creditLine, acct.currentBet))
		present = true
	end
	if not present then print ("\127888822No Accounts Held\127o") end
end

function casino:DisplayGames ()
	local game
	local present = false
	print ("\n\12700ff00Open Games")
	for _, game in pairs (casino.data.tables) do
		print (string.format ("\127888822%s:\tGame: %s\127o", game.player, game.name))
		present = true
	end
	if not present then print ("\127888822No Games Open\127o") end
end

function casino:DisplayWaitQueue ()
	local k, player
	local present = false
	print ("\n\12700ff00Players Waiting")
	for k, player in ipairs (casino.data.waitQueue) do
		print (string.format ("\127888822%d:\tName: %s\127o", k, player))
		present = true
	end
	if not present then print ("\127888822No One\127o") end
end

function casino:DisplayGameStats ()
	print ("\n\12700ff00Game Stats\127o");
	print (string.format ("\127888822Numbers of wins: %d\127o", casino.data.wins))
	print (string.format ("\127888822Numbers of losses: %d\127o", casino.data.losses))
	print (string.format ("\127888822Total credits bet into bank: %d\127o", casino.data.totalBet))
	print (string.format ("\127888822Total credits paid out by bank: %d\127o", casino.data.totalPaidout))
end

function casino:Status ()
	if casino.data.houseThread then
		print (string.format ("\12700ffffHouse Thread: %s\127o", coroutine.status (casino.data.houseThread)))
	else
		print ("\12700ffffNo Thread\127o")
	end
	local game, acct
	casino:DisplayAccounts ()
	casino:DisplayGames ()
	casino:DisplayWaitQueue ()
	casino:DisplayGameStats ()
end

function casino:Reset ()
	math.randomseed (os.time ())
	math.random ()
end

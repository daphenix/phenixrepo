casino.bank = {}
casino.bank.trustAccount = {}

function casino.bank:SetUpTrustAccount (playerName, amt)
end

function casino.bank:Payout (playerName, amt)
	GiveMoney (playerName, amt)
	
	-- Deduct payout amount from trust account
end

function casino.bank:Cashout (playerName)
	if casino.bank.trustAccount [playerName] then
		-- Send remaining money in trust account to player, clear trust account
		--GiveMoney (playerName, total)
		casino.bank.trustAccount [playerName] = nil
	else
		SendChat ("You must first create an account to cashout", "PRIVATE", playerName)
	end
end

casino.bank = {}
casino.bank.trustAccount = {}

function casino.bank:OpenAccount (playerName, amt, makeAnnouncement)
	if amt and amt > 0 then
		local acct = {
			player = playerName,
			balance = amt,
			creditLine = 0,
			currentBet = 0
		}

		function acct:SendMessage (msg)
			table.insert (casino.data.messageQueue, casino:Message (acct.player, msg))
		end
		
		function acct:IsPlayerInSector ()
			local result = false
			ForEachPlayer (function (id)
				if GetPlayerName (id) == acct.player then result = true end
			end)
			
			return result
		end
		
		function acct:MakeBet (amt, showMessages)
			showMessages = showMessages or false
			if amt > 0 and amt <= acct.balance + acct.creditLine then
				acct.currentBet = amt
				acct.balance = acct.balance - amt
				if showMessages then acct:SendMessage (string.format ("Your bet of %dc has been registered", amt)) end
				return true
			else
				acct:SendMessage (string.format ("Bet must be more than 0c and no more than %dc", (acct.balance + acct.creditLine)))
				return false
			end
		end
		
		function acct:Withdraw (amt)
			casino:Log (string.format ("%s attempted to witdraw %d from acct with balance %d", acct.player, amt, acct.balance))
			if acct:IsPlayerInSector () then
				if amt >= 0 and amt <= acct.balance then
					acct.balance = acct.balance - amt
					--GiveMoney (acct.player, amt)
					acct:SendMessage (string.format ("%d Withdrawn", amt))
				elseif amt < 0 then
					acct:SendMessage ("You cannot withdraw a negative amount")
				elseif amt > acct.balance then
					acct:SendMessage ("You cannot withdraw more credits than you have on account!")
				end
			else
				acct:SendMessage ("You must be present in the casino sector to make a withdraw")
			end
		end
		
		function acct:Deposit (amt)
			if amt > 0 then
				acct.balance = acct.balance + amt
				acct:SendMessage (string.format ("%dc Deposited", amt))
			end
		end
		
		casino.bank.trustAccount [playerName] = acct
		if makeAnnouncement then
			acct:SendMessage (string.format ("Account Created with initial balance of %dc", amt))
		end
		casino:Log ("Account created for " .. playerName)
		
		return acct
	end
end

function casino.bank:CloseAccount (playerName)
	casino:Log (string.format ("Closeout account attempt for %s", playerName))
	if casino.bank.trustAccount [playerName]  then
		if casino.bank.trustAccount [playerName]:IsPlayerInSector () then
			-- Send remaining money in trust account to player if in sector, clear trust account
			--GiveMoney (playerName, casino.bank.trustAccount [playerName].balance)
			casino.bank.trustAccount [playerName] = nil
		else
		end
	else
		casino:SendMessage (playerName, "You must first create an account in order to close")
	end
end

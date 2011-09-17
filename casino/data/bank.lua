casino.bank = {}
casino.bank.trustAccount = {}
casino.bank.assets = 0

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
		
		function acct:MakeBet (amt, showMessage)
			showMessage = showMessage or false
			if amt > 0 and amt <= acct.balance + acct.creditLine then
				acct.currentBet = amt
				acct.balance = acct.balance - amt
				casino.data.totalBet = casino.data.totalBet + amt
				if showMessage then acct:SendMessage (string.format ("Your bet of %dc has been registered", amt)) end
				return true
			else
				acct:SendMessage (string.format ("Maximum Bet is %dc", (acct.balance + acct.creditLine)))
				return false
			end
		end
		
		function acct:Withdraw (amt)
			casino:Log (string.format ("%s attempted to witdraw %d from acct with balance %d", acct.player, amt, acct.balance))
			if acct:IsPlayerInSector () then
				if amt >= 0 and amt <= acct.balance then
					acct.balance = acct.balance - amt
					GiveMoney (acct.player, amt)
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
		
		function acct:Deposit (amt, showMessage)
			casino:Log (string.format ("%d was deposited in the account of %s", amt, acct.player))
			if not showMessage then showMessage = true end
			if amt > 0 then
				acct.balance = acct.balance + amt
				if showMessage then
					acct:SendMessage (string.format ("%dc Deposited", amt))
				end
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

-- Create a simulated bank account for testing purposes
function casino.bank:CreateSimulationAccount (playerName, amt, simulator)
	local acct = {
		player = playerName,
		balance = amt,
		creditLine = 0,
		currentBet = 0
	}

	function acct:SendMessage (msg) end
	
	function acct:MakeBet (amt)
		acct.currentBet = amt
		acct.balance = acct.balance - amt
		simulator.totalBet = simulator.totalBet + amt
		
		return true
	end
		
	function acct:Withdraw (amt)
		if amt >= 0 and amt <= acct.balance then
			acct.balance = acct.balance - amt
		end
	end
	
	function acct:Deposit (amt)
		if amt > 0 then
			acct.balance = acct.balance + amt
		end
	end
	
	return acct
end

function casino.bank:GetTotalAssets ()
	local acct
	local total = 0
	for _, acct in pairs (casino.bank.trustAccount) do
		total = total + acct.balance + acct.currentBet
	end
	
	return total
end

function casino.bank:CloseAccount (playerName, isAdmin)
	casino:Log (string.format ("Closeout account attempt for %s", playerName))
	if casino.bank.trustAccount [playerName]  then
		if casino.bank.trustAccount [playerName]:IsPlayerInSector () then
			-- Send remaining money in trust account to player if in sector, clear trust account
			GiveMoney (playerName, casino.bank.trustAccount [playerName].balance)
			casino.bank.trustAccount [playerName] = nil
			casino:SendMessage (playerName, "Your casino account has been closed")
		elseif isAdmin then
			local s = string.format ("%s not in sector", playerName)
			casino:Log (s)
			casino.ui:CreateApprovalUI (s, "Close Anyway?", function ()
				casino.bank.trustAccount [playerName] = nil
				casino:Log ("Account forced closed")
			end)
		end
	elseif not isAdmin then
		casino:SendMessage (playerName, "You must first create an account in order to close")
	end
end

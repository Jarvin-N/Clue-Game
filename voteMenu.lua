local voteMenu = {}

--Variables that hold paths to different objects.
--ServerStorage
local ServerStorage = game:GetService("ServerStorage")
local ValueTags = ServerStorage:FindFirstChild("ValueTags")
local GUIStorage = ServerStorage:FindFirstChild("GUIStorage")
local voteMenuGUI = GUIStorage:FindFirstChild("voteMenu")
--ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:FindFirstChild("remoteEvents")
local voteEvent = remoteEvents:FindFirstChild("characterSelect")
--Players
local Players = game:GetService("Players")
--Teams
local Teams = game:GetService("Teams")
local Playing = Teams:FindFirstChild("Playing")
local Eliminated = Teams:FindFirstChild("Eliminated")

--Table
voteTable = {}

--Function
function voteMenu.sendVote(player)
	local voteMenuClone = voteMenuGUI:Clone()
	local playerTable = Playing:GetPlayers()
	--Update the buttons of voteMenuClone
	local buttonsTable = voteMenuClone:FindFirstChild("Frame"):FindFirstChild("Buttons"):GetChildren()
	for i = 1, #playerTable, 1 do
		if playerTable[i] ~= nil then
			local BTN = buttonsTable[i]
			BTN.Text = playerTable[i]:GetAttribute("CharacterName")
			BTN.Visible = true
		end
	end
	--Send the player the voteMenuClone
	voteMenuClone.Parent = player.PlayerGui
end

function voteMenu.recieveVote(player, selection)
	--Recieves the vote the player made
	table.insert(voteTable, selection)
end

function voteMenu.clearVotes()
	--Clears the vote table.
	voteTable = {}
end

function voteMenu.calculateVotes()
	--Dictionary to hold votes
	local DictionaryVote = {}
	if #voteTable > 0 then
		for i = 1, #voteTable, 1 do
			local counter = 0
			for j = 1,#voteTable, 1 do
				if voteTable[i] == voteTable[j] then
					counter = counter + 1
				end
			end
			--Checking if the key exists in the dictionary
			if DictionaryVote[voteTable[i]] == nil then
				DictionaryVote[voteTable[i]] = counter
			end
		end
		--Finding the highest number of votes
		local counter = 0
		for player, votes in pairs(DictionaryVote) do
			if votes >= counter then
				counter = votes
			end
		end
		--Finding the people with the highest number of votes
		local mostVoted = {}
		for player, votes in pairs(DictionaryVote)  do
			if votes == counter then
				table.insert(mostVoted, player)
			end
		end
		--Pick a random person
		if #mostVoted  > 1 then
			local mostVoted = voteMenu.random(mostVoted)
		else
			mostVoted = mostVoted[1]
		end
		--Returning the instance
		local playerTable = Playing:GetPlayers()
		print(mostVoted)
		for index, player in ipairs(playerTable) do
			local playerChar = player:GetAttribute("CharacterName")
			if playerChar == mostVoted then
				return player
			end
		end
	else
		--Vote off a random player if no one votes.
		local playerTable = Playing:GetPlayers()
		local randomNum = math.random(1, #playerTable)
		return playerTable[randomNum]
	end
end


function voteMenu.random(voteTable)
	--This function chooses a random player to eliminate
	local randomNum = math.random(1, #voteTable)
	local eliminated = voteTable[randomNum]
	return eliminated
end

function voteMenu.removeGui()
	voteEvent:FireAllClients()
end




return voteMenu

local clueMenu = {}

--Variables that hold paths to different objects
--ServerStorage
local ServerStorage = game:GetService("ServerStorage")
local ClueStorage = ServerStorage:FindFirstChild("ClueStorage")
local Locations = ServerStorage:FindFirstChild("Locations")
local Nurse = Locations:FindFirstChild("Nurse")
local GUIStorage = ServerStorage:FindFirstChild("GUIStorage")
local clueGUI = GUIStorage:FindFirstChild("clueGUI")
--ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:FindFirstChild("remoteEvents")
local clueEvent = remoteEvents:FindFirstChild("clueEvent")


--Table
Clues = {}
RealCounter = 0


--Functions
function clueMenu.sendMenu(player)
	local MenuClone = clueGUI:Clone()
	local CharacterName = player:GetAttribute("CharacterName")
	--Setting the Buttons to equal the player's clue names
	local CharacterClues = ClueStorage:FindFirstChild(CharacterName):Clone()
	local CharacterCluesTable = CharacterClues:GetChildren()
	local RBTNS = MenuClone:FindFirstChild("Frame"):FindFirstChild("RBTNS"):GetChildren()
	for index, button in ipairs(RBTNS) do
		button.Text = CharacterCluesTable[index].Name
	end
	--Fake Clues
	local FBTNS = MenuClone:FindFirstChild("Frame"):FindFirstChild("FBTNS"):FindFirstChild("BTNS"):GetChildren()
	local FakeCluesClone = ClueStorage:FindFirstChild("FakeClue"):Clone()
	local FakeClueTable = FakeCluesClone:GetChildren()
	--Remove character's clues from fake clues
	for i = 1, #FakeClueTable, 1 do
		for j = 1, #CharacterCluesTable, 1 do
			if FakeClueTable[i] ~= nil then
				if FakeClueTable[i].Name == CharacterCluesTable[j].Name then
					FakeClueTable[i] = nil
				end
			end 
		end
	end 
	
	for i = 1, #FakeClueTable, 1 do
		if FakeClueTable[i] == nil then
			table.remove(FakeClueTable, i)
		end
	end
	
	for index, button in ipairs(FBTNS) do
		if FakeClueTable[index] ~= nil then
			button.Text = FakeClueTable[index].Name
		else 
			button.Visible = false
		end
	end
	--Send player the gui
	MenuClone.Parent = player.PlayerGui
end

function clueMenu.cleanUP()
	Clues = {}
	RealCounter = 0
	game.Workspace:FindFirstChild("Nurse"):Destroy()
	game.Workspace:FindFirstChild("FakeClue"):Destroy()
end

function clueMenu.receiveClues(player, clueName, typeClue)
	if typeClue == ("Real") then
		RealCounter += 1
		if RealCounter >= 3 then
			clueEvent:FireClient(player, "Real")
		end
	elseif typeClue == ("Fake") then
		clueEvent:FireClient(player, "Fake")		
	end
	table.insert(Clues, clueName)
	if #Clues == 4 then
		clueEvent:FireClient(player, "Remove")
	end
end
clueEvent.OnServerEvent:Connect(clueMenu.receiveClues)

function clueMenu.removeGUI(player)
	clueEvent:FireClient(player, "Remove")
end

function clueMenu.returnClues(player)
	if #Clues == 4 then
		print(Clues)
		return Clues
	else
		--If the player has less than 4 clues
		local CharacterName = player:GetAttribute("CharacterName")
		--Setting the Buttons to equal the player's clue names
		local CharacterClues = ClueStorage:FindFirstChild(CharacterName):Clone()
		local CharacterCluesTable = CharacterClues:GetChildren()
		local MissingClues = 4 - #Clues
		--Figure out what clues are already found
		if #Clues == 0 then
			for index, value in ipairs(CharacterCluesTable) do
				table.insert(Clues, index)
			end
		else
			for i=1, #CharacterCluesTable, 1 do
				for j=1, #Clues, 1 do
					if CharacterCluesTable[i] ~= nil then
						if CharacterCluesTable[i].Name == Clues[j] then
							table.remove(CharacterCluesTable, i)
						end
					end
				end
			end
			for i=1, MissingClues, 1 do
				local value = CharacterCluesTable[i].Name
				table.insert(Clues, value)
			end
		end
	end
end

function clueMenu.displayClues()
	local NurseClone = Nurse:Clone()
	NurseClone.Parent = game.Workspace
	local ClueSpots = NurseClone:FindFirstChild("ClueSpots"):GetChildren()
	--Find the clues and clone them
	local ClueItems = {}
	local NeededClues = ClueStorage:FindFirstChild("FakeClue"):Clone()
	NeededClues.Parent = game.Workspace
	local NeededCluesTable = NeededClues:GetChildren()
	for index, clue in ipairs(Clues) do
		for index, clue2 in ipairs(NeededCluesTable) do
			if clue == clue2.Name then
				table.insert(ClueItems, clue2)
			end
		end
	end
	
	for index, clue in ipairs(ClueItems) do
		clue.Position =  ClueSpots[index].Position		
	end
	local TeleSpots = NurseClone:FindFirstChild("TeleSpots"):GetChildren()
	return TeleSpots
end


return clueMenu

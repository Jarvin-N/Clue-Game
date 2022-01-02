local GManager = {}

--Variables that hold paths to different objects
--ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:FindFirstChild("remoteEvents")
local hudEvent = remoteEvents:FindFirstChild("hudEvent")
local timerEvent = remoteEvents:FindFirstChild("timerEvent")
--ServerStorage
local ServerStorage = game:GetService("ServerStorage")
local ValueTags = ServerStorage:FindFirstChild("ValueTags")
local GameText = ValueTags:FindFirstChild("GameText")
local hudEnabled = ValueTags:FindFirstChild("hudEnabled")
local timerEnabled = ValueTags:FindFirstChild("timerEnabled")
local TimerTag = ValueTags:FindFirstChild("TimerTag")
local Speaker = ValueTags:FindFirstChild("Speaker")
--Players
local Players = game:GetService("Players")
--Teams
local Teams = game:GetService("Teams")
local Playing = Teams:FindFirstChild("Playing")
local Eliminated = Teams:FindFirstChild("Eliminated")
--OtherScripts
local PManager = require(script.Parent.PManager)
local CharacterMenu = require(script.Parent.CharacterMenu)

--Functions
function GManager.updateGameInfo(speaker, text, displayHud)
	--Sends the current hud info to all players.
	Speaker.Value = speaker
	GameText.Value = text
	hudEnabled.Value = displayHud
	hudEvent:FireAllClients(speaker,text, displayHud)
end

function GManager.CatchUP(player)
	--Updates newly connect player's to the current HUD
	local displayHud = hudEnabled.Value
	local text = GameText.Value
	local speaker = Speaker.Value
	hudEvent:FireClient(player, speaker, text, displayHud)
end

function GManager.Timer(Text, TimeVal, displayTimer)
	--Sends all the timer info to players
	GameText.Value = Text
	timerEnabled.Value = displayTimer
	timerEvent:FireAllClients(Text, TimeVal, displayTimer)
end

function GManager.TimerCatchUP(player)
	--Updates newly connected players to the current timer
	local text = GameText.Value
	local timer = TimerTag.Value
	local displaytimer = timerEnabled.Value
	timerEvent:FireClient(player, text, timer, displaytimer)
end

Players.PlayerAdded:Connect(GManager.CatchUP)
Players.PlayerAdded:Connect(GManager.TimerCatchUP)

function GManager.CountDown(Time, Header)
	TimerTag.Value = Time
	repeat
		GManager.updateGameInfo("", "", false)
		TimerTag.Value = TimerTag.Value - 1
		GManager.Timer(Header, TimerTag.Value, true)
		if Header == "Intermission" then
			local playerTable = Players:GetChildren()
			for index, player in ipairs(playerTable) do
				PManager.updateTeam(player, Playing)
			end
		end
		wait(1)
	until TimerTag.Value  == 0
	GManager.Timer("", "", false)
end

--GameText

function GManager.Introduction(contestants)
	--Add game instructions here
end



return GManager

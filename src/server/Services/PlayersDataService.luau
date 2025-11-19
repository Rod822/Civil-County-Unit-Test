local DataStoreService = game:GetService("DataStoreService")
local DS = DataStoreService:GetDataStore("PlayerData")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = ReplicatedStorage:WaitForChild("Classes")

local Profile = require(Classes.Profile)

--- @class PlayersDataService
--- @brief Створює профілі гравців, синхронізує DataStore та leaderstats.
local PlayersDataService = {}
PlayersDataService.__index = PlayersDataService

PlayersDataService._profiles = {}

--- @brief Обробляє вхід гравця, створюючи профіль і leaderstats.
--- @param player Player Roblox-гравець.
function PlayersDataService:OnPlayerAdded(player: Player)
	local LoadedData: { Money: number }? = nil
	local success, result = pcall(function()
		return DS:GetAsync(tostring(player.UserId))
	end)

	if success and result and typeof(result) == "table" and typeof(result.Money) == "number" then
		LoadedData = result
	else
		LoadedData = { Money = 200 }
	end

	local profile = Profile.new(player.UserId, LoadedData)
	self._profiles[player.UserId] = profile

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local Money = Instance.new("IntValue")
	Money.Name = "Money"
	Money.Value = LoadedData.Money
	Money.Parent = leaderstats
end

--- @brief Зберігає персистентні дані гравця перед виходом.
--- @param player Player Roblox-гравець.
function PlayersDataService:OnPlayerRemoving(player: Player)
	local profile = self._profiles[player.UserId]
	if not profile then
		return
	end

	local PersistentData = profile.persistent
	local success, err = pcall(function()
		DS:SetAsync(tostring(player.UserId), PersistentData)
	end)
	if not success then
		warn("Failed to save data for player: " .. player.UserId .. " Error: " .. err)
	end
	self._profiles[player.UserId] = nil
end

--- @brief Додає гравцю кошти та оновлює leaderstats.
--- @param player Player Цільовий гравець.
--- @param amount number Сума для додавання.
function PlayersDataService:AddMoney(player: Player, amount: number)
	local profile = self._profiles[player.UserId]
	if not profile then
		return
	end
	profile.persistent.Money = profile.persistent.Money + amount
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local Money = leaderstats:FindFirstChild("Money")
		if Money then
			Money.Value = profile.persistent.Money
		end
	end
end

--- @brief Прагне списати кошти, якщо їх достатньо.
--- @param player Player Цільовий гравець.
--- @param amount number Сума для зняття.
--- @return boolean? false, якщо грошей недостатньо; nil, якщо профіль не знайдено.
function PlayersDataService:RemoveMoney(player: Player, amount: number): boolean?
	local profile = self._profiles[player.UserId]
	if not profile then
		return nil -- Profile not found
	end
	if profile.persistent.Money < amount then
		return false -- Not enough money
	end
	profile.persistent.Money = profile.persistent.Money - amount
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local Money = leaderstats:FindFirstChild("Money")
		if Money then
			Money.Value = profile.persistent.Money
		end
	end
	return true -- Successfully removed money
end

--- @brief Оновлює значення в persistent або session частині профілю.
--- @param player Player Цільовий гравець.
--- @param key string Ім'я поля.
--- @param value any Нове значення.
function PlayersDataService:SetData(player: Player, key: string, value: any)
	local profile = self._profiles[player.UserId]
	if not profile then
		warn("Profile not found for" .. player.Name)
		return
	end

	if profile.persistent[key] ~= nil then
		profile.persistent[key] = value
		return
	end
	if profile.session[key] ~= nil then
		profile.session[key] = value
		return
	end
	warn("[PlayersDataService] Unknown data key " .. key)
end

return PlayersDataService

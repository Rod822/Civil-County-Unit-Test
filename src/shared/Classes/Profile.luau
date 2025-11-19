local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = ReplicatedStorage:WaitForChild("Classes")
local PersistentData = require(Classes.PersistentData)
local SessionData = require(Classes.SessionData)

--- @class Profile
--- @brief Контейнер гравця, що містить persistent (PersistentData) та session (SessionData) записи.
local Profile = {}
Profile.__index = Profile

export type Profile = {
	persistent: PersistentData.PersistentData,
	session: SessionData.SessionData,
}

--- @brief Створює новий профіль гравця.
--- @param userId number Унікальний Roblox UserId.
--- @param tableFromDataStore table|nil Сира таблиця, отримана з DataStore.
--- @return Profile Структура з ініціалізованими persistent/session даними.
function Profile.new(userId: number, tableFromDataStore: { [string]: any }?): Profile
	local self = setmetatable({}, Profile)
	self.persistent = PersistentData.new(tableFromDataStore)
	self.session = SessionData.new()
	return self
end

return Profile

--- @class PersistentData
--- @brief Персистентний стан гравця (наприклад, баланс Money), що зберігається в Roblox DataStore.
local PersistentData = {}
PersistentData.__index = PersistentData

export type PersistentData = {
	Money: number,
}

local DEFAULTS = {
	Money = 200,
}

--- @brief Створює структуру персистентних даних із таблиці DataStore.
--- @param tableFromDataStore table|nil Вихідні значення, прочитані з DataStore.
--- @return PersistentData Ініціалізований запис зі сталими дефолтами.
function PersistentData.new(tableFromDataStore: { [string]: any }?): PersistentData
	local obj = {
		Money = (tableFromDataStore and tonumber(tableFromDataStore.Money)) or DEFAULTS.Money,
	}
	return setmetatable(obj, PersistentData)
end

return PersistentData

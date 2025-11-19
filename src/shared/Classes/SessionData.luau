--- @class SessionData
--- @brief Тимчасовий стан гравця (робота, paycheckBonus), який скидається після виходу.
local SessionData = {}
SessionData.__index = SessionData

export type SessionData = {
	paycheckBonus: number,
	job: string,
}

local DEFAULTS = {
	paycheckBonus = 0,
	job = "Civilian",
}

--- @brief Створює новий об'єкт SessionData з дефолтними значеннями.
--- @return SessionData Незалежний запис для конкретного профілю.
function SessionData.new(): SessionData
	local obj = table.clone(DEFAULTS)
	return setmetatable(obj, SessionData)
end

return SessionData

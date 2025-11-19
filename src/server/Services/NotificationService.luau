local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayersDataService = require(ServerScriptService.Services.PlayersDataService)

--- @class NotificationService
--- @brief Розсилає системні повідомлення гравцям, роботам і всьому серверу.
local NotificationService = {}
NotificationService.__index = NotificationService

local DEFAULT_DURATION = 5

local function getRemote(): RemoteEvent
	local re = ReplicatedStorage:FindFirstChild("NotifyRE")
	if not re then
		re = Instance.new("RemoteEvent")
		re.Name = "NotifyRE"
		re.Parent = ReplicatedStorage
	end
	return re :: RemoteEvent
end

getRemote()

local function dispatchTo(player: Player, payload: { [string]: any })
	getRemote():FireClient(player, payload)
end

--- @brief Широкомовне повідомлення всім гравцям на сервері.
--- @param text string Основний текст.
--- @param title string|nil Заголовок (Notice за замовчуванням).
--- @param duration number|nil Тривалість показу в секундах.
function NotificationService:Broadcast(text: string, title: string?, duration: number?)
	for _, plr in ipairs(Players:GetPlayers()) do
		dispatchTo(plr, {
			title = title or "Notice",
			text = text,
			duration = duration or DEFAULT_DURATION,
			kind = "broadcast",
		})
	end
end

--- @brief Надсилає повідомлення конкретному гравцю.
--- @param player Player Отримувач.
--- @param text string Текст повідомлення.
--- @param title string|nil Заголовок (Message за замовчуванням).
--- @param duration number|nil Тривалість показу.
function NotificationService:SendTo(player: Player, text: string, title: string?, duration: number?)
	dispatchTo(player, {
		title = title or "Message",
		text = text,
		duration = duration or DEFAULT_DURATION,
		kind = "direct",
	})
end

--- @brief Розсилає повідомлення всім гравцям із вказаною роботою.
--- @param jobName string Значення `SessionData.job`.
--- @param text string Основний текст.
--- @param title string|nil Заголовок повідомлення.
--- @param duration number|nil Тривалість показу.
function NotificationService:SendToJob(jobName: string, text: string, title: string?, duration: number?)
	for _, plr in ipairs(Players:GetPlayers()) do
		local profile = PlayersDataService._profiles[plr.UserId]
		if profile and profile.session.job == jobName then
			dispatchTo(plr, {
				title = title or jobName,
				text = text,
				duration = duration or DEFAULT_DURATION,
				kind = "job",
			})
		end
	end
end

--- @brief Надсилає деталізоване повідомлення про нарахування зарплати.
--- @param player Player Отримувач.
--- @param base number Базова сума виплати.
--- @param bonus number Додатковий бонус.
--- @param total number Підсумкова виплата.
--- @param jobName string Робота, за яку іде виплата.
function NotificationService:Paycheck(player: Player, base: number, bonus: number, total: number, jobName: string)
	local title = "Paycheck"
	local parts = {}
	table.insert(parts, ("Job: %s"):format(jobName))
	table.insert(parts, ("Base: $%d"):format(base))
	if (bonus or 0) > 0 then
		table.insert(parts, ("Bonus: $%d"):format(bonus))
	end
	table.insert(parts, ("Total: $%d"):format(total))
	self:SendTo(player, table.concat(parts, " | "), title, 6)
end

return NotificationService

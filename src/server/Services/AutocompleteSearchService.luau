local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = ReplicatedStorage:WaitForChild("Classes")

local TrieTreeRecord = require(Classes:WaitForChild("TrieTreeRecord"))

--- @class AutocompleteSearchService
--- @brief Підтримує множинні trie для пошуку об'єктів за префіксом.
local AutocompleteSearchService = {}

local Trees = {}

--- @brief Ініціалізує trie для вибраної папки.
--- @param name string Унікальне ім'я дерева.
--- @param folder Instance Папка з екземплярами, які треба індексувати.
function AutocompleteSearchService.InitTree(name, folder)
	assert(typeof(name) == "string" and name ~= "", "InitTree: name must be non-empty string")
	assert(typeof(folder) == "Instance", "InitTree: folder must be an Instance")

	if Trees[name] ~= nil then
		AutocompleteSearchService.RemoveTree(name)
	end

	local tree = TrieTreeRecord.new(folder)

	for _, child in ipairs(folder:GetChildren()) do
		tree:AddInstance(child)
	end

	tree.conns[#tree.conns + 1] = folder.ChildAdded:Connect(function(child)
		tree:AddInstance(child)
	end)
	tree.conns[#tree.conns + 1] = folder.ChildRemoved:Connect(function(child)
		tree:RemoveInstance(child)
	end)

	Trees[name] = tree
end

--- @brief Виконує пошук у вибраному дереві.
--- @param name string Назва дерева, створеного через InitTree.
--- @param prefix string Префікс для пошуку.
--- @param limit number|nil Максимальна кількість результатів.
--- @return {Instance} Масив екземплярів Roblox.
function AutocompleteSearchService.Search(name, prefix, limit)
	local tree = Trees[name]
	if not tree then
		return {}
	end
	return tree:Search(prefix, limit)
end

--- @brief Видаляє trie й відключає всі зв'язки.
--- @param name string Назва дерева.
--- @return boolean true, якщо дерево існувало й було видалено.
function AutocompleteSearchService.RemoveTree(name)
	local tree = Trees[name]
	if not tree then
		return false
	end
	for _, c in ipairs(tree.conns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	Trees[name] = nil
	return true
end

return AutocompleteSearchService

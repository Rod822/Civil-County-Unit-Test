--- @class TrieNode
--- @brief Внутрішній вузол префіксного дерева з довільною кількістю дітей.
local Node = {}
Node.__index = Node

export type Node = {
	children: { [string]: Node },
	isEnd: boolean,
}

--- @brief Створює порожній вузол trie.
function Node.new(): Node
	local self = setmetatable({}, Node)
	self.children = {}
	self.isEnd = false
	return self
end

--- @brief Вставляє слово до дерева, створюючи проміжні вузли.
--- @param word string Нормалізоване слово (наприклад, у нижньому регістрі).
function Node:Insert(word: string)
	local node: Node = self
	for i = 1, #word do
		local ch = string.sub(word, i, i)
		if not node.children[ch] then
			node.children[ch] = Node.new()
		end
		node = node.children[ch]
	end
	node.isEnd = true
end

--- @brief Повертає вузол, що відповідає префіксу.
--- @param prefix string Ключ для пошуку.
--- @return TrieNode|nil Вузол кінця префікса або nil.
function Node:Find(prefix: string): Node?
	local node: Node? = self
	for i = 1, #prefix do
		if not node then
			return nil
		end
		node = node.children[string.sub(prefix, i, i)]
	end
	return node
end

local function collect(node: Node?, prefix: string, out: { string }, limit: number?)
	if not node then
		return
	end
	if node.isEnd then
		table.insert(out, prefix)
		if limit and #out >= limit then
			return
		end
	end
	for ch, child in pairs(node.children) do
		if limit and #out >= limit then
			return
		end
		collect(child, prefix .. ch, out, limit)
	end
end

--- @brief Збирає слова, що починаються з prefix, у вказаний масив.
--- @param prefix string Частина слова для з'єднання.
--- @param out table Буфер результатів.
--- @param limit number|nil Максимальна кількість записів.
function Node:Collect(prefix: string, out: { string }, limit: number?)
	collect(self, prefix, out, limit)
end

return Node

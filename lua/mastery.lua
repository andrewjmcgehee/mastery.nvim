local M = {}

M.setup = function()
	local now = os.time()
	local fp = vim.fn.stdpath("data") .. "/mastery"
	local log = io.open(fp, "a")
	if log then
		log:write(now)
	end
end

return M

local M = {}

M.setup = function()
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			local now = os.time()
			local fp = vim.fn.stdpath("data") .. "/mastery.log"
			local log = io.open(fp, "a")
			if log then
				log:write(now, ",")
			end
		end,
	})
	vim.api.nvim_create_autocmd("VimLeave", {
		callback = function()
			local now = os.time()
			local fp = vim.fn.stdpath("data") .. "/mastery.log"
			local log = io.open(fp, "a")
			if log then
				log:write(now, "\n")
			end
		end,
	})
end

return M

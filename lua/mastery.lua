local M = {}

M.setup = function()
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			-- read or create the state file
			local file = io.open(vim.fn.stdpath("data") .. "/mastery.state", "r")
			local offset = 0
			local elapsed = 0
			if not file then
				file = io.open(vim.fn.stdpath("data") .. "/mastery.state", "w")
				if not file then
					vim.notify("Failed to create mastery.state file")
					return
				end
				file:write(offset .. "\n")
				file:write(elapsed .. "\n")
			else
				offset = tonumber(file:read("*1"), 10)
				elapsed = tonumber(file:read("*1"), 10)
			end
			vim.notify(offset .. " " .. elapsed)
			-- log the time
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

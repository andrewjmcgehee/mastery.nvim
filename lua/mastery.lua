local M = {}

local state = {
	enter_ts = -1,
	leave_ts = -1,
}

M.state = state

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
				offset = file:read("*n")
				elapsed = file:read("*n")
			end
			local total_elapsed = offset + elapsed
			vim.notify("Mastery: " .. total_elapsed .. " seconds", vim.log.levels.INFO, {
				title = "Mastery",
			})
			-- log and set the enter time
			local now = os.time()
			M.state.enter_ts = now
			local fp = vim.fn.stdpath("data") .. "/mastery.log"
			local log = io.open(fp, "a")
			if log then
				log:write(now, ",")
			end
		end,
	})
	vim.api.nvim_create_autocmd("BufLeave", {
		callback = function()
			local now = os.time()
			local diff = now - M.state.enter_ts
			print(diff)
			local fp = vim.fn.stdpath("data") .. "/mastery.log"
			local log = io.open(fp, "a")
			if log then
				log:write(now, "\n")
			end
		end,
	})
end

return M

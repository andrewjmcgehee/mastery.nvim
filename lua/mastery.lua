local M = {}

local state = {
	enter_ts = -1,
	leave_ts = -1,
}

M.state = state

M.setup = function()
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			-- log and set the enter time
			local now = os.time()
			M.state.enter_ts = now
			local log_fp = vim.fn.stdpath("data") .. "/mastery.log"
			local log_file = io.open(log_fp, "a")
			if log_file then
				log_file:write(now, ",")
				log_file:close()
			end
		end,
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			-- write time to log
			local now = os.time()
			local log_fp = vim.fn.stdpath("data") .. "/mastery.log"
			local log_file = io.open(log_fp, "a")
			if log_file then
				log_file:write(now, "\n")
				log_file:close()
			end
			-- read or create the state file
			local offset = 0
			local elapsed = 0
			local state_fp = vim.fn.stdpath("data") .. "/mastery.state"
			local state_file = io.open(state_fp, "r")
			if not state_file then
				state_file = io.open(state_fp, "w")
				if not state_file then
					vim.notify("failed to create mastery.state file", vim.log.levels.ERROR, { title = "Mastery" })
					return
				end
				state_file:write(offset .. "\n")
				state_file:write(elapsed .. "\n")
			else
				offset = state_file:read("*n")
				elapsed = state_file:read("*n")
			end
			state_file:close()
			-- calculate diff and update global state file
			local diff = now - M.state.enter_ts
			local total_elapsed = offset + elapsed + diff
			vim.notify(total_elapsed .. "s", vim.log.levels.INFO, { title = "Mastery" })
			-- write new state
			state_file = io.open(state_fp, "w")
			if state_file then
				state_file:write(offset .. "\n")
				state_file:write((elapsed + diff) .. "\n")
			else
				vim.notify("failed to write mastery.state file", vim.log.levels.ERROR, { title = "Mastery" })
			end
		end,
	})
end

return M

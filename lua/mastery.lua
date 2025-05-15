local M = {}

M.session_state = {
	enter_ts = -1,
}

M.log_enter_ts = function()
	-- log and set the enter time
	local now = os.time()
	M.session_state.enter_ts = now
	local log_fp = vim.fn.stdpath("data") .. "/mastery.log"
	local log_file = io.open(log_fp, "a")
	if log_file then
		log_file:write(now, ",")
		log_file:close()
	end
	return now
end

M.log_exit_ts = function()
	local now = os.time()
	local log_fp = vim.fn.stdpath("data") .. "/mastery.log"
	local log_file = io.open(log_fp, "a")
	if log_file then
		log_file:write(now, "\n")
		log_file:close()
	end
	return now
end

M.create_or_read_global_state_file = function()
	-- read or create the state file
	local elapsed = 0
	local state_fp = vim.fn.stdpath("data") .. "/mastery.state"
	local state_file = io.open(state_fp, "r")
	if not state_file then
		state_file = io.open(state_fp, "w")
		if not state_file then
			vim.notify("failed to create mastery.state file", vim.log.levels.ERROR, { title = "Mastery" })
			return
		end
		state_file:write(elapsed .. "\n")
	else
		elapsed = state_file:read("*n")
	end
	state_file:close()
	return {
		elapsed = elapsed,
	}
end

M.update_global_state_file = function(elapsed)
	local new_state_fp = vim.fn.stdpath("data") .. "/mastery.state.new"
	local new_state_file = io.open(new_state_fp, "w")
	if not new_state_file then
		vim.notify("failed to create mastery.state.new file", vim.log.levels.ERROR, { title = "Mastery" })
		return
	end
	new_state_file:write(elapsed)
	new_state_file:close()
	-- move new state file to overwrite old
	local state_fp = vim.fn.stdpath("data") .. "/mastery.state"
	os.remove(state_fp)
	os.rename(new_state_fp, state_fp)
end

M.on_enter = function()
	M.log_enter_ts()
end

M.on_leave = function()
	local now = M.log_exit_ts()
	local diff = now - M.session_state.enter_ts
	local state = M.create_or_read_global_state_file()
	if not state then
		return
	end
	M.update_global_state_file(state.elapsed + diff)
end

M.setup = function()
	vim.api.nvim_create_autocmd("VimEnter", { callback = M.on_enter })
	vim.api.nvim_create_autocmd("VimLeave", { callback = M.on_leave })
	vim.api.nvim_create_user_command("Mastery", function()
		local state = M.create_or_read_global_state_file()
		if not state then
			return
		end
		local diff = os.time() - M.session_state.enter_ts
		local mastery = state.elapsed + diff
		local hours = mastery / 60 / 60
		local percent = (hours / 10000) * 100
		vim.notify(
			"you've achieved "
				.. string.format("%.2f", hours)
				.. " hours ("
				.. string.format("%.2f", percent)
				.. "%) of mastery",
			vim.log.levels.INFO,
			{ title = "Mastery" }
		)
	end, {})
end

return M

local M = {}

M.session_state = {
	enter_ts = -1,
}

M.set_enter_ts = function()
	local now = os.time()
	M.session_state.enter_ts = now
	return now
end

M.log_time_delta = function()
	local now = os.time()
	local log_fp = vim.fn.stdpath("data") .. "/mastery.log"
	local log_file = io.open(log_fp, "a")
	if log_file then
		log_file:write(M.session_state.enter_ts, ",", now, "\n")
		log_file:close()
	end
	return now
end

M.create_or_read_global_init_file = function()
	local init = os.time()
	local init_fp = vim.fn.stdpath("data") .. "/mastery.init"
	local init_file = io.open(init_fp, "r")
	if not init_file then
		init_file = io.open(init_fp, "w")
		if not init_file then
			vim.notify("failed to create mastery.init file", vim.log.levels.ERROR, { title = "Mastery" })
			return
		end
		init_file:write(init .. "\n")
	else
		init = init_file:read("*n")
	end
	init_file:close()
	return {
		initial_timestamp = init,
	}
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
	M.create_or_read_global_init_file()
	M.set_enter_ts()
end

M.on_leave = function()
	local now = M.log_time_delta()
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
		local init = M.create_or_read_global_init_file()
		if not init then
			return
		end
		local state = M.create_or_read_global_state_file()
		if not state then
			return
		end
		local diff = os.time() - M.session_state.enter_ts
		local total = os.time() - init.initial_timestamp
		local total_days = math.floor(total / 60 / 60 / 24)
		local total_days_mod = total_days % 365
		local total_years = math.floor(total_days / 365)
		local mastery = state.elapsed + diff
		local minutes = math.floor(mastery / 60) % 60
		local hours = math.floor(mastery / 60 / 60)
		local percent = (mastery / 60 / 60 / 10000) * 100
		vim.notify(
			"you've achieved "
				.. hours
				.. "h "
				.. minutes
				.. "m "
				.. "("
				.. string.format("%.4f", percent)
				.. "%) of mastery in the past "
				.. total_years
				.. "y "
				.. total_days_mod
				.. "d.\nthat's "
				.. string.format("%.2f", hours / total_days)
				.. "h per day.",
			vim.log.levels.INFO,
			{ title = "Mastery" }
		)
	end, {})
end

return M

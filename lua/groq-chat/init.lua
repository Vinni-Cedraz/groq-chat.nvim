local M = {}

-- Default configuration
local config = {
	api_key = nil, -- Required from user
	model = "gemma2-9b-it",
	window_width = 80,
}

local state = {
	buf = nil,
	win = nil,
	chat_history = {},
}

-- Helper function to make HTTP requests
local function make_request(messages)
	if not config.api_key then
		error("Groq API key not configured. Please set api_key in setup()")
	end

	local curl = require("plenary.curl")
	local response = curl.post("https://api.groq.com/openai/v1/chat/completions", {
		headers = {
			Authorization = "Bearer " .. config.api_key,
			["Content-Type"] = "application/json",
		},
		body = vim.fn.json_encode({
			model = config.model,
			messages = messages,
		}),
	})

	if response.status ~= 200 then
		error("Groq API error: " .. response.body)
	end

	return vim.fn.json_decode(response.body).choices[1].message.content
end

-- Get current buffer content
local function get_current_file_content()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	return table.concat(lines, "\n")
end

-- Create chat window
local function create_chat_window()
	-- Create new buffer
	state.buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(state.buf, "groq-chat")
	vim.bo[state.buf].filetype = "markdown"
	vim.bo[state.buf].syntax = "markdown"
	vim.bo[state.buf].textwidth = 0
	local ok, parser = pcall(vim.treesitter.get_parser, state.buf, "markdown")
	if ok and parser then
		vim.treesitter.start(state.buf, "markdown")
	end

	-- Create split window
	local width = vim.api.nvim_get_option("columns")
	local win_width = config.window_width

	state.win = vim.api.nvim_open_win(state.buf, true, {
		relative = "editor",
		width = win_width,
		height = vim.api.nvim_get_option("lines"),
		col = width - win_width,
		row = 0,
		style = "minimal",
		border = "single",
	})

	-- Set window options
	vim.wo[state.win].wrap = true
	vim.wo[state.win].linebreak = true
	vim.wo[state.win].cursorline = true
	vim.wo[state.win].conceallevel = 2
	vim.wo[state.win].foldlevel = 99

	-- Return to previous window
	vim.cmd("wincmd p")
end

-- Update chat display
local function update_chat_display()
	if state.buf then
		local lines = {}

		-- Only display assistant messages
		for _, msg in ipairs(state.chat_history) do
			if msg.role == "assistant" then
				-- Split content into lines and add them
				for line in msg.content:gmatch("([^\n]*)\n?") do
					if line ~= "" then
						table.insert(lines, line)
					end
				end
				-- Add a blank line between messages
				table.insert(lines, "")
			end
		end
		vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
	end
end

-- Send message to chat
local function send_message(content)
	local messages = {
		{
			role = "system",
			content = "You are a helpful coding assistant. Keep responses focused on the code.",
		},
	}

	-- Add chat history
	for _, msg in ipairs(state.chat_history) do
		table.insert(messages, msg)
	end

	-- Add new user message
	table.insert(messages, { role = "user", content = content })

	-- Get response from Groq
	local response = make_request(messages)

	-- Update chat history
	table.insert(state.chat_history, { role = "user", content = content })
	table.insert(state.chat_history, { role = "assistant", content = response })

	-- Update display
	update_chat_display()
end

-- Initialize chat
local function init_chat()
	if not state.win then
		create_chat_window()
	end

	-- Clear existing chat
	state.chat_history = {}

	-- Send initial message
	local file_content = get_current_file_content()
	send_message("explain this code to me in a single paragraph:\n" .. file_content)
end

function M.setup(user_config)
	-- Merge user config with defaults
	if user_config then
		config = vim.tbl_deep_extend("force", config, user_config)
	end

	-- Validate required config
	if not config.api_key then
		error("Groq API key is required. Please set api_key in setup()")
	end

	-- Create commands
	vim.api.nvim_create_user_command("GroqChat", function()
		init_chat()
	end, {})

	vim.api.nvim_create_user_command("GroqChatSend", function(opts)
		send_message(opts.args)
	end, { nargs = "+" })

	vim.api.nvim_create_user_command("GroqChatClose", function()
		if state.win and vim.api.nvim_win_is_valid(state.win) then
			vim.api.nvim_win_close(state.win, true)
		end
		state.win = nil
		state.buf = nil
	end, {})
end

return M

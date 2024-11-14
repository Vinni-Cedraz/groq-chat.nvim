# groq-chat.nvim

A Neovim plugin that integrates Groq's AI models directly into your editor for code assistance and chat interactions.

## Features

- Interactive chat interface in a vertical split window
- Code analysis and explanation capabilities
- Persistent chat history during session
- Easy-to-use commands for interaction
- Built-in error handling for API requests

## Prerequisites

- Neovim >= 0.5.0
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- Groq API key

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
    'Vinni-Cedraz/groq-chat.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    config = function()
        require('groq-chat').setup()
    end
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {
    'Vinni-Cedraz/groq-chat.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('groq-chat').setup()
    end
}
```

## Configuration

Add your Groq API key and customize settings:

```lua
require('groq-chat').setup({
    api_key = "your-groq-api-key", -- Required
    model = "gemma2-9b-it",        -- Optional, default: "gemma2-9b-it"
    window_width = 80,             -- Optional, default: 80
})
```

## Usage

Commands:
- `:GroqChat` - Opens the chat window and analyzes current file
- `:GroqChatSend <message>` - Sends a message to the chat
- `:GroqChatClose` - Closes the chat window

## Example

1. Open a file you want to analyze
2. Run `:GroqChat` to start a chat session
3. Use `:GroqChatSend` to ask questions about the code
4. Close the chat with `:GroqChatClose` when done

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

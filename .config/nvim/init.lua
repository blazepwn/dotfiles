-- Use the terminal background, including Kitty's transparency.
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.number = true

local function transparent_background()
  for _, group in ipairs({
    "Normal", "NormalNC", "NormalFloat", "FloatBorder", "FloatTitle",
    "SignColumn", "FoldColumn", "EndOfBuffer", "LineNr", "CursorLineNr",
    "StatusLine", "StatusLineNC", "WinSeparator", "VertSplit",
  }) do
    vim.cmd("highlight " .. group .. " guibg=NONE ctermbg=NONE")
  end
  -- Older Neovim themes invert the status line, which would paint a background.
  vim.cmd("highlight StatusLine gui=NONE cterm=NONE")
  vim.cmd("highlight StatusLineNC gui=NONE cterm=NONE")
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("TransparentBackground", { clear = true }),
  callback = transparent_background,
})
transparent_background()

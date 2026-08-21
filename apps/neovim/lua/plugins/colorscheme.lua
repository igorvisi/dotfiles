-- onedark aligned with Zed's "One Dark Pro" (apps/zed/settings.json:
-- panel backgrounds #23272E / #2C313A, italics on keyword/comment/type/boolean).
-- code_style has no "type"/"boolean" keys, so those are italicized via highlights.
return {
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000, -- loaded before other plugins to avoid a colorscheme flash
    config = function()
      require("onedark").setup({
        -- "dark" matches the #282C34 background of One Dark Pro
        style = "dark",
        code_style = {
          comments = "italic",
          keywords = "italic",
          functions = "none",
          strings = "none",
          variables = "none",
        },
        -- mirrors Zed's theme_overrides
        highlights = {
          -- types/booleans italic (Zed: syntax.type, syntax.boolean)
          Type = { fmt = "italic" },
          Structure = { fmt = "italic" },
          Boolean = { fmt = "italic" },
          TSBoolean = { fmt = "italic" },
          TSConstant = { fmt = "italic" },
          TSType = { fmt = "italic" },
          -- panel/border backgrounds (Zed: border/panel/status_bar #23272E,
          -- active tab #2C313A)
          FloatBorder = { bg = "#23272E", fg = "#23272E" },
          NormalFloat = { bg = "#23272E" },
          StatusLine = { bg = "#23272E" },
          TabLine = { bg = "#23272E" },
          TabLineSel = { bg = "#2C313A" },
        },
      })
      vim.cmd.colorscheme("onedark")
    end,
  },
}

-- Thème onedark, aligné sur le thème "One Dark Pro" de Zed
-- (apps/zed/settings.json : fonds panneaux #23272E / #2C313A,
-- italiques sur keyword / comment / type / boolean).
--
-- onedark.nvim : code_style (comment|keyword|... au pluriel) et highlights
-- (overrides de groupes) — pas de clés "type"/"boolean" dans code_style,
-- donc les types et booléens sont mis en italique via highlights.
return {
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000, -- chargé avant les autres plugins pour éviter le flash
    config = function()
      require("onedark").setup({
        -- "dark" correspond au fond #282C34 de One Dark Pro
        style = "dark",
        code_style = {
          comments = "italic",
          keywords = "italic",
          functions = "none",
          strings = "none",
          variables = "none",
        },
        -- aligné sur les theme_overrides de Zed
        highlights = {
          -- types / booléens en italique (Zed: syntax.type, syntax.boolean)
          Type = { fmt = "italic" },
          Structure = { fmt = "italic" },
          Boolean = { fmt = "italic" },
          TSBoolean = { fmt = "italic" },
          TSConstant = { fmt = "italic" },
          TSType = { fmt = "italic" },
          -- fonds panneaux/border (Zed: border/panel/status_bar #23272E,
          -- onglet actif #2C313A)
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

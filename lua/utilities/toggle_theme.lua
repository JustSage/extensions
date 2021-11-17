local function toggle_theme(themes)
   local current_theme = vim.g.default_theme
   for _, name in ipairs(themes) do
      if name ~= current_theme then
         if require("utilities").reload_theme(name) then
            -- open a buffer and close it to reload the statusline
            vim.cmd "new|bwipeout"
            vim.g.default_theme = name
            if require("utilities").change_theme(vim.g.theme, name) then
               vim.g.default_theme = name
            end
         end
      end
   end
end

return toggle_theme

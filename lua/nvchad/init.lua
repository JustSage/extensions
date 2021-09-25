local M = {}

-- Edit user config file, based on the assumption it exists in the config as
-- theme = "theme name"
-- 1st arg as current theme, 2nd as new theme
M.change_theme = require "nvchad.change_theme"

-- clear command line from lua
M.clear_cmdline = function()
   vim.defer_fn(function()
      vim.cmd "echo"
   end, 0)
end

-- wrapper to use vim.api.nvim_echo
-- table of {string, highlight}
-- e.g echo({{"Hello", "Title"}, {"World"}})
M.echo = function(opts)
   if opts == nil or type(opts) ~= "table" then
      return
   end
   vim.api.nvim_echo(opts, false, {})
end

-- Ensure that chadrc exists, if it doesn't then copy the example chadrc
M.ensure_chadrc_exists = function()
   local config_path = vim.fn.stdpath "config/lua/custom/"
   local config_name = vim.g.nvchad_user_config or "chadrc"
   local config_file = config_path .. config_name .. ".lua"
   local example_config_file = config_path .. "example_chadrc" .. ".lua"

   if not vim.fn.filereadable(config_file) then
      local cp_result = vim.fn.system("cp "
         .. example_config_file
         .. config_file
      )

      if vim.v.shell_error == 0 then
         print("NvChad: 'custom/chadrc' was not found, so copied it 'custom/example_chadrc.lua' -> 'custom/chadrc.lua'")
      else
         print("NvChad: 'custom/chadrc' was not found & there was an error copying 'custom/example_chadrc.lua' -> 'custom/chadrc.lua'")
      end
    else
       print("NvChad: there is no 'custom/chadrc.lua' file, and no 'custom/example_chadrc.lua' file to copy it from")
    end
end

-- 1st arg - r or w
-- 2nd arg - file path
-- 3rd arg - content if 1st arg is w
-- return file data on read, nothing on write
M.file = function(mode, filepath, content)
   local data
   local fd = assert(vim.loop.fs_open(filepath, mode, 438))
   local stat = assert(vim.loop.fs_fstat(fd))
   if stat.type ~= "file" then
      data = false
   else
      if mode == "r" then
         data = assert(vim.loop.fs_read(fd, stat.size, 0))
      else
         assert(vim.loop.fs_write(fd, content, 0))
         data = true
      end
   end
   assert(vim.loop.fs_close(fd))
   return data
end

-- return a table of available themes
M.list_themes = function(return_type)
   local themes = {}
   -- folder where theme files are stored
   local themes_folder = vim.fn.stdpath "data" .. "/site/pack/packer/opt/nvim-base16.lua/lua/hl_themes"
   -- list all the contents of the folder and filter out files with .lua extension, then append to themes table
   local fd = vim.loop.fs_scandir(themes_folder)
   if fd then
      while true do
         local name, typ = vim.loop.fs_scandir_next(fd)
         if name == nil then
            break
         end
         if typ ~= "directory" and string.find(name, ".lua$") then
            -- return the table values as keys if specified
            if return_type == "keys_as_value" then
               themes[vim.fn.fnamemodify(name, ":r")] = true
            else
               table.insert(themes, vim.fn.fnamemodify(name, ":r"))
            end
         end
      end
   end
   return themes
end

-- reload whole config without exiting nvim
M.reload_config = require "nvchad.reload_config"

-- reload a plugin ( will try to load even if not loaded)
-- can take a string or list ( table )
-- return true or false
M.reload_plugin = function(plugins)
   local status = true
   local function _reload_plugin(plugin)
      local loaded = package.loaded[plugin]
      if loaded then
         package.loaded[plugin] = nil
      end
      local ok, err = pcall(require, plugin)
      if not ok then
         print("Error: Cannot load " .. plugin .. " plugin!\n" .. err .. "\n")
         status = false
      end
   end

   if type(plugins) == "string" then
      _reload_plugin(plugins)
   elseif type(plugins) == "table" then
      for _, plugin in ipairs(plugins) do
         _reload_plugin(plugin)
      end
   end
   return status
end

-- reload themes without restarting vim
-- if no theme name given then reload the current theme
M.reload_theme = require "nvchad.reload_theme"

-- toggle between 2 themes
-- argument should be a table with 2 theme names
M.toggle_theme = require "nvchad.toggle_theme"

-- update nvchad
M.update_nvchad = require "nvchad.update_nvchad"

return M

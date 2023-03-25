local on_attach = require("lsp").on_attach

local root_dir = require("jdtls.setup").find_root({ "packageInfo" }, "Config")
local home = os.getenv("HOME")
local eclipse_workspace = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

--#region
-- Root dir /Volumes/workplace/AndonCord
-- Home /Users/rajivbh
-- Eclipse ws /Users/rajivbh/.local/share/eclipse/AndonCord
--#endregion

local ws_folders_jdtls = {}
if root_dir then
  local file = io.open(root_dir .. "/.bemol/ws_root_folders")
  if file then
    for line in file:lines() do
      table.insert(ws_folders_jdtls, "file://" .. line)
    end
    file:close()
  end
end

-- Only supporting linux/mac systems
local config_os = "/" .. (vim.fn.has("macunix") and "config_mac" or "config_linux")
local jdtls_path = home .. "/.local/share/nvim/mason/packages/jdtls/" -- TODO
local path_to_java_17 = "/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/java"
local path_to_eclipse_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

local config = {
  on_attach = on_attach,
  -- See https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {
    path_to_java_17,

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    -- Lombok Setup
    -- "-javaagent:" .. home .. "/brazil-pkg-cache/packages/Lombok/Lombok-1.16.x.400639.0/AL2_x86_64/DEV.STD.PTHREAD/build/lib/lombok.jar",
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',


    '-jar', path_to_eclipse_jar,

    '-configuration', jdtls_path .. config_os,
    --                ^^^^^^^^^^    ^^^^^^^^^
    --                Must point    Change to one of `linux`, `win` or `mac`
    --                to the        Depending on your system.
    --                eclipse.jdt.ls 
    --                installation

    -- -- See `data directory configuration` section in the README
    "-data",
    eclipse_workspace,
  },
  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
    }
  },

  init_options = {
    workspaceFolders = ws_folders_jdtls,
  },
}

require("jdtls").start_or_attach(config)

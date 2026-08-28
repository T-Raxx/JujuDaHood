-- JujuDaHood launcher: instala addons a la carpeta nativa + carga el juju main.
-- Un solo loadstring. Correr en Da Hood real (place 2788229376).
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/launch.lua"))()

local RAW = "https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main"

-- 1) instalar nuestros addons a "juju recode/addons/" (nativo)
local ok1, e1 = pcall(function()
    loadstring(game:HttpGet(RAW.."/install.lua"))()
end)
if not ok1 then warn("[JujuDaHood] install falló: "..tostring(e1)) end

-- 2) cargar el juju main (CopiesBest, compile-verified)
loadstring(game:HttpGet(RAW.."/dist/juju-main.lua"))()

-- 3) in-game: misc > addons > load "feature-exposer"

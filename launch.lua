-- JujuDaHood launcher: carga juju reborn (base activa) + instala nuestros addons.
-- Da Hood real (place 2788229376).
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/launch.lua"))()

-- 1) BASE = juju reborn (tungtungsahurbek-lang, fork open-source activo:
--    fire anti-detección con packet-mirroring + jitter, AC-killer, resolver/backtrack).
--    Mismo contrato getgenv().juju + misma carpeta "juju recode/addons/" que nuestros addons.
local ok1, e1 = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/tungtungsahurbek-lang/juju/main/reborn.lua"))()
end)
if not ok1 then warn("[JujuDaHood] reborn falló: "..tostring(e1)) end

-- 2) instalar nuestros addons a "juju recode/addons/" (nativo)
local ok2, e2 = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/install.lua"))()
end)
if not ok2 then warn("[JujuDaHood] install falló: "..tostring(e2)) end

-- 3) in-game: misc > addons > load "feature-exposer"

-- Fallback offline (si reborn cae): nuestro CopiesBest fixeado en dist/juju-main.lua
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/dist/juju-main.lua"))()

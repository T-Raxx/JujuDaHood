-- JujuDaHood addon installer (nativo): syncea nuestros addons a la carpeta de juju.
-- Escribe en "juju recode/addons/" (Potassium: AppData\Local\Potassium\workspace\juju recode\addons).
-- Correr una vez; después cargá cada addon desde el tab misc > addons de juju.
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/install.lua"))()

local RAW = "https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/addons/"

-- Manifiesto (build.sh lo regenera desde addons/*.luau)
local ADDONS = {
    "feature-exposer",
}

local DIR = "juju recode/addons"
if not isfolder("juju recode") then makefolder("juju recode") end
if not isfolder(DIR) then makefolder(DIR) end

local ok_n, fail_n = 0, 0
for _, name in ipairs(ADDONS) do
    local ok, src = pcall(game.HttpGet, game, RAW..name..".luau")
    if ok and type(src) == "string" and #src > 0 then
        writefile(DIR.."/"..name..".luau", src)
        ok_n = ok_n + 1
        print("[JujuDaHood] instalado: "..name)
    else
        fail_n = fail_n + 1
        warn("[JujuDaHood] fetch fail: "..name.." ("..tostring(src)..")")
    end
end

print(("[JujuDaHood] %d addon(s) en '%s' — %d fallados. Cargalos desde misc > addons.")
    :format(ok_n, DIR, fail_n))

-- JujuDaHood loader (path C): inyecta nuestros addons en un juju ya corriendo.
-- Correr DESPUÉS de que tu juju cargue (setea getgenv().juju), en Da Hood real.
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/loader.lua"))()

local RAW = "https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main"
local BRANCH_RAW = RAW  -- cambiar a .../dev para probar WIP

-- Manifiesto de addons (build.sh lo regenera desde addons/*.luau)
local ADDONS = {
    "feature-exposer",
}

local function wait_for_juju(timeout)
    local t = os.clock()
    while not getgenv().juju and (os.clock() - t) < (timeout or 20) do
        task.wait(0.1)
    end
    return getgenv().juju
end

local juju = wait_for_juju(20)
if not juju then
    warn("[JujuDaHood] getgenv().juju no encontrado — cargá juju primero (Da Hood real). Abortando.")
    return
end

local loaded, failed = {}, {}
for _, name in ipairs(ADDONS) do
    local ok, src = pcall(game.HttpGet, game, BRANCH_RAW.."/addons/"..name..".luau")
    if not ok then
        failed[#failed+1] = name.." (fetch)"; warn("[JujuDaHood] fetch fail "..name..": "..tostring(src))
    else
        local f, err = loadstring(src, "@"..name)
        if not f then
            failed[#failed+1] = name.." (compile)"; warn("[JujuDaHood] compile fail "..name..": "..tostring(err))
        else
            local ran, rerr = pcall(f)
            if not ran then
                failed[#failed+1] = name.." (runtime)"; warn("[JujuDaHood] runtime fail "..name..": "..tostring(rerr))
            else
                loaded[#loaded+1] = name; print("[JujuDaHood] addon cargado: "..name)
            end
        end
    end
end

print(("[JujuDaHood] listo — %d cargados, %d fallados"):format(#loaded, #failed))

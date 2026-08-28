-- feature-exposer: revela TODAS las features de juju (incl. combate/detectadas —
-- el usuario maneja AC después con framework decompilado + saveinstance).
-- Refleja el árbol `menu` desde un upvalue del API juju y set_visible(true) en todo.
-- Headless: no crea UI propia; revela in-place los widgets reales (con sus settings).

local juju = getgenv and getgenv().juju
if not juju then
    warn("[exposer] getgenv().juju no encontrado — cargá juju primero (Da Hood real).")
    return
end

-- reflection helpers (executor-agnostic)
local _getupvalues = getupvalues or (debug and debug.getupvalues)

local function find_menu()
    if not _getupvalues then return nil end
    local candidates = { juju.find_element, juju.set_flag, juju.get_flags, juju.create_element, juju.get_signals }
    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then
            local ok, ups = pcall(_getupvalues, fn)
            if ok and type(ups) == "table" then
                for _, v in pairs(ups) do
                    if type(v) == "table" and rawget(v, "groups") then
                        return v
                    end
                end
            end
        end
    end
    return nil
end

local menu = find_menu()
if not (menu and menu.groups) then
    warn("[exposer] no se pudo reflejar el árbol menu (executor sin getupvalues o estructura cambiada). Nada revelado.")
    return
end

local revealed, groups_shown, errors = 0, 0, 0

-- 1) mostrar grupos ocultos (ej. base hace groups['addons']:hide())
for _, group in pairs(menu.groups) do
    pcall(function()
        if type(group) == "table" and group.show then
            group:show(); groups_shown = groups_shown + 1
        end
    end)
    -- 2) revelar cada elemento de cada sección de cada tab
    for _, tab in pairs(rawget(group, "tabs") or {}) do
        for _, section in pairs(rawget(tab, "sections") or {}) do
            for _, element in pairs(rawget(section, "elements") or {}) do
                local ok = pcall(function()
                    if type(element) == "table" and element.set_visible then
                        element:set_visible(true); revealed = revealed + 1
                    end
                end)
                if not ok then errors = errors + 1 end
            end
        end
    end
end

-- 3) elementos en menu.settings (find_element también los busca)
if rawget(menu, "settings") then
    for _, settings in pairs(menu.settings) do
        for _, element in pairs(rawget(settings, "elements") or {}) do
            pcall(function()
                if type(element) == "table" and element.set_visible then
                    element:set_visible(true); revealed = revealed + 1
                end
            end)
        end
    end
end

print(("[exposer] reveal-all: %d elementos revelados, %d grupos mostrados, %d errores")
    :format(revealed, groups_shown, errors))

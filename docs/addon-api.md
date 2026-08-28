# juju Addon API — contrato

Extraído de `reference/juju-deobf.lua` (CopiesBest deobf). El API se expone como **`getgenv().juju`** (asignado en L26685 del deobf; construido L26044+). Los addons leen el global `juju`.

## Modelo de carga

**Nativo (UI addons):** `menu.load_addon(name)` lee `juju recode/addons/<name>.luau` (workspace), `loadstring`, corre en coroutine con `getfenv(data).__IDENTIFIER = name`, registra en `addon_data[name]`. `menu` NO está expuesto a addons → sólo se dispara desde el tab addons (misc→addons) o escribiendo el archivo y cargando manual.

**Headless (nuestro loader.lua, path C):** correr el addon como `loadstring` plano DESPUÉS de juju. Usa helpers de `getgenv().juju` (los que NO dependen de `__IDENTIFIER`) + APIs crudas del executor (hookmetamethod, RunService, Drawing). No necesita `load_addon`.

- **Funcionan headless** (sin `__IDENTIFIER`): `find_element`, `set_flag`, `get_flag`, `get_flags`, `get_ragebot_target(s)`, `is_player_*`, `is_auto_stomping`, `purchase_item`, `get/set_server_cframe`, `reload_gun`, `get_ping`, etc. (búsquedas/estado global).
- **Necesitan `__IDENTIFIER` + `addon_data`** (sólo vía `load_addon`): `create_tab`, `create_section`, `create_element`, `create_connection`, `on_unload`, `set_tab_text`. Para UI propia sin el flow nativo → usar Drawing/keybinds propios, o writefile+load manual.

## API surface (`getgenv().juju`)

| Función | Firma | Nota |
|---|---|---|
| `find_element` | `(parent_section, name) -> element` | Busca por nombre de sección+elemento (lower). Bloquea "config"/"unload". Headless ✅ |
| `set_flag` / `get_flag` / `get_flags` | `(flag, value)` / `(flag)` / `()` | Estado de toggles/sliders por flag. Headless ✅ |
| `get_signal` / `get_signals` | `(signal)` / `()` | Señales internas juju |
| `create_connection` | `(signal, callback) -> conn` | Tracked por addon. **Requiere __IDENTIFIER** |
| `create_tab` / `create_section` / `create_element` | `(func)` / `(name,side,size,offset)` / `(section,info,elements)` | UI del addon. **Requiere __IDENTIFIER** |
| `set_tab_text` / `on_unload` | `(text)` / `(func)` | **Requiere __IDENTIFIER** |
| `add/remove_ragebot_target` | `(player)` | Manipula lista de targets |
| `get_ragebot_target(s)` | `()` | Target(s) actual(es). Headless ✅ |
| `set_ragebot_target` | `(player, message)` | |
| `get/set_ragebot_aim_position` | `()` / `(position)` | |
| `set_legitbot_target` | `(player, message)` | |
| `is_player_knocked` / `is_player_dead` / `is_player_invulnerable` | `(player) -> bool` | Headless ✅ |
| `get/set_player_status` | `(player)` / `(player, status)` | Wanted/status |
| `is_in_void` / `is_auto_stomping` / `is_purchasing` | `() -> bool` | Estado local |
| `get/set_server_cframe` / `get_client_cframe` | `()` / `(cf)` / `()` | **Pos spoof server-side** |
| `purchase_item` | `(item, ammo)` | Compra arma/ammo/armor |
| `reload_gun` | `()` | |
| `get_ping` / `get_active_keybinds` | `()` | |

## Métodos de elemento (de `find_element`/`create_element`)

`:set_toggle(bool)`, `:set_slider(n)`, `:set_dropdown({...})`, `:set_textbox(s)`, `:set_colorpicker(c)`, `:set_key(k)`, `:set_visible(bool)`, `:set_options({...})`. Señales: `["on_clicked"]`, `["on_toggle_change"]`, `["on_dropdown_change"]`, `["on_slider_change"]`, `["on_color_change"]`, `["on_key_change"]`.

## Ejemplo (headless, patrón ragebot addon leak)

```lua
local juju = getgenv().juju
local autofire = juju.find_element("general", "auto fire")   -- headless ok
local followtarget = juju.find_element("utility", "follow target")
-- togglear feature existente:
autofire:set_toggle(true)
-- leer estado:
local target = juju.get_ragebot_target()
if target and not juju.is_player_dead(target) then ... end
```

## Constraints

- Combate (autofire/silent aim internos de juju) **DETECTADO** en Da Hood real → NO construir sobre esos vectores.
- Da Hood-específico: juju aborta en L17 si no hay `ReplicatedStorage.MainEvent` (10s) → `getgenv().juju` NUNCA se setea en clones (Da Strike) ni baseplate. Verificación de addons requiere Da Hood real (aged alt 14+ días).

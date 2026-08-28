# JujuDaHood

Rama mantenida de juju.lol para **Da Hood original** (place 2788229376). **Arquitectura addon** (path C): no reescribimos el monolito juju — corremos el juju runnable del usuario y le inyectamos features como **addons** vía `getgenv().juju`.

## Por qué addons (no fork del monolito)

El leak deobfuscado (LuraphV14.7) es la copia más completa + el mejor AC-killer público, PERO **no compila** en executor: choca el límite Luau de 200 locals/función, pervasivo (medido: liberar 7 locals movió el error 48 líneas). Remediarlo = slog riesgoso (bug silencioso local→global) y no-verificable sin runtime. → **Deobf = referencia de lectura; features = addons.**

## Estructura

```
reference/juju-deobf.lua   CopiesBest deobf (27156L) — REFERENCIA, no se corre. Mejor AC-killer + spec del addon API.
docs/addon-api.md          contrato getgenv().juju (API surface, __IDENTIFIER, headless vs UI)
addons/*.luau              nuestros addons
loader.lua                 path C: espera getgenv().juju e inyecta addons
build.sh                   regenera el manifiesto ADDONS de loader.lua desde addons/
assets/                    deps vendorizadas de alex541-juju/juju (por si se hostea juju runnable)
```

## Uso

**Todo en uno** (Da Hood real, place 2788229376):
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/launch.lua"))()
```
Instala addons a `juju recode/addons/` + carga el juju main. Después: misc > addons > load "feature-exposer".

**Separado:**
```lua
-- juju main (CopiesBest, compile-verified OK)
loadstring(game:HttpGet("https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/dist/juju-main.lua"))()
-- instalar addons a la carpeta nativa (Potassium: AppData\Local\Potassium\workspace\juju recode\addons)
loadstring(game:HttpGet("https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/install.lua"))()
```

**Loader HttpGet alternativo** (inyecta addons vía getgenv().juju sin carpeta nativa):
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/loader.lua"))()
```

## juju main runnable

`dist/juju-main.lua` = CopiesBest (mejor AC-killer + más completo) con el fix del límite Luau 200-local: 3 wraps `do..end` (chunk menú) + 3 bloques extraídos a IIFE `local function _block_esp/_block_ragebot/_block_aim() ... end _f()` (cada uno su propio register-file de 200; baseline pasa a upvalues). Compile-verified OK en executor. Fuente editable = `reference/juju-deobf.lua`; `build.sh` copia a `dist/`. **Runtime NO verificado** (CopiesBest aborta en clones sin MainEvent → necesita Da Hood real; transformación behavior-preserving por construcción).

## Addon API (resumen)

`getgenv().juju` expone: `find_element`, `set/get_flag`, `create_tab/section/element`, `create_connection`, `on_unload`, `get/set_ragebot_target(s)`, `is_player_knocked/dead/invulnerable`, `is_auto_stomping`, `purchase_item`, `reload_gun`, **`get/set_server_cframe`** (pos spoof), `get/set_player_status`, etc. Detalle + qué funciona headless en `docs/addon-api.md`.

## Roadmap addons

- **SP1 — ac-hardening** (defensivo primero): addon headless que instala los 2 vectores que al AC-killer base le faltan — `getsenv(Animate).checkingSPEED` source-kill + `__newindex` block del reset ws/jp del juego.
- **SP2 — utility**:
  - **anti-perfect-weld / anti-connection-exploit** (net-new, ausente en base): defensa HvH contra weld/fling de otros exploiters.
  - **surface autostomp / rapidfire**: presentes en base (stripeados en builds defaced) → togglear vía `find_element` o reimplementar headless si el runtime no los tiene.

## Constraints

- Combate interno de juju (**autofire / silent aim**) **DETECTADO** en Da Hood real → NO desarrollar sobre esos vectores.
- Newest juju paid = LuraphV15 fanmade + luarmor (no deobfuscable) → no hay source más nuevo; base de referencia = V14.7.
- **Verificación live bloqueada**: juju aborta sin `MainEvent` (clones/baseplate) → `getgenv().juju` sólo existe en Da Hood real, que requiere alt 14+ días. Addons se escriben code-complete; live-fire diferido.

## Nota AC-killer (referencia)

`reference/juju-deobf.lua` = única copia pública con las 3 capas (LogService `MessageOut` nuke + `__namecall` block de **13 opcodes** `CHECKER/CHECKER_1/CHECKER_4/TeleportDetect/OneMoreTime/GUI_CHECK/checkingSPEED/BANREMOTE/KICKREMOTE/BR_KICKPC/BR_KICKMOBILE/PERMAIDBAN/INVISHIT` + getreg closure-nuke). Todas las demás copias GitHub = 11 opcodes, namecall block simple.

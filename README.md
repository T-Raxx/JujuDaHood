# JujuDaHood

Rama mantenida de juju.lol para **Da Hood original** (place 2788229376). Base = mejor AC-killer disponible públicamente (leak deobfuscado LuraphV14.7). Desarrollo forward: mantener AC-killer + añadir/restaurar utility. Combate (autofire/silent aim internos) **detectado** por el AC/framework nuevo → NO se desarrolla sobre esos vectores.

## Estructura

```
src/juju.lua          base (27156L, CopiesBest) — mejor AC-killer, LPH macros passthrough (corre standalone)
assets/               deps vendorizadas de alex541-juju/juju (api.lua = Drawing lib, sonidos, imágenes, rbxm, themes)
dist/JujuDaHood.lua   bundle (SP0: == src; SP1/SP2 concatenará módulos)
build.sh              bundler
docs/                 specs/notas
```

## Loader (una vez pusheado a GitHub público)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/T-Raxx/JujuDaHood/main/dist/JujuDaHood.lua"))()
```

> **RAW_BASE = `T-Raxx/JujuDaHood`** — si tu usuario/repo GitHub es otro, cambiá las URLs en `src/juju.lua` (32 refs `raw.githubusercontent.com/T-Raxx/JujuDaHood/main/assets/`) y re-buildeá.

## AC-killer (base) — 3 capas

1. **LogService nuke** — `:Disable()` conexiones `MessageOut` (AC lee errores consola), refresh 5s.
2. **`__namecall` hook** — bloquea 13 opcodes AC en `MainEvent:FireServer(<flag>)`: `CHECKER, CHECKER_1, CHECKER_4, TeleportDetect, OneMoreTime, GUI_CHECK, checkingSPEED, BANREMOTE, KICKREMOTE, BR_KICKPC, BR_KICKMOBILE, PERMAIDBAN, INVISHIT`. Bloquea `Kick` foráneo + neutraliza `crash`.
3. **getreg bypass** — mata closures conexión AC (heurística `source` 1 punto + `getupvalues(v)[2] ~= 26`), hook `signal.__index`→conexiones falsas, null `GetFocusedTextBox`.

Es la única versión pública con las 3 capas + los 13 opcodes (todas las demás copias = 11 opcodes, solo namecall block simple).

## Roadmap

- **SP0** — scaffold + base runnable + deps vendorizadas ✅ (local; falta push + live load-verify)
- **SP1** — AC-killer maintenance: graftar 2 vectores (`getsenv(Animate).checkingSPEED` source-kill + `__newindex` block del reset ws/jp del juego), audit opcodes, resiliencia.
- **SP2** — Utility restoration: surfacing de features ya presentes en base (Autostomp ✅, Rapidfire ✅ — stripeadas en el build compilado) + **net-new: anti perfect weld / anti connection exploit / anti-fling** (ausentes en base).

## Deps runtime

- `assets/api.lua` (= `customapi.lua`, idénticos) — **librería Drawing/env custom** (render ESP/HUD cross-executor). `loadstring`'d → var `drawing`. NO es auth/keysystem.
- `GetObjects(rbxassetid://...)` ×9 — meshes/particles Roblox catálogo (no vendorizados, quedan en Roblox).
- Cache local runtime: el script hace `isfile("juju recode/assets/X") ? readfile : HttpGet+writefile`.

## Notas

- Testing live en **Da Hood real** bloqueado: requiere alt 14+ días. Copia Da Hood sirve para load/UI verify (disparo serverside, opcodes pueden diferir → AC-killer no engancha full).
- Newest juju paid = LuraphV15 fanmade + luarmor (no deobfuscable) → no hay source más nuevo; desarrollamos desde esta base V14.7.

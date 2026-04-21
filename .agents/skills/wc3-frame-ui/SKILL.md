---
name: wc3-frame-ui
description: Build Warcraft 3 Reforged custom UI (HUD, buff bars, portraits, tooltips, custom buttons) using the Blz Frame API in Lua/JASS. Use when working with BlzCreateFrame, BlzCreateFrameByType, BlzFrameSet*, FDF/TOC files, ORIGIN_FRAME_*, frame events, or any custom in-game HUD work.
---

# Warcraft 3 Frame UI — best practices (Reforged, patch ≥1.32)

Distilled from Tasyen's "The Big UI-Frame Tutorial".

## 1. Three creation natives — pick the right one

| Native | Needs FDF? | Use for |
|---|---|---|
| `BlzCreateFrame(name, parent, prio, ctx)` | **Yes** — `name` must be a MainFrame in a loaded FDF | Templated frames (`"ScriptDialogButton"`, `"EscMenuBackdrop"`, `"QuestButtonBaseTemplate"`, …) |
| `BlzCreateSimpleFrame(name, parent, ctx)` | **Yes** | SimpleFrame-family templates only |
| `BlzCreateFrameByType(type, name, parent, inherits, ctx)` | **No** | Anything you can build from a raw type (`"BACKDROP"`, `"TEXT"`, `"BUTTON"`, `"GLUETEXTBUTTON"`, `"FRAME"`, `"STATUSBAR"`, …). `inherits` may be empty `""` or a loaded template name. |

**Rule of thumb:** if you don't truly need the FDF, prefer `BlzCreateFrameByType`. It can never silently fail because of a missing/mis-imported TOC.

If you *do* use a custom TOC/FDF, after import the toc path passed to `BlzLoadTOCFile("war3mapImported\\X.toc")` must match exactly, the TOC needs a trailing empty line, and the FDF must be packed into the MPQ. A failed load returns silently and every subsequent `BlzCreateFrame(<name>, …)` returns a broken handle — frames just won't appear.

## 2. Mouse events — what fires on what

`BlzTriggerRegisterFrameEvent` only delivers events for the right frame type. Most importantly:

| Type | Fires |
|---|---|
| `BACKDROP`, `TEXT`, `SPRITE`, `MODEL`, `FRAME` | **Nothing.** No hover, no click. |
| `BUTTON` | `CONTROL_CLICK`, `MOUSE_ENTER`, `MOUSE_LEAVE`, `MOUSE_UP`, `MOUSE_WHEEL` |
| `GLUEBUTTON`, `GLUETEXTBUTTON` | same as BUTTON, plus click-sound |
| `CHECKBOX`, `EDITBOX`, `SLIDER`, `POPUPMENU`, `DIALOG` | their own events |

Consequence: **never put `FRAMEEVENT_MOUSE_ENTER/LEAVE` on a `BACKDROP`** — it will never fire. For a clickable/hoverable icon, use a `BUTTON` (often inheriting `"IconButtonTemplate"` or `"ScoreScreenTabButtonTemplate"`) and put a `BACKDROP` child on top of it via `BlzFrameSetAllPoints(icon, button)`.

## 3. Tooltips — the right way

Two equivalent ways to show a hover-tooltip; both rely on the engine, not on manual mouse-event handling:

```lua
-- Plain text tooltip
local btn = BlzCreateFrameByType("BUTTON", "MyBtn", parent, "IconButtonTemplate", 0)
local icon = BlzCreateFrameByType("BACKDROP", "MyBtnIcon", btn, "", 0)
BlzFrameSetAllPoints(icon, btn)

local tip = BlzCreateFrameByType("TEXT", "MyBtnTip", btn, "", 0)
BlzFrameSetTooltip(btn, tip)            -- engine now shows/hides `tip` automatically
BlzFrameSetEnable(tip, false)           -- prevent text from grabbing the mouse
BlzFrameSetPoint(tip, FRAMEPOINT_BOTTOM, btn, FRAMEPOINT_TOP, 0, 0.005)
BlzFrameSetText(tip, "Hello")
```

For a boxed tooltip, make a `BACKDROP` parent (e.g. `BlzCreateFrame("QuestButtonBaseTemplate", …)`) and a `TEXT` child anchored inside it; pass the **backdrop** to `BlzFrameSetTooltip` — its child text inherits visibility.

Updating the text later is fine: just `BlzFrameSetText(tip, newString)` whenever the underlying data changes.

Caveats from the tutorial:
- Calling `BlzFrameSetTooltip(btn, sameTip)` twice with the same combination crashes on hover.
- Cannot undo: there is no `BlzFrameClearTooltip`. To "remove", point the button at an empty/hidden tooltip.
- A non-Simple tooltip frame becomes a child of the button, so a tooltip placed at the right edge of the screen may be clamped to 4:3. Wrap it in an empty `FRAME` parent if you need it to escape 4:3.
- Text gets bold/garbled if one tooltip frame is shared by many buttons; give each button its own.

## 4. Multiplayer / desync safety

`BlzCreateFrame*`, `BlzGetOriginFrame`, `BlzGetFrameByName`, `BlzFrameGetParent`, `BlzFrameGetChild` all assign a handle id. **Never call them inside a `GetLocalPlayer()` block.** Per-player UI differences are fine when you only call read/write natives like `BlzFrameSetVisible`, `BlzFrameSetText`, `BlzFrameSetTexture` inside the local-player block.

To safely vary visibility per player:

```lua
local f = BlzCreateFrameByType(...)            -- synced
if GetLocalPlayer() == somePlayer then
    BlzFrameSetVisible(f, true)                 -- local only, no desync
end
```

## 5. Coordinate space

Default playable area is `0..0.8` x `0..0.6` (4:3, origin at bottom-left). Anything outside is clipped to 4:3 unless reparented to a frame that escapes 4:3 — best candidates are `BlzGetFrameByName("ConsoleUIBackdrop", 0)` (post-1.31), `BlzGetFrameByName("Multiboard", 0)`, or a custom `FullScreenParent` pattern.

`BlzFrameSetAbsPoint(f, FRAMEPOINT_TOPRIGHT, 0.8, 0.6)` ≈ top-right of the 4:3 play area.

## 6. Useful built-in templates (no custom FDF needed)

Backdrops: `"EscMenuBackdrop"`, `"QuestButtonBaseTemplate"`, `"ScoreScreenButtonBackdropTemplate"`, `"QuestButtonDisabledBackdropTemplate"`, `"QuestButtonPushedBackdropTemplate"`, `"Leaderboard"`.

Button inherits: `"ScriptDialogButton"` (GLUETEXTBUTTON), `"ScoreScreenTabButtonTemplate"` (yellow hover, BUTTON), `"IconButtonTemplate"` (blue hover, BUTTON).

Checkbox: `"QuestCheckBox"`, `"QuestCheckBox2"`, `"QuestCheckBox3"`.

Loading the rest of Blizzard's templates only needs a tiny TOC:

```
UI\FrameDef\Glue\standardtemplates.fdf
UI\FrameDef\UI\escmenutemplates.fdf
UI\FrameDef\Glue\battlenettemplates.fdf
```

Then `BlzLoadTOCFile("war3mapImported\\Templates.toc")` grants access to `EscMenuButtonTemplate`, `EscMenuSliderTemplate`, `EscMenuEditBoxTemplate`, `EscMenuTextAreaTemplate`, `EscMenuLabelTextTemplate`, etc.

## 7. Origin frames worth knowing

`ORIGIN_FRAME_GAME_UI` (root for non-Simple), `ORIGIN_FRAME_HERO_BUTTON` (each hero icon, by index), `ORIGIN_FRAME_COMMAND_BUTTON` (12 command-card buttons), `ORIGIN_FRAME_PORTRAIT`, `ORIGIN_FRAME_MINIMAP`, `ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR`, `ORIGIN_FRAME_WORLD_FRAME`, `ORIGIN_FRAME_UBERTOOLTIP`, `ORIGIN_FRAME_SIMPLE_UI_PARENT` (root for SimpleFrames = `ConsoleUI`).

## 8. Getting an icon for a unit

`BlzGetUnitAbilityByIndex(unit, i)` enumerates **every** ability on the unit, including the hidden item-granted abilities. Iterating it for a "unit icon" picks up a random item ability and is almost never what you want.

For a unit's portrait/icon, use the **unit-type** rawcode:

```lua
local icon = BlzGetAbilityIcon(GetUnitTypeId(unit))   -- works for unit ids too
```

If that returns empty (rare), fall back to a known texture path like `"ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"`.

For an ability's icon (when you actually want one specific ability):

```lua
local abil = BlzGetUnitAbility(unit, FourCC('A000'))
local path = BlzGetAbilityStringLevelField(abil, ABILITY_SLF_ICON_NORMAL, 0)
```

## 9. Common gotchas

- **`BlzFrameSetText` on a TEXT frame ignores `BlzFrameSetFont`** in 1.31; in 1.32+ it works for stand-alone TEXT, but `BlzFrameSetFont` on a `SimpleFrame` crashes the game.
- **`BlzFrameSetTexture(frame, path, 0, true)`** — last arg `blend` controls alpha-channel blending. Use `true` for icons with transparency.
- **`BlzFrameSetVisible` / `BlzFrameSetAlpha` / `BlzFrameSetEnable` / `BlzDestroyFrame` on a `String` or `Texture` simple-frame crashes.**
- **Simple/non-Simple cannot mix as parent-child** without breaking features; pick one family per subtree.
- **`BlzGetFrameByName` only returns frames that have been created in the current local game session** — some Blizzard frames (Quest UI, LogDialog, Chat) only exist after first use or only in single/multiplayer.
- **Empty `framehandle` parent → DC** when you later use a frame native on the child. Always assert/short-circuit if `BlzGetOriginFrame(...)` returns 0.

## 10. Skeleton: hover-tooltip icon button without custom FDF

```lua
local function makeIconButton(parent, ctx, size, texturePath)
    local btn  = BlzCreateFrameByType("BUTTON", "MyBtn", parent, "IconButtonTemplate", ctx)
    BlzFrameSetSize(btn, size, size)

    local icon = BlzCreateFrameByType("BACKDROP", "MyBtnIcon", btn, "", ctx)
    BlzFrameSetAllPoints(icon, btn)
    BlzFrameSetTexture(icon, texturePath, 0, true)

    -- Boxed tooltip (own per button to avoid the shared-tooltip bold-text bug)
    local tipBox = BlzCreateFrame("QuestButtonBaseTemplate", btn, 0, ctx)
    BlzFrameSetSize(tipBox, 0.22, 0.06)
    BlzFrameSetPoint(tipBox, FRAMEPOINT_BOTTOM, btn, FRAMEPOINT_TOP, 0, 0.004)

    local tipText = BlzCreateFrameByType("TEXT", "MyBtnTipText", tipBox, "", ctx)
    BlzFrameSetPoint(tipText, FRAMEPOINT_TOPLEFT, tipBox, FRAMEPOINT_TOPLEFT, 0.008, -0.008)
    BlzFrameSetPoint(tipText, FRAMEPOINT_BOTTOMRIGHT, tipBox, FRAMEPOINT_BOTTOMRIGHT, -0.008, 0.008)
    BlzFrameSetEnable(tipText, false)
    BlzFrameSetTextAlignment(tipText, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)

    BlzFrameSetTooltip(btn, tipBox)
    return btn, icon, tipText
end
```

Set `tipText`'s string with `BlzFrameSetText` whenever the underlying data changes — the engine drives visibility automatically on hover.

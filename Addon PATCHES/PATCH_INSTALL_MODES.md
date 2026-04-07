# Addon Patch Install Modes

Last reviewed: 2026-04-07

This file classifies each addon patch by how it should be installed today.

## Current distribution policy

- GitHub release `addon-patches-v1.0.0` currently ships only `overwrite-only` packages.
- These are the patches that are not safe to split into a dependent `*-KR` addon yet.
- Standalone KR addon candidates will be moved over to `ESOUI -> Minion` distribution in phases.

Why this split is necessary:

1. Overwrite-only patches currently modify original initialization or settings files directly, so a separate dependent addon can break the original addon's load order or recreate global state.
2. Standalone KR addon candidates are safer as separate addons because they only add locale data or patch already-loaded globals.
3. Minion distribution depends on ESOUI registration, so standalone KR addons should be published there instead of being treated as long-term manual overwrite packages.

## Standalone KR addon candidates

These patches can be packaged as a separate `*-KR` addon because they only add localization data or patch already-loaded globals without reinitializing the whole addon.

| Addon | Current patch files | Why standalone is viable |
| --- | --- | --- |
| `ActionDurationReminder` | `ActionDurationReminder/i18n/kr.lua` | Only calls `ActionDurationReminder.putText(...)` after the original addon loads. |
| `Azurah` | `Azurah/Locales/Korean_kr.lua` | Only patches Azurah's locale table/getter and does not reload core modules. |
| `CrutchAlerts` | `CrutchAlerts/lang/kr.lua` | Hooks `LibAddonMenu`, info panel, notifications, and threshold labels after the original addon loads without recreating addon state. |
| `Destinations` | `Destinations/data/kr/*.lua` | Only provides Korean data tables for destination strings and collectibles. |
| `DolgubonsLazyWritCreator` | `DolgubonsLazyWritCreator/Languages/kr.lua` | Patches `WritCreater` language functions after the addon is already in memory; it does not recreate the whole addon state. |
| `HarvestMap` | `HarvestMap/Modules/HarvestMap/Localization/kr.lua` | Only fills `Harvest.localizedStrings`. |
| `LibSavedVars` | `LibSavedVars/localization/kr.lua` | Only adds entries to `LIBSAVEDVARS_STRINGS`. |
| `LostTreasure` | `LostTreasure/lang/kr.lua` | Only registers translated strings with `SafeAddString`. |
| `pChat` | `pChat/i18n/kr.lua` | Only registers translated strings with `SafeAddString`. |
| `TamrielTradeCentre` | `TamrielTradeCentre/lang/kr.lua`, `TamrielTradeCentre/ItemLookUpTable_kr.lua` | Only adds TTC string IDs and Korean lookup tables. |

## Overwrite-only patches

These patches are not safe as separate `*-KR` addons in their current form.
They reload core addon files, rebuild global state, or rerun full settings modules.
For these, the current safe delivery method is to overwrite files inside the original addon folder.

| Addon | Current patch files | Why standalone breaks |
| --- | --- | --- |
| `BanditsUserInterface` | `BUI_Vars.lua`, `BUI_Controls.lua`, `BUI_Menu.lua`, `BUI_Settings.lua`, `BUI_Automation.lua`, `BUI_Initialize.lua`, `lang/kr.lua` | Reloads Bandits core files and recreates `BUI = {}`. This wipes or replaces state from the original addon and breaks settings/UI initialization. |
| `FancyActionBar+` | `menu.lua`, `lang/kr.lua` | Reloads the full settings menu module instead of only injecting translations. |
| `LibAddonMenu-2.0` | `LibAddonMenu-2.0.lua` | Reloads the entire library, which is too risky as a dependent addon because many addons may already have initialized against the original library instance. |
| `USPF` | `USPF.lua`, `USPF_Menu.lua`, `lang/strings.lua`, `lang/kr.lua` | Reloads the addon core and menu modules, not just language data. |
| `VotansMiniMap` | `Settings.lua`, `PinLevels.lua`, `PinSizes.lua`, `Styles.lua`, `lang/strings.lua`, `lang/kr.lua` | Reloads multiple core settings/style modules and is not a pure post-load locale patch. |

## Next refactor targets

To convert an overwrite-only patch into a real standalone `*-KR` addon, the patch must stop reloading original core files and instead do one of these:

1. Register strings only.
2. Patch exported locale tables after `DependsOn` load.
3. Hook or replace specific functions on existing globals without recreating the addon root table.

`BanditsUserInterface` is the confirmed failure case that proved this distinction matters.

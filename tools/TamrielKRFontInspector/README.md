# TamrielKR Font Inspector

Hover inspector addon for ESO UI font debugging.

## Commands
- `/tkfi`
- `/tkfi on`
- `/tkfi off`
- `/tkfi freeze`
- `/tkfi dump`

## What it shows
- Hovered control name
- Control text
- `GetFont()` reference
- Resolved font file, size, and effect when available
- Control dimensions and text dimensions
- Parent chain
- Descendant text/font candidates inside hovered container
- Control source name and call site when the API exposes them

## Important note
The addon can show the control's assigned font style or font file, but the final Korean glyph fallback chosen through `BackupFont` is not exposed directly by the UI API.
Use the displayed font reference together with `backupfont_kr.xml` when tracing the actual Korean fallback chain.

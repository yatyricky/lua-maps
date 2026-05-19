---
description: "General c# guidelines"
applyTo: "**/*.cs"
---

- Warcraft III world space in this repo is right-handed: +x points right, +y points away, +z points up.
- This is not a conventional C# runtime project. Treat `CSProject/**/*.cs` as source meant to be transpiled to Lua, and do not validate changes with `dotnet build` or similar CLR build steps unless the user explicitly asks for that.

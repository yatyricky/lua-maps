---
description: "General c# guidelines"
applyTo: "**/*.cs"
---

- Warcraft III world space in this repo is right-handed: +x points right (east), +y points away (north), +z points up (flying up).
- This is not a conventional C# runtime project. Treat `CSProject/**/*.cs` as source meant to be transpiled to Lua, and do not validate changes with `dotnet build` or similar CLR build steps unless the user explicitly asks for that.
- CSharp side code largely draws on Unity's API and semantics, but it is not actually running on Unity. Do not suggest code that relies on Unity-specific features or behaviors that are not explicitly implemented in the transpilation layer.

# Jass to Lua Declaration Generator

This tool converts Warcraft III Jass files (`common.j` and `blizzard.j`) into properly formatted Lua declaration files with EmmyLua annotations.

## Features

- **Automatic file splitting**: Keeps generated files under 5000 lines for optimal Language Server performance
- **EmmyLua annotations**: Generates proper `@type`, `@param`, and `@return` annotations
- **Type definitions**: Converts Jass type hierarchies to Lua class definitions
- **Function declarations**: Converts native functions with proper parameter typing
- **Global constants**: Processes constant declarations with comments
- **Keyword escaping**: Handles Lua keywords by prefixing with underscore

## Usage

### Quick Generation (PowerShell)
```powershell
.\generate.ps1          # Normal mode (clean output)
.\generate.ps1 -Debug   # Debug mode (shows unprocessed lines)
```

### Quick Generation (Batch)
```cmd
generate.bat
```

### Manual Generation
```bash
node enhanced-parser.js <input.j> <output-prefix> [--debug]
```

Examples:
```bash
node enhanced-parser.js common.j common           # Clean output
node enhanced-parser.js common.j common --debug   # Show unprocessed lines
node enhanced-parser.js blizzard.j blizzard
```

## Output

The generator creates multiple files:
- `common_1.lua`, `common_2.lua`, etc. (from `common.j`)
- `blizzard_1.lua`, `blizzard_2.lua`, etc. (from `blizzard.j`)

Each file contains:
- `---@diagnostic disable` header to suppress Language Server warnings
- Type definitions with inheritance (`---@class Type : ParentType`)
- Function declarations with parameter and return type annotations
- Global variable declarations

## Example Output

### Type Definition
```lua
---@class unit : widget

---@class player : agent
```

### Function Declaration
```lua
---@param whichPlayer player
---@param newName string
---@return nothing
function SetPlayerName(whichPlayer, newName) end
```

### Global Constant
```lua
---3.14159
---@type real
bj_PI = nil
```

## File Structure

- `enhanced-parser.js` - Main parser script
- `generate.ps1` - PowerShell generation script
- `generate.bat` - Batch generation script
- `common.j` - Source Jass common functions
- `blizzard.j` - Source Jass blizzard functions
- `common_*.lua` - Generated common declarations (output)
- `blizzard_*.lua` - Generated blizzard declarations (output)

## Configuration

The parser can be configured by modifying these settings in `enhanced-parser.js`:

- `maxLinesPerFile`: Maximum lines per output file (default: 4500)
- `keywords`: Set of Lua keywords to escape
- `skipPatterns`: Regular expressions for lines to ignore

## Troubleshooting

### "Unprocessed" Lines
If you see "Unprocessed" lines in the output (when using `--debug` flag), these are typically:
- **Function implementations** - We intentionally skip function bodies and only extract declarations
- **Control flow statements** (`if`, `else`, `return`) - These are implementation details we don't need
- **Complex variable assignments** - Some complex initialization patterns aren't needed for type definitions

These are **safe to ignore** as the parser focuses on extracting API declarations for type checking, not implementation details.

### Performance
The parser processes:
- **common.j**: ~3,368 declarations from 4,224 total lines  
- **blizzard.j**: ~497 declarations from 10,808 total lines

Most skipped lines are intentional (comments, implementations, control flow).
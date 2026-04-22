const fs = require("fs");
const path = require("path");
const readline = require("readline");

class JassToLuaGenerator {
    constructor(options = {}) {
        this.maxLinesPerFile = 4500; // Keep under 5000 for language server
        this.currentLines = 0;
        this.currentFileIndex = 1;
        this.currentOutput = "";
        this.outputFiles = [];
        this.debugMode = options.debug || false; // Control debug output
        this.keywords = new Set(['end', 'function', 'local', 'return', 'if', 'then', 'else', 'elseif', 'while', 'do', 'for', 'in', 'repeat', 'until', 'break', 'and', 'or', 'not']);
        
        // Better regex patterns
        this.regType = /^\s*type\s+(?<name>\w+)\s+extends\s+(?<super>\w+)(?:\s+.*)?$/;
        this.regFunc = /^\s*(?:constant\s+)?(?:native|function)\s+(?<name>\w+)\s+takes\s+(?<args>[^)]*)\s+returns\s+(?<type>\w+)\s*$/;
        this.regConst = /^\s*constant\s+(?<type>\w+)\s+(?<name>\w+)\s*=\s*(?<expr>.*?)\s*$/;
        this.regGlobal = /^\s*(?<type>\w+)\s+(?<name>\w+)\s*$/;
        
        // Skip patterns
        this.skipPatterns = [
            /^\s*\/\//, // Comments
            /^\s*$/, // Empty lines
            /^\s*globals\s*$/, 
            /^\s*endglobals\s*$/,
            /^\s*endfunction\s*$/,
            /^\s*function\s+\w+\s+takes/, // Function implementations (we only want declarations)
            /^\s*local\s+/,
            /^\s*set\s+/,
            /^\s*call\s+/,
            /^\s*return\s*$/,
            /^\s*return\s+/,
            /^\s*if[\s(]/,
            /^\s*then\s*$/,
            /^\s*else\s*$/,
            /^\s*elseif[\s(]/,
            /^\s*endif\s*$/,
            /^\s*loop\s*$/,
            /^\s*endloop\s*$/,
            /^\s*exitwhen\s+/,
            /^\s*debug\s+/
        ];
    }

    escapeKeyword(name) {
        return this.keywords.has(name) ? `_${name}` : name;
    }

    shouldSkip(line) {
        return this.skipPatterns.some(pattern => pattern.test(line));
    }

    addToOutput(content) {
        const lines = content.split('\n').length - 1;
        if (this.currentLines + lines > this.maxLinesPerFile) {
            this.flushCurrentFile();
        }
        this.currentOutput += content;
        this.currentLines += lines;
    }

    flushCurrentFile() {
        if (this.currentOutput.trim()) {
            this.outputFiles.push({
                index: this.currentFileIndex,
                content: `---@diagnostic disable\n\n${this.currentOutput}`
            });
            this.currentFileIndex++;
            this.currentOutput = "";
            this.currentLines = 0;
        }
    }

    processType(line) {
        const match = line.match(this.regType);
        if (!match) return false;
        
        const { name, super: superType } = match.groups;
        this.addToOutput(`---@class ${name} : ${superType}\n\n`);
        return true;
    }

    processFunction(line) {
        const match = line.match(this.regFunc);
        if (!match) return false;
        
        const { name, args, type } = match.groups;
        let output = "";
        
        const argList = [];
        if (args.trim() !== "nothing" && args.trim() !== "") {
            const argParts = args.split(",").map(arg => arg.trim()).filter(arg => arg);
            for (const arg of argParts) {
                const parts = arg.split(/\s+/);
                if (parts.length >= 2) {
                    const argType = parts[0];
                    const argName = this.escapeKeyword(parts[1]);
                    argList.push({ name: argName, type: argType });
                    output += `---@param ${argName} ${argType}\n`;
                }
            }
        }
        
        output += type !== "nothing" ? `---@return ${type}\n` : ""
        const argNames = argList.map(arg => arg.name).join(", ");
        output += `function ${name}(${argNames}) end\n\n`;
        
        this.addToOutput(output);
        return true;
    }

    processConstant(line) {
        const match = line.match(this.regConst);
        if (!match) return false;
        
        const { type, name, expr } = match.groups;
        let output = "";
        
        if (expr && expr.trim()) {
            output += `---${expr.trim()}\n`;
        }
        output += `---@type ${type}\n`;
        output += `${name} = nil\n\n`;
        
        this.addToOutput(output);
        return true;
    }

    processGlobal(line) {
        // Handle simple global variable declarations
        let match = line.match(this.regGlobal);
        if (!match) return false;
        
        const { type, name } = match.groups;
        
        // Skip if this looks like a type definition or other special case
        if (type === 'type' || line.includes('extends') || line.includes('takes') || line.includes('returns')) {
            return false;
        }
        
        let output = `---@type ${type}\n`;
        output += `${name} = nil\n\n`;
        
        this.addToOutput(output);
        return true;
    }

    processComplexGlobal(line) {
        // Handle complex global declarations like "force array bj_FORCE_PLAYER"
        const complexGlobalMatch = line.match(/^\s*(?<type>\w+)(?<isArray>\s+array)?\s+(?<name>\w+)(?:\s*=.*)?$/);
        if (!complexGlobalMatch) return false;
        
        const { type, isArray, name } = complexGlobalMatch.groups;
        
        // Skip type definitions and function-like lines
        if (type === 'type' || line.includes('extends') || line.includes('takes') || line.includes('returns') || line.includes('function')) {
            return false;
        }
        
        // Skip control flow keywords
        if (['if', 'else', 'elseif', 'return', 'then'].includes(type)) {
            return false;
        }
        
        const luaType = isArray ? `${type}[]` : type;
        let output = `---@type ${luaType}\n`;
        output += `${name} = nil\n\n`;
        
        this.addToOutput(output);
        return true;
    }

    async processFile(inputFile, outputPrefix) {
        console.log(`Processing ${inputFile}...`);
        
        const fileStream = fs.createReadStream(inputFile);
        const rl = readline.createInterface({
            input: fileStream,
            crlfDelay: Infinity
        });

        let processedLines = 0;
        let skippedLines = 0;

        for await (const line of rl) {
            const trimmedLine = line.trim();
            
            if (this.shouldSkip(trimmedLine)) {
                skippedLines++;
                continue;
            }

            let processed = false;
            
            // Try to process as different types
            processed = this.processType(trimmedLine) ||
                       this.processFunction(trimmedLine) ||
                       this.processConstant(trimmedLine) ||
                       this.processGlobal(trimmedLine) ||
                       this.processComplexGlobal(trimmedLine);

            if (!processed && trimmedLine) {
                // Log unprocessed lines only in debug mode
                if (this.debugMode) {
                    console.log(`Unprocessed: ${trimmedLine}`);
                }
            } else if (processed) {
                processedLines++;
            }
        }

        this.flushCurrentFile();
        
        console.log(`Processed ${processedLines} lines, skipped ${skippedLines} lines`);
        console.log(`Generated ${this.outputFiles.length} files`);

        // Write output files
        for (const file of this.outputFiles) {
            const outputPath = `${outputPrefix}_${file.index}.lua`;
            fs.writeFileSync(outputPath, file.content);
            console.log(`Written ${outputPath} (${file.content.split('\n').length} lines)`);
        }

        // Reset for next file
        this.outputFiles = [];
        this.currentFileIndex = 1;
        this.currentOutput = "";
        this.currentLines = 0;
    }
}

async function main() {
    const debugMode = process.argv.includes('--debug');
    const filteredArgs = process.argv.slice(2).filter(a => a !== '--debug');

    if (filteredArgs.length === 0) {
        // Default: process both standard WC3 files in the same directory as this script
        const dir = path.dirname(path.resolve(process.argv[1]));
        const pairs = [
            { input: path.join(dir, 'common.j'),   prefix: path.join(dir, 'common') },
            { input: path.join(dir, 'blizzard.j'), prefix: path.join(dir, 'blizzard') },
        ];
        for (const { input, prefix } of pairs) {
            if (!fs.existsSync(input)) {
                console.error(`Input file ${input} does not exist, skipping`);
                continue;
            }
            const generator = new JassToLuaGenerator({ debug: debugMode });
            await generator.processFile(input, prefix);
        }
        return;
    }

    if (filteredArgs.length < 2) {
        console.log("Usage: node enhanced-parser.js <input.j> <output-prefix> [--debug]");
        console.log("       node enhanced-parser.js [--debug]   (processes common.j and blizzard.j)");
        process.exit(1);
    }

    const inputFile = filteredArgs[0];
    const outputPrefix = filteredArgs[1];

    if (!fs.existsSync(inputFile)) {
        console.error(`Input file ${inputFile} does not exist`);
        process.exit(1);
    }

    const generator = new JassToLuaGenerator({ debug: debugMode });
    await generator.processFile(inputFile, outputPrefix);
}

if (require.main === module) {
    main().catch(console.error);
}

module.exports = { JassToLuaGenerator };
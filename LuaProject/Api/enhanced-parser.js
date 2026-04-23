const fs = require("fs");
const path = require("path");

// ============================================================================
// JASS Tokenizer
// ============================================================================

const TokenType = {
    KEYWORD: "KEYWORD",
    IDENT: "IDENT",
    NUMBER: "NUMBER",
    STRING: "STRING",
    FOURCC: "FOURCC",
    LPAREN: "LPAREN",
    RPAREN: "RPAREN",
    COMMA: "COMMA",
    EQ: "EQ",
    LBRACKET: "LBRACKET",
    RBRACKET: "RBRACKET",
    COMMENT: "COMMENT",
    EOF: "EOF",
};

const KEYWORDS = new Set([
    "type", "extends", "native", "constant", "function", "takes", "returns",
    "globals", "endglobals", "endfunction", "local", "set", "call", "return",
    "if", "then", "else", "elseif", "endif", "loop", "endloop", "exitwhen",
    "array", "nothing", "and", "or", "not", "debug", "true", "false",
]);

class Token {
    constructor(type, value, line) {
        this.type = type;
        this.value = value;
        this.line = line;
    }
    toString() {
        return `${this.type}(${this.value}) @${this.line}`;
    }
}

function tokenize(source) {
    const tokens = [];
    let i = 0;
    let line = 1;

    while (i < source.length) {
        // Whitespace
        if (source[i] === "\n") { line++; i++; continue; }
        if (/\s/.test(source[i])) { i++; continue; }

        // Line comment //
        if (source[i] === "/" && source[i + 1] === "/") {
            while (i < source.length && source[i] !== "\n") i++;
            continue;
        }

        // String literal
        if (source[i] === '"') {
            let val = '"';
            i++;
            while (i < source.length && source[i] !== '"') {
                if (source[i] === "\\") { val += source[i++]; }
                val += source[i++];
            }
            if (i < source.length) { val += source[i]; i++; }
            tokens.push(new Token(TokenType.STRING, val, line));
            continue;
        }

        // Four-character code literal 'xxxx'
        if (source[i] === "'") {
            let val = "'";
            i++;
            while (i < source.length && source[i] !== "'" && source[i] !== "\n") {
                val += source[i++];
            }
            if (i < source.length && source[i] === "'") { val += source[i]; i++; }
            tokens.push(new Token(TokenType.FOURCC, val, line));
            continue;
        }

        // Number
        if (/[0-9]/.test(source[i]) || (source[i] === "." && /[0-9]/.test(source[i + 1]))) {
            let val = "";
            if (source[i] === "0" && (source[i + 1] === "x" || source[i + 1] === "X")) {
                val = source[i] + source[i + 1]; i += 2;
                while (i < source.length && /[0-9a-fA-F]/.test(source[i])) val += source[i++];
            } else {
                while (i < source.length && /[0-9]/.test(source[i])) val += source[i++];
                if (i < source.length && source[i] === ".") {
                    val += source[i++];
                    while (i < source.length && /[0-9]/.test(source[i])) val += source[i++];
                }
            }
            tokens.push(new Token(TokenType.NUMBER, val, line));
            continue;
        }

        // Identifier / keyword
        if (/[a-zA-Z_]/.test(source[i])) {
            let val = "";
            while (i < source.length && /\w/.test(source[i])) val += source[i++];
            const type = KEYWORDS.has(val) ? TokenType.KEYWORD : TokenType.IDENT;
            tokens.push(new Token(type, val, line));
            continue;
        }

        // Punctuation
        const ch = source[i];
        switch (ch) {
            case "(": tokens.push(new Token(TokenType.LPAREN, "(", line)); i++; break;
            case ")": tokens.push(new Token(TokenType.RPAREN, ")", line)); i++; break;
            case ",": tokens.push(new Token(TokenType.COMMA, ",", line)); i++; break;
            case "=": tokens.push(new Token(TokenType.EQ, "=", line)); i++; break;
            case "[": tokens.push(new Token(TokenType.LBRACKET, "[", line)); i++; break;
            case "]": tokens.push(new Token(TokenType.RBRACKET, "]", line)); i++; break;
            default: i++; break; // skip unknown characters
        }
    }

    tokens.push(new Token(TokenType.EOF, "", line));
    return tokens;
}

// ============================================================================
// JASS Parser -> AST
// ============================================================================

// AST Node types
// TypeDecl:     { kind: "TypeDecl", name, super }
// FuncDecl:     { kind: "FuncDecl", isConstant, isNative, name, params:[{type,name}], returnType }
// GlobalDecl:   { kind: "GlobalDecl", isConstant, type, name, isArray, value? }

class Parser {
    constructor(tokens, options = {}) {
        this.tokens = tokens;
        this.pos = 0;
        this.nodes = [];
        this.debug = options.debug || false;
    }

    peek() { return this.tokens[this.pos]; }
    advance() { return this.tokens[this.pos++]; }

    expect(type, value) {
        const t = this.advance();
        if (t.type !== type || (value !== undefined && t.value !== value)) {
            throw new Error(`Expected ${type}(${value || "any"}) but got ${t} at line ${t.line}`);
        }
        return t;
    }

    match(type, value) {
        const t = this.peek();
        if (t.type === type && (value === undefined || t.value === value)) {
            return this.advance();
        }
        return null;
    }

    parse() {
        while (this.peek().type !== TokenType.EOF) {
            try {
                this.parseTopLevel();
            } catch (e) {
                if (this.debug) {
                    console.error(`Parse error at line ${this.peek().line}: ${e.message}`);
                }
                // Skip to next recognizable top-level construct
                this.recover();
            }
        }
        return this.nodes;
    }

    recover() {
        // Advance until we find a top-level keyword or EOF
        while (this.peek().type !== TokenType.EOF) {
            const t = this.peek();
            if (t.type === TokenType.KEYWORD && [
                "type", "constant", "native", "function", "globals"
            ].includes(t.value)) {
                break;
            }
            this.advance();
        }
    }

    parseTopLevel() {
        const t = this.peek();

        if (t.type === TokenType.KEYWORD && t.value === "type") {
            this.parseTypeDecl();
        } else if (t.type === TokenType.KEYWORD && t.value === "globals") {
            this.parseGlobals();
        } else if (t.type === TokenType.KEYWORD && t.value === "native") {
            this.parseNativeFunc(false);
        } else if (t.type === TokenType.KEYWORD && t.value === "constant") {
            // constant native ... OR constant <type> <name> = ...
            this.parseConstant();
        } else if (t.type === TokenType.KEYWORD && t.value === "function") {
            this.parseFunction();
        } else {
            this.advance(); // skip unknown top-level token
        }
    }

    parseTypeDecl() {
        this.expect(TokenType.KEYWORD, "type");
        const name = this.expect(TokenType.IDENT).value;
        this.expect(TokenType.KEYWORD, "extends");
        const superType = this.expect(TokenType.IDENT).value;
        this.nodes.push({ kind: "TypeDecl", name, super: superType });
    }

    parseGlobals() {
        this.expect(TokenType.KEYWORD, "globals");
        while (!(this.peek().type === TokenType.KEYWORD && this.peek().value === "endglobals")) {
            if (this.peek().type === TokenType.EOF) break;
            this.parseGlobalEntry();
        }
        this.expect(TokenType.KEYWORD, "endglobals");
    }

    parseGlobalEntry() {
        // Possible forms:
        //   constant <type> <name> = <expr>
        //   <type> array <name>
        //   <type> <name> [= <expr>]
        const isConst = !!this.match(TokenType.KEYWORD, "constant");
        const typeTok = this.advance();
        const type = typeTok.value;

        let isArray = false;
        if (this.peek().type === TokenType.KEYWORD && this.peek().value === "array") {
            this.advance();
            isArray = true;
        }

        const name = this.expect(TokenType.IDENT).value;

        let value = null;
        if (this.match(TokenType.EQ)) {
            value = this.readExpr();
        }

        this.nodes.push({ kind: "GlobalDecl", isConstant: isConst, type, name, isArray, value });
    }

    parseConstant() {
        this.expect(TokenType.KEYWORD, "constant");
        // Is it "constant native ..."?
        if (this.peek().type === TokenType.KEYWORD && this.peek().value === "native") {
            this.parseNativeFunc(true);
            return;
        }
        // constant <type> <name> = <expr>
        const type = this.advance().value;
        const name = this.expect(TokenType.IDENT).value;
        this.expect(TokenType.EQ);
        const value = this.readExpr();
        this.nodes.push({ kind: "GlobalDecl", isConstant: true, type, name, isArray: false, value });
    }

    parseNativeFunc(isConstant) {
        this.expect(TokenType.KEYWORD, "native");
        const name = this.expect(TokenType.IDENT).value;
        this.expect(TokenType.KEYWORD, "takes");
        const params = this.parseParams();
        this.expect(TokenType.KEYWORD, "returns");
        const returnType = this.parseReturnType();
        this.nodes.push({ kind: "FuncDecl", isConstant, isNative: true, name, params, returnType });
    }

    parseFunction() {
        this.expect(TokenType.KEYWORD, "function");
        const name = this.expect(TokenType.IDENT).value;
        this.expect(TokenType.KEYWORD, "takes");
        const params = this.parseParams();
        this.expect(TokenType.KEYWORD, "returns");
        const returnType = this.parseReturnType();
        // Skip function body until endfunction
        this.skipFunctionBody();
        this.nodes.push({ kind: "FuncDecl", isConstant: false, isNative: false, name, params, returnType });
    }

    parseParams() {
        const params = [];
        // nothing?
        if (this.peek().type === TokenType.KEYWORD && this.peek().value === "nothing") {
            this.advance();
            return params;
        }
        // type name [, type name]*
        while (true) {
            const type = this.advance().value;
            const name = this.expect(TokenType.IDENT).value;
            params.push({ type, name });
            if (!this.match(TokenType.COMMA)) break;
        }
        return params;
    }

    parseReturnType() {
        if (this.peek().type === TokenType.KEYWORD && this.peek().value === "nothing") {
            this.advance();
            return "nothing";
        }
        return this.advance().value;
    }

    skipFunctionBody() {
        let depth = 1; // we're inside the function
        while (depth > 0 && this.peek().type !== TokenType.EOF) {
            const t = this.advance();
            if (t.type === TokenType.KEYWORD && t.value === "function") {
                // Nested function declaration (unlikely but handle)
                // Actually JASS doesn't have nested functions, but just in case
            }
            if (t.type === TokenType.KEYWORD && t.value === "endfunction") {
                depth--;
            }
        }
    }

    readExpr() {
        // Read tokens until we hit something that ends the expression:
        // - A keyword that starts a new statement (but not part of the expr)
        // - A comma or closing paren in the parent context
        // - End of line (we consumed all tokens on this logical line)
        //
        // Since JASS expressions can be complex but we only need the text for
        // annotation comments, just collect tokens until we see a clear boundary.
        const parts = [];
        while (this.peek().type !== TokenType.EOF) {
            const t = this.peek();
            // Stop at keywords that signal a new statement
            if (t.type === TokenType.KEYWORD && [
                "type", "constant", "native", "function", "globals", "endglobals",
                "endfunction", "local", "set", "call", "if", "else", "elseif",
                "endif", "loop", "endloop", "exitwhen", "return", "debug"
            ].includes(t.value)) {
                break;
            }
            // Convert fourcc 'xxxx' to FourCC('xxxx')
            if (t.type === TokenType.FOURCC) {
                parts.push(`FourCC(${t.value})`);
                this.advance();
            } else {
                parts.push(this.advance().value);
            }
        }
        return parts.join(" ").trim();
    }
}

// ============================================================================
// Lua Annotation Generator from AST
// ============================================================================

const LUA_KEYWORDS = new Set([
    "end", "function", "local", "return", "if", "then", "else", "elseif",
    "while", "do", "for", "in", "repeat", "until", "break", "and", "or", "not"
]);

class LuaAnnotationGenerator {
    constructor(options = {}) {
        this.maxLinesPerFile = 4500;
        this.currentLines = 0;
        this.currentFileIndex = 1;
        this.currentOutput = "";
        this.outputFiles = [];
    }

    escapeKeyword(name) {
        return LUA_KEYWORDS.has(name) ? `_${name}` : name;
    }

    addToOutput(content) {
        const lines = content.split("\n").length - 1;
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

    generate(nodes) {
        for (const node of nodes) {
            switch (node.kind) {
                case "TypeDecl":
                    this.emitTypeDecl(node);
                    break;
                case "FuncDecl":
                    this.emitFuncDecl(node);
                    break;
                case "GlobalDecl":
                    this.emitGlobalDecl(node);
                    break;
            }
        }
        this.flushCurrentFile();
        return this.outputFiles;
    }

    emitTypeDecl(node) {
        this.addToOutput(`---@class ${node.name} : ${node.super}\n\n`);
    }

    emitFuncDecl(node) {
        let output = "";
        for (const p of node.params) {
            const name = this.escapeKeyword(p.name);
            output += `---@param ${name} ${p.type}\n`;
        }
        if (node.returnType !== "nothing") {
            output += `---@return ${node.returnType}\n`;
        }
        const argNames = node.params.map(p => this.escapeKeyword(p.name)).join(", ");
        output += `function ${node.name}(${argNames}) end\n\n`;
        this.addToOutput(output);
    }

    emitGlobalDecl(node) {
        let output = "";
        if (node.isConstant && node.value) {
            output += `---${node.value}\n`;
        }
        const luaType = node.isArray ? `${node.type}[]` : node.type;
        output += `---@type ${luaType}\n`;
        output += `${node.name} = nil\n\n`;
        this.addToOutput(output);
    }
}

// ============================================================================
// Main
// ============================================================================

async function main() {
    const debugMode = process.argv.includes("--debug");
    const filteredArgs = process.argv.slice(2).filter(a => a !== "--debug");

    let pairs;
    if (filteredArgs.length === 0) {
        const dir = path.dirname(path.resolve(process.argv[1]));
        pairs = [
            { input: path.join(dir, "common.j"),   prefix: path.join(dir, "common") },
            { input: path.join(dir, "blizzard.j"), prefix: path.join(dir, "blizzard") },
        ];
    } else if (filteredArgs.length < 2) {
        console.log("Usage: node enhanced-parser.js <input.j> <output-prefix> [--debug]");
        console.log("       node enhanced-parser.js [--debug]   (processes common.j and blizzard.j)");
        process.exit(1);
    } else {
        pairs = [{ input: filteredArgs[0], prefix: filteredArgs[1] }];
    }

    for (const { input, prefix } of pairs) {
        if (!fs.existsSync(input)) {
            console.error(`Input file ${input} does not exist, skipping`);
            continue;
        }

        console.log(`Parsing ${input}...`);
        const source = fs.readFileSync(input, "utf-8");
        const tokens = tokenize(source);
        console.log(`  Tokenized: ${tokens.length} tokens`);

        const parser = new Parser(tokens, { debug: debugMode });
        const ast = parser.parse();
        console.log(`  Parsed: ${ast.length} AST nodes`);

        const counts = {};
        for (const node of ast) {
            counts[node.kind] = (counts[node.kind] || 0) + 1;
        }
        for (const [kind, count] of Object.entries(counts)) {
            console.log(`    ${kind}: ${count}`);
        }

        const generator = new LuaAnnotationGenerator();
        const outputFiles = generator.generate(ast);

        for (const file of outputFiles) {
            const outputPath = `${prefix}_${file.index}.lua`;
            fs.writeFileSync(outputPath, file.content);
            console.log(`  Written ${outputPath} (${file.content.split("\n").length} lines)`);
        }
    }
}

if (require.main === module) {
    main().catch(console.error);
}

module.exports = { tokenize, Parser, LuaAnnotationGenerator };

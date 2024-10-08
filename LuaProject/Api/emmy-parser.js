const fs = require("fs");
const readline = require("readline");

const whichFile = process.argv[2];
const targetFile = process.argv[3];

const keywords = {
    end: 1
}

function escape(name) {
    if (keywords[name] === 1) {
        return "_" + name
    } else {
        return name
    }
}

const ri = readline.createInterface({
    input: fs.createReadStream(whichFile),
});

const regType = new RegExp(/type\s+(?<name>\w+)\s+extends\s+(?<super>\w+)/g);
const regFunc = new RegExp(/(constant\s+)?(native|function)\s+(?<name>\w+)\s+takes\s+(?<args>[\w \t,]+)\s+returns\s+(?<type>\w+)/g);
const regConst = new RegExp(/constant\s+(?<type>\w+)\s+(?<name>\w+)\s*=\s*(?<expr>.+)[\t ]*/g);

let output = ""

const ignore = [
    "//", "set ", "globals", "endglobals", "endfunction",
    "return", "endif", "local", "call", "if", "endloop", "exitwhen", "loop", "else",
    "debug", "boolean", "boolexpr", "commandbuttoneffect",
    "minimapicon", "ubersplat", "image", "lightning", "texttag", "unit",
    "button", "hashtable", "gamecache", "real", "string", "sound", "multiboard", "leaderboard",
    "timerdialog", "timer", "defeatcondition", "questitem", "quest", "terraindeformation",
    "integer", "item", "trigger", "group", "effect", "weathereffect",
    "fogmodifier", "destructable", "widget", "rect", "playercolor", "location", "player",
    "force", "mapcontrol", "gamespeed"
]

function shouldIgnore(line) {
    if (line.length === 0) {
        return true
    } else {
        for (const item of ignore) {
            if (line.startsWith(item)) {
                return true
            }
        }
        return false
    }
}

ri.on("line", (line) => {
    line = line.trim();
    if (line.match(regType)) {
        const g = regType.exec(line).groups
        output += `---@class ${g.name} : ${g.super}\n\n`
        regType.lastIndex = 0
    } else if (line.match(regFunc)) {
        const g = regFunc.exec(line).groups
        const argList = []
        if (g.args !== "nothing") {
            for (const arg of g.args.split(",")) {
                const ps = arg.trim().split(/[ \t]+/);
                const argName = escape(ps[1])
                argList.push({
                    name: argName,
                    type: ps[0]
                })
                output += `---@param ${argName} ${ps[0]}\n`
            }
        }
        output += `---@return ${g.type}\n`
        const argNameList = argList.map((e) => e.name).join(", ")
        output += `function ${g.name}(${argNameList}) end\n\n`
        regFunc.lastIndex = 0
    } else if (line.match(regConst)) {
        const g = regConst.exec(line).groups
        if (g.expr.trim().length > 0) {
            output += `---${g.expr}\n`
        }
        output += `---@type ${g.type}\n`
        output += `${g.name} = nil\n\n`
        regConst.lastIndex = 0
    } else if (shouldIgnore(line)) {
        // do nothing
    } else {
        console.log(line)
    }
});

ri.on("close", () => {
    fs.writeFileSync(targetFile, output);
});
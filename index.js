const fs = require("fs")
const path = require("path")
const readline = require('readline')
const child_process = require("child_process")

function askQuestion(query) {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
    });

    return new Promise(resolve => rl.question(query, ans => {
        rl.close();
        resolve(ans);
    }))
}

const configFp = path.join(__dirname, "config.json")

if (!fs.existsSync(configFp)) {
    console.log("\u001B[31m" + "Missing config.json, but I have created one for you. Please edit it and fill up the 'WC3Path' field." + "\u001B[0m")
    fs.writeFileSync(configFp, `{
    "WC3Path": ""
}`)
    process.exit(1)
}

const config = JSON.parse(fs.readFileSync(configFp))

const exePath = path.join(config.WC3Path, "_retail_/x86_64/Warcraft III.exe")
if (!fs.existsSync(exePath)) {
    console.log("\u001B[31m" + `The WC3Path in config.json is not right, I can't find ${exePath}` + "\u001B[0m")
    process.exit(1)
}

async function program() {
    // 1. map name
    let mapName = process.argv[2]
    if (mapName === undefined) {
        const opts = []
        for (const map of fs.readdirSync(__dirname)) {
            const absFp = path.join(__dirname, map)
            const stat = fs.statSync(absFp)
            if (!stat.isDirectory()) {
                continue
            }
            const fp = path.parse(absFp)
            if (fp.ext !== ".w3x") {
                continue
            }
            opts.push(fp.base)
        }
        let n = -1
        while (n < 0) {
            const chosen = await askQuestion(`${opts.map((e, i) => `${i + 1}. ${e}`).join("\n")}\nChoose a map: `)
            try {
                n = parseInt(chosen, 10)
                if (isNaN(n) || n > opts.length || n <= 0) {
                    n = -1
                }
            } catch (error) {
            }
        }
        mapName = opts[n - 1]
    }

    // 2. copy .\moonglade.w3x\war3map.wts .\moonglade.w3x\_Locales\zhCN.w3mod /y
    const from = path.join(__dirname, mapName, "war3map.wts")
    if (fs.existsSync(from)) {
        fs.copyFileSync(from, path.join(__dirname, mapName, "_Locales", "zhCN.w3mod", "war3map.wts"))
    }

    // 3. node ./lua-bundler/bin.js ./Main.lua ./moonglade.w3x/war3map.lua -e "Api;lua-bundler"
    child_process.execSync(`node ./lua-bundler/bin.js ./LuaProject/Main.lua ./${mapName}/war3map.lua -e "Api"`, {
        cwd: __dirname
    })
    

    // 4. launch
    if (process.argv[3] !== "-t") {
        const cmd = `"${exePath}" -launch -window -loadfile "${path.resolve(path.join(__dirname, mapName))}"`
        child_process.execSync(cmd, {
            cwd: __dirname
        })
    }
}

program().catch(e => console.log(e))
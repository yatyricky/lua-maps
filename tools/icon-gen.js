import fs from "fs"
import path from "path"
import { fileURLToPath } from "url"
import sharp from "sharp"

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)


// War3 icon standard size
const ICON_SIZE = 64

// Frame overlay paths
const BTN_FRAME = path.join(__dirname, "BTN.png")
const DISBTN_FRAME = path.join(__dirname, "DISBTN.png")
const PASBTN_FRAME = path.join(__dirname, "PASBTN.png")

// TGA file header structure (18 bytes)
function createTGAHeader(width, height) {
    const header = Buffer.alloc(18)
    // 0: ID length (no ID)
    header.writeUInt8(0, 0)
    // 1: Color map type (0 = no color map)
    header.writeUInt8(0, 1)
    // 2: Image type (2 = uncompressed true-color)
    header.writeUInt8(2, 2)
    // 3-4: Color map origin (ignored, set to 0)
    header.writeUInt16LE(0, 3)
    // 5-6: Color map length (ignored, set to 0)
    header.writeUInt16LE(0, 5)
    // 7: Color map depth (ignored, set to 0)
    header.writeUInt8(0, 7)
    // 8-9: X origin
    header.writeUInt16LE(0, 8)
    // 10-11: Y origin
    header.writeUInt16LE(0, 10)
    // 12-13: Width (little-endian)
    header.writeUInt16LE(width, 12)
    // 14-15: Height (little-endian)
    header.writeUInt16LE(height, 14)
    // 16: Bits per pixel (32 for BGRA)
    header.writeUInt8(32, 16)
    // 17: Image descriptor
    // - bit 5 set (0x20): origin at top-left (matches Sharp raw buffer order)
    // - lower 4 bits set to 8: 8 bits of alpha channel data
    header.writeUInt8(0x28, 17)
    return header
}

/**
 * Convert RGBA buffer to TGA format
 */
function createTGAFromBuffer(rgbaBuffer, width, height) {
    const header = createTGAHeader(width, height)

    // TGA uses BGRA format
    const bgraBuffer = Buffer.alloc(width * height * 4)
    for (let i = 0; i < width * height; i++) {
        const srcIdx = i * 4
        const destIdx = i * 4
        bgraBuffer[destIdx] = rgbaBuffer[srcIdx + 2]     // B
        bgraBuffer[destIdx + 1] = rgbaBuffer[srcIdx + 1] // G
        bgraBuffer[destIdx + 2] = rgbaBuffer[srcIdx]     // R
        bgraBuffer[destIdx + 3] = rgbaBuffer[srcIdx + 3] // A
    }

    // Keep top-to-bottom row order and mark origin as top-left in descriptor.
    return Buffer.concat([header, bgraBuffer])
}

/**
 * Load and resize image to 64x64 with black background
 */
async function loadAndProcessImage(sourcePath) {
    const metadata = await sharp(sourcePath).metadata()
    console.log(`Source: ${path.basename(sourcePath)} (${metadata.width}x${metadata.height})`)

    // Resize with black background (aspect ratio preserved, centered)
    const resized = await sharp(sourcePath)
        .resize(ICON_SIZE, ICON_SIZE, {
            fit: "contain",
            background: { r: 0, g: 0, b: 0, alpha: 1 }
        })
        .ensureAlpha()
        .toBuffer()

    return resized
}


// Overlay a frame image on top of the icon
async function overlayFrame(baseBuffer, framePath) {
    return await sharp(baseBuffer)
        .composite([{ input: framePath }])
        .toBuffer()
}

// Ensure raw pixel buffer is always RGBA (4 channels) before TGA packing.
async function toRawRGBA(imageBuffer) {
    const { data } = await sharp(imageBuffer)
        .ensureAlpha()
        .raw()
        .toBuffer({ resolveWithObject: true })
    return data
}


// PASBTN: overlay PASBTN frame
async function createPASBTNVersion(baseBuffer) {
    return await overlayFrame(baseBuffer, PASBTN_FRAME)
}


// DISBTN: overlay DISBTN frame
async function createDISBTNVersion(baseBuffer) {
    return await overlayFrame(baseBuffer, DISBTN_FRAME)
}


// DISPASBTN: overlay DISBTN frame (same as DISBTN)
async function createDISPASBTNVersion(baseBuffer) {
    return await overlayFrame(baseBuffer, DISBTN_FRAME)
}



/**
 * Main function to generate war3 icons
 */

async function generateIcons(sourceImagePath, outputDir, baseName) {
    console.log(`Loading image: ${sourceImagePath}`)

    const baseBuffer = await loadAndProcessImage(sourceImagePath)

    // Create output directories
    const cmdDir = path.join(outputDir, "CommandButtons")
    const cmdDisabledDir = path.join(outputDir, "CommandButtonsDisabled")
    const passiveDir = path.join(outputDir, "PassiveButtons")

    for (const dir of [cmdDir, cmdDisabledDir, passiveDir]) {
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true })
        }
    }

    // Clean base name
    const cleanBase = baseName
        .replace(/^BTN/i, "")
        .replace(/^PASBTN/i, "")
        .replace(/^DISBTN/i, "")

    const btnFileName = "BTN" + cleanBase + ".tga"
    const disBtnFileName = "DISBTN" + cleanBase + ".tga"
    const pasBtnFileName = "PASBTN" + cleanBase + ".tga"
    const disPasBtnFileName = "DISPASBTN" + cleanBase + ".tga"

    // 1. BTN - Overlay BTN frame
    console.log("Creating BTN...")
    const btnBuffer = await overlayFrame(baseBuffer, BTN_FRAME)
    const btnTga = createTGAFromBuffer(await toRawRGBA(btnBuffer), ICON_SIZE, ICON_SIZE)
    fs.writeFileSync(path.join(cmdDir, btnFileName), btnTga)
    console.log(`  Created: ${btnFileName}`)

    // 2. DISBTN - Overlay DISBTN frame
    console.log("Creating DISBTN...")
    const disBtnBuffer = await createDISBTNVersion(baseBuffer)
    const disBtnTga = createTGAFromBuffer(await toRawRGBA(disBtnBuffer), ICON_SIZE, ICON_SIZE)
    fs.writeFileSync(path.join(cmdDisabledDir, disBtnFileName), disBtnTga)
    console.log(`  Created: ${disBtnFileName}`)

    // 3. PASBTN - Overlay PASBTN frame
    console.log("Creating PASBTN...")
    const pasBtnBuffer = await createPASBTNVersion(baseBuffer)
    const pasBtnTga = createTGAFromBuffer(await toRawRGBA(pasBtnBuffer), ICON_SIZE, ICON_SIZE)
    fs.writeFileSync(path.join(passiveDir, pasBtnFileName), pasBtnTga)
    console.log(`  Created: ${pasBtnFileName}`)

    // 4. DISPASBTN - Overlay DISBTN frame (same as DISBTN)
    console.log("Creating DISPASBTN...")
    const disPasBtnBuffer = await createDISPASBTNVersion(baseBuffer)
    const disPasBtnTga = createTGAFromBuffer(await toRawRGBA(disPasBtnBuffer), ICON_SIZE, ICON_SIZE)
    fs.writeFileSync(path.join(cmdDisabledDir, disPasBtnFileName), disPasBtnTga)
    console.log(`  Created: ${disPasBtnFileName}`)

    console.log("\nGenerated icons:")
    console.log(`  BTN:      ${path.relative(outputDir, path.join(cmdDir, btnFileName))}`)
    console.log(`  DISBTN:   ${path.relative(outputDir, path.join(cmdDisabledDir, disBtnFileName))}`)
    console.log(`  PASBTN:   ${path.relative(outputDir, path.join(passiveDir, pasBtnFileName))}`)
    console.log(`  DISPASBTN: ${path.relative(outputDir, path.join(cmdDisabledDir, disPasBtnFileName))}`)
}

/**
 * Batch process multiple images
 */
async function batchGenerate(inputDir, outputDir) {
    if (!fs.existsSync(inputDir)) {
        console.error(`Input directory not found: ${inputDir}`)
        process.exit(1)
    }

    const files = fs.readdirSync(inputDir)
        .filter(f => /\.(png|jpg|jpeg)$/i.test(f))

    if (files.length === 0) {
        console.error("No image files found in input directory")
        process.exit(1)
    }

    console.log(`Found ${files.length} image(s) to process\n`)

    for (const file of files) {
        const sourcePath = path.join(inputDir, file)
        const baseName = path.basename(file, path.extname(file))

        try {
            console.log(`\n[${files.indexOf(file) + 1}/${files.length}] Processing: ${file}`)
            await generateIcons(sourcePath, outputDir, baseName)
        } catch (error) {
            console.error(`  Error: ${error.message}`)
        }
    }

    console.log(`\n\nBatch complete! Processed ${files.length} icon(s)`)
}

// CLI interface
async function main() {
    const args = process.argv.slice(2)

    if (args.length < 1) {
        console.log(`
War3 Icon Generator
====================
Generates 64x64 TGA icons for Warcraft 3 with proper button styles.

Usage: node icon-gen.js <source_image> [output_dir] [base_name]
   or: node icon-gen.js --batch <input_dir> <output_dir>

Options:
  source_image   Path to source image (PNG or JPEG)
  output_dir     Output directory (default: ./output)
  base_name      Base name for icon files (default: extracted from source)
  --batch        Batch mode: process all images in input_dir

Icon Styles:
  - BTN:      Silver embossed border (bright top-left, dark bottom-right)
  - DISBTN:   BTN with 60% brightness (saturation unchanged)
  - PASBTN:   No border, edge fade-out effect
  - DISPASBTN: PASBTN with 60% brightness (saturation unchanged)

Examples:
  # Single icon
  node tools/icon-gen.js ./textures/ability_paladin_crusaderstrike.jpg ./moonglade.w3x/ReplaceableTextures CrusaderStrike

  # Batch process
  node tools/icon-gen.js --batch ./textures ./moonglade.w3x/ReplaceableTextures
`)
        process.exit(1)
    }

    if (args[0] === "--batch") {
        const inputDir = args[1]
        const outputDir = args[2] || path.join(__dirname, "ReplaceableTextures")

        if (!inputDir) {
            console.error("Error: Input directory required for batch mode")
            process.exit(1)
        }

        await batchGenerate(inputDir, outputDir)
    } else {
        const sourceImage = args[0]
        const outputDir = args[1] || path.join(__dirname, "ReplaceableTextures")
        const baseName = args[2] || path.basename(sourceImage, path.extname(sourceImage))

        if (!fs.existsSync(sourceImage)) {
            console.error(`Error: Source image not found: ${sourceImage}`)
            process.exit(1)
        }

        await generateIcons(sourceImage, outputDir, baseName)
    }
}

main()

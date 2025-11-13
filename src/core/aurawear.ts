#!/usr/bin/env ts-node
import { spawnSync } from "child_process";
import { writeFileSync, existsSync } from "fs";
import { join, resolve } from "path";
import { argv } from "process";
import { fileURLToPath } from "url";

/* --------------------------------------------------------------
   Resolve the directory of this script (so we can locate the Python
   helper that lives next to it).  -------------------------------------------------------------- */
const __dirname = fileURLToPath(new URL(".", import.meta.url));
const PYTHON_SCRIPT = join(__dirname, "aurawear_helper.py");

/* --------------------------------------------------------------
   Run the Python helper with the supplied prompt.
   The helper returns a JSON string on stdout that contains:
     - prompt
     - image_path
     - audio_path
     - model_path
   -------------------------------------------------------------- */
function runHelper(prompt: string) {
    const result = spawnSync("python3", [PYTHON_SCRIPT, prompt], {
        encoding: "utf8",
        cwd: __dirname,
    });

    if (result.error) {
        console.error("⚠️  Failed to start Python helper:", result.error);
        process.exit(1);
    }

    if (result.status !== 0) {
        console.error("⚠️  Python helper exited with error:", result.stderr);
        process.exit(result.status);
    }

    return JSON.parse(result.stdout);
}

/* --------------------------------------------------------------
   Write a tiny JSON diary (log.json) in the current working dir.
   -------------------------------------------------------------- */
function writeDiary(entry: any) {
    const diary = join(process.cwd(), "log.json");
    if (existsSync(diary)) {
        const existing = JSON.parse(readFileSync(diary, "utf8"));
        existing.push(entry);
        writeFileSync(diary, JSON.stringify(existing, null, 2));
    } else {
        writeFileSync(diary, JSON.stringify([entry], null, 2));
    }
}

/* --------------------------------------------------------------
   Main entry point.
   -------------------------------------------------------------- */
function main() {
    const prompt = argv.slice(2).join(" ").trim();
    if (!prompt) {
        console.log("Usage: aurawear \"<text prompt>\"");
        process.exit(0);
    }

    console.log(`🔮  Generating for prompt: "${prompt}"`);
    const result = runHelper(prompt);

    console.log(`🖼️  Image saved to ${result.image_path}`);
    console.log(`🎵  Audio saved to ${result.audio_path}`);
    console.log(`🗿  3D model saved to ${result.model_path}`);

    writeDiary(result);
    console.log("📓  Diary entry added to log.json");
}

main();

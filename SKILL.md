---
name: unlock-music-decode
description: Decode encrypted music files with Unlock Music CLI. Use when the user says "获取原始文件", "解码音乐文件", "还原原始音频", or asks to process encrypted music formats such as ncm, qmc, mflac, mgg, kgm, kwm, tm, xiami, or ximalaya files. The skill ensures um-darwin-arm64 is available before decoding.
---

# Unlock Music Decode

## Workflow

Use this skill to recover original audio files from encrypted music files with `um-darwin-arm64`.

1. Identify the input file or directory from the user request. If the user only says "获取原始文件" without a path, inspect the current working directory for likely encrypted music files before asking.
2. Ensure the CLI is available:

   ```bash
   ~/.codex/skills/unlock-music-decode/scripts/ensure_um_darwin_arm64.sh --print-path
   ```

   The script checks `PATH`, then `~/.codex/tools/unlock-music/v0.2.12/um-darwin-arm64`, then tries the official release download. If the release URL is blocked by Cloudflare, it builds the same version from `unlock-music.dev/cli@v0.2.12`.

3. Decode with an explicit output directory:

   ```bash
   ~/.codex/skills/unlock-music-decode/scripts/decode_original.sh /path/to/input /path/to/output
   ```

4. Report the output directory and important command output. Do not delete source files unless the user explicitly asks for that.

## Direct CLI Usage

`um-darwin-arm64 --help` shows the core usage:

```text
um [-o /path/to/output/dir] [--extra-flags] [-i] /path/to/input
```

Important flags:

- `-i`, `--input`: input file or directory.
- `-o`, `--output`: output directory.
- `--overwrite`: overwrite existing output files.
- `--supported-ext`: print supported extensions.
- `--qmc-mmkv`, `--qmc-mmkv-key`: use when QMC files require an MMKV database/key.
- `--remove-source`: only use when the user explicitly asks to remove source files.

## Output Handling

Prefer a sibling output directory named `original-files` when the user does not specify one. For a single input file, place `original-files` next to the file. For a directory input, place `original-files` inside that directory unless that would mix source and output in an unsafe way.

After decoding, list newly created files with sizes when practical:

```bash
find /path/to/output -maxdepth 2 -type f -print
```

If decoding fails, rerun with `--verbose` once and report the concise failure reason.

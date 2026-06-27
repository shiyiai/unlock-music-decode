# Unlock Music Decode

这是一个用于 Codex 的音乐解码 skill，主要封装 Unlock Music CLI，帮助从常见的加密音乐文件中还原原始音频文件。

## 适用场景

当用户提出以下需求时，可以使用这个 skill：

- 获取原始文件
- 解码音乐文件
- 还原原始音频
- 处理 `.ncm`、`.qmc`、`.mflac`、`.mgg`、`.kgm`、`.kwm`、`.tm`、虾米、喜马拉雅等加密音乐格式

本仓库不会删除源文件。只有在用户明确要求删除源文件时，才应使用 Unlock Music CLI 的 `--remove-source` 参数。

## 文件说明

- `SKILL.md`：Codex skill 入口说明，定义触发场景和执行流程。
- `agents/openai.yaml`：Codex 中展示该 skill 的名称、简介和默认提示词。
- `scripts/ensure_um_darwin_arm64.sh`：检查并准备 `um-darwin-arm64` 命令。
- `scripts/decode_original.sh`：对输入文件或目录执行解码，并输出到指定目录。

## 安装到 Codex

推荐直接克隆到 Codex 的个人 skill 目录：

```bash
mkdir -p ~/.codex/skills
git clone git@github.com:shiyiai/unlock-music-decode.git ~/.codex/skills/unlock-music-decode
```

安装后，目录结构应类似：

```text
~/.codex/skills/unlock-music-decode/
├── SKILL.md
├── README.md
├── agents/
└── scripts/
```

如果本地已经存在该目录，需要更新到最新版本：

```bash
cd ~/.codex/skills/unlock-music-decode
git pull
```

安装完成后，重启 Codex 或开启新的 Codex 会话，让 skill 列表重新加载。之后在对话里说“获取原始文件”“解码音乐文件”等需求时，Codex 就可以按 `SKILL.md` 中的流程调用这个 skill。

## CLI 准备逻辑

`ensure_um_darwin_arm64.sh` 会按以下顺序查找或安装 Unlock Music CLI：

1. 优先使用当前 `PATH` 中已有的 `um-darwin-arm64`。
2. 如果不存在，则检查 `~/.codex/tools/unlock-music/v0.2.12/um-darwin-arm64`。
3. 如果本地仍不存在，则尝试从官方 release 下载 `v0.2.12`。
4. 如果下载失败，并且本机安装了 Go，则从 `unlock-music.dev/cli@v0.2.12` 构建同版本二进制。

查看最终可用的 CLI 路径：

```bash
~/.codex/skills/unlock-music-decode/scripts/ensure_um_darwin_arm64.sh --print-path
```

## 使用方式

解码单个文件：

```bash
~/.codex/skills/unlock-music-decode/scripts/decode_original.sh /path/to/song.ncm /path/to/output
```

解码整个目录：

```bash
~/.codex/skills/unlock-music-decode/scripts/decode_original.sh /path/to/songs /path/to/output
```

如果没有传入输出目录，脚本会自动使用 `original-files`：

- 输入是单个文件时，输出到该文件同级目录下的 `original-files`。
- 输入是目录时，输出到该目录内的 `original-files`。

可以继续向 Unlock Music CLI 透传额外参数，例如覆盖已存在文件：

```bash
~/.codex/skills/unlock-music-decode/scripts/decode_original.sh /path/to/songs /path/to/output --overwrite
```

## 常用参数

底层 CLI 的基本用法是：

```text
um [-o /path/to/output/dir] [--extra-flags] [-i] /path/to/input
```

常用参数包括：

- `-i, --input`：输入文件或目录。
- `-o, --output`：输出目录。
- `--overwrite`：覆盖已存在的输出文件。
- `--supported-ext`：查看支持的文件扩展名。
- `--qmc-mmkv`、`--qmc-mmkv-key`：处理部分需要 MMKV 数据库或密钥的 QMC 文件。
- `--remove-source`：删除源文件，仅在用户明确要求时使用。

## 输出检查

解码完成后，可以查看输出文件：

```bash
find /path/to/output -maxdepth 2 -type f -print
```

如果解码失败，建议使用 `--verbose` 重新执行一次，保留关键错误信息用于定位问题。

## 注意事项

- 请只处理用户有权访问和转换的音乐文件。
- 解码脚本默认保留源文件。
- 下载或构建 CLI 需要网络访问；如果官方 release 被拦截，脚本会尝试 Go 构建 fallback。
- 当前脚本面向 macOS Apple Silicon，使用的二进制名称是 `um-darwin-arm64`。

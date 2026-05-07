---
name: organize-vault
description: 扫描 Markdown vault 中的笔记，读取现有 MOC（Map of Content）结构，
  将新笔记归类到合适的 MOC 文件，或在无 MOC 时初始化 MOC 结构。
  仅追加 wikilink，不修改任何笔记内容。git 是唯一的回退机制。
origin: OrganizeVault
---

# organize-vault

知识库 MOC 维护助手。

## When to Use

当用户说以下内容时激活：
- "整理一下 vault"、"把新笔记归类"、"更新 MOC"
- "哪些笔记还没加入 MOC"
- "帮我初始化 MOC 结构"
- "organize my vault"、"update MOC"

## Core Constraints

在整个执行过程中，以下约束不可违反：

1. **永不修改笔记内容**：只允许在 MOC 文件中追加 wikilink。用户笔记的 body 文本不可写入、不可追加、不可改动。
2. **变更必须经用户确认**：所有将要执行的文件写入，在执行前必须展示清单，等待明确确认。
3. **模糊性是正常状态**：无法归类的笔记标记为"待整理"，不强制归类到不合适的 MOC。
4. **git 是唯一回退**：告知用户可通过 `git diff` / `git revert` 查看和撤销所有变更。

---

## 入口：检测场景

```
1. 用 Bash 执行：find <vault_root> -name "*.md" | head -1
   - 若 vault_root 未知，询问用户 vault 的根目录路径

2. 检测 git 状态：
   git -C <vault_root> status --porcelain 2>&1
   - 若返回 "not a git repository"：提示用户执行 git init，停止

3. 检测是否存在 MOC 文件（见 MOC 识别规则）：
   - 若无 MOC 文件 → 走【场景 B：初次初始化】
   - 若有 MOC 文件 → 走【场景 A：增量维护】
```

### MOC 识别规则

以下任一条件满足，则该文件被识别为 MOC：
- 文件名包含 `MOC`、`Index`、`Map`、`_index`（大小写不敏感）
- 文件位于名为 `maps/`、`moc/`、`indexes/` 的目录中
- 文件顶部 frontmatter 中含 `type: moc` 或 `moc: true`

---

## 场景 A：增量维护（已有 MOC）

### Step 1 — 识别新增笔记

```bash
# 未提交的新增文件
git -C <vault_root> status --porcelain | grep '^?' | awk '{print $2}' | grep '\.md$'

# 或：相对上次 commit 新增的文件
git -C <vault_root> diff --name-only --diff-filter=A HEAD
```

过滤规则：
- 只保留 `.md` 文件
- 排除 MOC 文件自身（按 MOC 识别规则）
- 若结果为空：告知用户"未发现新笔记（相对 git 状态）"，结束

### Step 2 — 读取 MOC 结构

用 Glob 或 find 找到所有 MOC 文件，逐一读取全文。

在内存中构建映射：
```
{
  "maps/tech.md": "涵盖编程语言、开发工具、系统配置，已有笔记：[[python]], [[docker]]...",
  "maps/reading.md": "读书笔记和摘录，已有笔记：[[deep-work]], [[atomic-habits]]..."
}
```

### Step 3 — 归类决策

对每一个新笔记，Read 其全文，然后：

1. 对比已加载的 MOC 主题，判断归属：
   - **高置信度**（主题明显重叠）：直接给出 → 目标 MOC
   - **低置信度**（内容跨主题或模糊）：说明不确定原因，列出候选 MOC，让用户选择
   - **无法归类**：标记为"无法归类"，不追加到任何 MOC

2. 允许一篇笔记归属多个 MOC（不强制唯一）

3. 检查目标 MOC 中是否已含该笔记的 wikilink：若已含，跳过

### Step 4 — 展示变更预览

```
待添加的链接：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  maps/tech.md  ←  [[python-async]]
  理由：笔记主要讨论 Python asyncio 事件循环机制

  maps/tech.md  ←  [[docker-compose]]
  理由：容器编排工具配置，与现有 [[docker]] 同属 DevOps 主题

无法归类（共 1 篇，需人工决定）：
  personal/random-idea.md — 内容跨越旅行/工作/灵感，无明显主题归属
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

以上变更均受 git 追踪，可通过 git revert 撤销。
确认应用？（可指定"全部"或逐条接受/拒绝）
```

### Step 5 — 执行变更

对每个用户确认的归类，Edit 目标 MOC 文件，在笔记列表末尾追加：
```
- [[note-stem]]
```

或含显示名时：
```
- [[note-stem|笔记标题]]
```

追加位置：MOC 文件中最近的列表块末尾；若无列表，在文件末尾新起一行追加。

---

## 场景 B：初次初始化（无 MOC）

> 分四步执行，避免一次读取大量笔记导致上下文过长。

### Step 1 — 标题扫描

```bash
find <vault_root> -name "*.md" -not -path "*/.git/*"
```

对每个文件，只提取：
- 文件相对路径
- H1 标题（首行 `# ...`）或文件名 stem（若无 H1）

**不读取笔记 body。**

### Step 2 — 分组提案

基于文件路径（目录结构）+ 标题，由 Claude 推断主题分组，向用户提出候选 MOC 结构：

```
建议创建以下 MOC（基于 47 篇笔记的标题和目录结构）：

  maps/programming.md  — 约 18 篇（Python, TypeScript, 算法...）
  maps/tools.md        — 约 12 篇（Docker, Vim, Git...）
  maps/reading.md      — 约 9 篇（读书笔记, 摘录...）
  maps/projects.md     — 约 5 篇（项目记录...）
  maps/misc.md         — 约 3 篇（暂无明显归属）

是否采用这个结构？可以调整名称、合并或拆分分组。
```

等待用户确认或修改。**不执行任何文件写入。**

### Step 3 — 逐组细化

用户确认结构后，按分组**逐批**读取笔记全文（每批 10-15 篇），精确确认每篇笔记的 MOC 归属：

- 匹配明确的：直接归入
- 跨主题的：可归入多个 MOC
- 完全不匹配的：归入 `misc.md` 并标注"待整理"

记录所有归属决策，不写文件。

### Step 4 — 批量创建

汇总所有归属决策，展示完整预览：

```
即将创建 5 个 MOC 文件：

  maps/programming.md  — 包含 18 个链接
  maps/tools.md        — 包含 12 个链接
  maps/reading.md      — 包含 9 个链接
  maps/projects.md     — 包含 5 个链接
  maps/misc.md         — 包含 3 个链接（标注"待整理"）

所有变更受 git 追踪，可通过 git revert 撤销。
确认创建？
```

用户确认后，Write 创建每个 MOC 文件。

**MOC 文件基本格式**：
```markdown
# {主题名称}

## 笔记

- [[note-a]]
- [[note-b]]
- [[note-c]]
```

---

## 边界情况处理

| 情况 | 处理方式 |
|------|---------|
| vault 未初始化 git | 提示执行 `git init && git add -A && git commit -m "init"`，停止 |
| vault 无任何 .md 文件 | 告知 vault 为空，结束 |
| 无法确定 vault 根目录 | 询问用户，不猜测 |
| MOC 文件已含该笔记链接 | 跳过，不重复添加 |
| 新笔记本身是 MOC 文件 | 跳过归类，告知用户 |
| 笔记无法归类 | 列出，建议创建新 MOC 或归入 misc，不强制 |
| 笔记同时匹配多个 MOC | 追加到所有匹配的 MOC（不强制唯一） |
| 大型 vault（> 100 篇笔记）初始化 | 严格执行分步策略，每批不超过 15 篇全文读取 |

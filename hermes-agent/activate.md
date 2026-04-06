# activate.md — 激活 human-like 自主思考系统

请将此文件内容发送给 Hermes Agent，让 Agent 执行以下操作。

---

## 激活指令（请依次执行）

### 第一步：初始化数据

确认以下文件已存在（由 install.sh 创建）：

- `~/.hermes/human-like/thinking-state.json`
- `~/.hermes/human-like/thinking-queue.json`
- `~/.hermes/human-like/thoughts/` 目录

如果不存在，请先 `mkdir -p ~/.hermes/human-like/thoughts` 并从当前文件夹下的 `configs/` 子目录中复制配置文件。

### 第二步：创建三个 cron 任务

> 所有 payload 路径使用固定数据目录 `~/.hermes/human-like/cron-payloads/`，由 install.sh 自动复制，与项目 clone 位置无关。

**任务 1：梦境思考**

```
cronjob(
  action="create",
  name="human-like: 梦境思考",
  prompt="请读取 ~/.hermes/human-like/cron-payloads/dream-thinking.md 的内容作为指令，严格按其中描述的步骤执行。所有数据文件（state、queue、thoughts）路径均在 ~/.hermes/human-like/ 下。",
  schedule="0 */3 * * *",
  deliver="origin"
)
```

说明：每 3 小时执行一次（0:00, 3:00, 6:00...）

**任务 2：自主探索**

```
cronjob(
  action="create",
  name="human-like: 自主探索",
  prompt="请读取 ~/.hermes/human-like/cron-payloads/autonomous-exploration.md 的内容作为指令，严格按其中描述的步骤执行。",
  schedule="every 2h",
  deliver="origin"
)
```

说明：每 2 小时执行一次

**任务 3：微触发管理器**

```
cronjob(
  action="create",
  name="human-like: 微触发",
  prompt="请读取 ~/.hermes/human-like/cron-payloads/micro-trigger-manager.md 的内容作为指令，严格按其中描述的步骤执行。",
  schedule="every 5m",
  deliver="origin"
)
```

说明：每 10 分钟初始化一次，运行时会检查用户活跃度并自我调整 cron 间隔：用户在 7-13 分钟，用户离线 31-64 分钟。

### 第三步：记录 cron ID

创建完成后，**仅写入运行时文件** `~/.hermes/human-like/thinking-state.json`，不要修改项目目录下的模板文件。

将返回的三个 cron job_id 分别写入：
- `dreamCronId`
- `explorationCronId`
- `microCronId`

如果 cronjob 创建结果没有返回 job_id，使用 `cronjob(action="list")` 查看并用名称匹配。

### 第四步：确认

运行 `cronjob(action="list")` 确认三个任务都已创建且状态正常。

报告结果给用户。

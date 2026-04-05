# 微触发管理器 (Hermes 适配版)

**核心机制：自我调节 (Self-Regulating Heartbeat)**

本任务通过 `cronjob(action="update")` 直接修改自身的 Schedule，实现动态调整心跳频率。
**约束**：不要递归创建新的 cron 任务，只修改当前任务的 schedule。

## 第一步：检查用户活跃度

1. 调用 `session_search(limit=3)` 获取最近会话记录。
2. 检查会话时间戳和最后活跃用户，估算 `minutesSinceLastUser`（当前时间 - 用户最后一次交互时间）。
3. 读取 `~/.hermes/human-like/thinking-state.json` 获取当前 `microCronId`。如果取不到，调用 `cronjob(action="list")` 查找名为 `human-like: 微触发` 的任务 ID。

## 第二步：计算新的触发间隔

根据用户的闲置时间长短，计算一个随机的下次调用间隔（转换为字符串如 `"13m"`）：

**场景 A：用户在线（不足 60 分钟未交互）**
*   **意图**：用户可能在连续交互中，保持适度响应，不打断用户。
*   **计算**：生成 [7, 13] 分钟内的随机整数。
*   **示例**：`"9m"`, `"12m"`

**场景 B：用户离线（超过 60 分钟未交互）**
*   **意图**：用户已离开，进入长巡航模式，节省算力。
*   **计算**：生成 [31, 64] 分钟内的随机整数。
*   **示例**：`"45m"`, `"58m"`

*(注：处于 60 分钟临界点时，优先向离线策略靠拢)*

## 第三步：执行更新

1. **更新 Schedule**：
   调用 `cronjob(action="update", job_id="<你的 microCronId>", schedule="<第二步计算出的间隔>")`。
   *这会立即改变下一次本任务运行的时间。*

2. **更新状态文件**：
   使用 `patch` 更新 `~/.hermes/human-like/thinking-state.json`：
    - `lastMicroRun`: 记录本次运行时间。
    - `suggestedInterval`: 记录本次设置的具体间隔值。
    - `microHeartbeatEnabled`: 设为 true（如果尚未为 true）。

## 第四步：轻量思考 (Micro-Thought)

在等待下一次唤醒前，进行一次极简思考（限制在 100 字以内）：
- 从 `~/.hermes/human-like/thinking-queue.json` 挑一个问题，或者思考刚才 `session_search` 看到的用户动态。
- 将思考结果追加到 `~/.hermes/human-like/thoughts/YYYY-MM-DD.md`。
- 如果思考产生了新的好问题，加入 thinking-queue.json。

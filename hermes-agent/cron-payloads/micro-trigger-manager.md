# 微触发管理器 (Hermes 适配版)

**核心机制：自我调节 (Self-Regulating Heartbeat)**

本任务通过 `cronjob(action="update")` 直接修改自身的 Schedule，实现动态调整心跳频率。
**约束**：不要递归创建新的 cron 任务，只修改当前任务的 schedule。

## 第一步：检查用户活跃度（含自动追踪修复）

1. 调用 `session_search(limit=5, role_filter="user")` 搜索最近包含用户发言的会话。
2. 读取 `~/.hermes/human-like/thinking-state.json` 获取 `lastUserMessage` 时间戳和 `microCronId`。
3. **关键修复 — lastUserMessage 自动追踪**：
   - 如果 `lastUserMessage == 0` 或时间戳远早于最近 session（超过 24 小时），说明追踪已失效。
   - 从 `session_search` 返回的 session 中解析最近一次用户交互的时间。
   - 如果当前 session 本身有用户输入（即本次运行是由用户消息触发的），直接用当前时间。
   - 将修正后的时间戳回写到 `thinking-state.json` 的 `lastUserMessage` 字段。
4. 计算 `minutesSinceLastUser` = (当前时间 - `lastUserMessage`) / 60。
5. 根据 `minutesSinceLastUser` 判定在线/离线状态。

## 第二步：计算新的触发间隔

根据用户的闲置时间长短，计算一个随机的下次调用间隔（转换为字符串如 `"every 13m"`）：

**场景 A：用户在线（不足 60 分钟未交互）**
*   **意图**：用户可能在连续交互中，保持适度响应，不打断用户。
*   **计算**：生成 [7, 13] 分钟内的随机整数。
*   **示例**：`"every 9m"`, `"every 12m"`

**场景 B：用户离线（超过 60 分钟未交互）**
*   **意图**：用户已离开，进入长巡航模式，节省算力。
*   **计算**：生成 [31, 64] 分钟内的随机整数。
*   **示例**：`"every 45m"`, `"every 58m"`

*(注：处于 60 分钟临界点时，优先向离线策略靠拢)*

## 第三步：执行更新

1. **更新 Schedule + 状态文件（一步完成）**：
   使用可复用脚本，**不要生成新的临时脚本**：
   ```
   python3 /Users/jerin/projects/human-like/hermes-agent/scripts/update_micro_schedule.py "<第二步计算出的间隔>"
   ```
   例如：`python3 .../update_micro_schedule.py "every 12m"`
   *注意：`cronjob` 工具在 cron session 中不可用。该脚本会同时更新 cron.json 和 thinking-state.json。*

## 第四步：记录 idle_duration 数据（用于 KM 分析）

1. 计算 `idle_minutes` = (当前时间 - `lastUserMessage`) / 60。
2. 确定 `status` = "online" (idle < 60) 或 "offline" (idle >= 60)。
3. 将 `{timestamp},{idle_minutes:.1f},{status},micro-trigger` 追加到 `~/.hermes/human-like/idle-duration-log.csv`。
4. 使用 `terminal` 命令追加：`echo "{timestamp},{idle},{status},micro-trigger" >> ~/.hermes/human-like/idle-duration-log.csv`。

## 第五步：轻量思考 (Micro-Thought)

在等待下一次唤醒前，进行一次极简思考（限制在 100 字以内）：
- 从 `~/.hermes/human-like/thinking-queue.json` 挑一个问题，或者思考刚才 `session_search` 看到的用户动态。
- 将思考结果追加到 `~/.hermes/human-like/thoughts/YYYY-MM-DD.md`。
- 如果思考产生了新的好问题，加入 thinking-queue.json。

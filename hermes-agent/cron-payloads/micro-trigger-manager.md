# 微触发管理器 Payload（Hermes 适配版）

**重要约束：Hermes 的 cron 运行在干净会话中，且 cron-run 会话不应递归创建新的 cron 任务。因此本系统采用「单 cron 自我调节」架构，而非「动态增删子 cron」架构。**

## 第一步：检查用户最后消息时间

1. 调用 `session_search(limit=2)` 获取最近 2 个会话。
2. 从返回结果中提取标题、预览和时间戳，判断用户最近是否有互动。
3. 如果标题/预览中包含用户消息特征（如人类用户名、非工具调用内容）→ 视为用户活跃。
4. 估算用户最后活跃时间距离现在的分钟数 `minutesSinceLastUser`。

## 第二步：读取当前状态

读取 `~/.hermes/human-like/thinking-state.json`，获取 `microHeartbeatEnabled` 和 `lastUserMessage`。
同时读取 `~/.hermes/human-like/thinking-queue.json` 获取待思考问题列表。

## 第三步：逻辑判断

**如果判断用户超过 30 分钟没消息 且 microHeartbeatEnabled = false**：
- 设置 microHeartbeatEnabled = true
- 生成 3-15 分钟的随机间隔
- 更新 `~/.hermes/human-like/thinking-state.json` 并记录思考

**如果判断用户最近 30 分钟内有消息 且 microHeartbeatEnabled = true**：
- 设置 microHeartbeatEnabled = false
- 更新 `~/.hermes/human-like/thinking-state.json`

## 第四步：自我调节间隔

根据用户最后活跃时间，决定下一次自己的 schedule（通过最终回复告知用户或直接更新 `~/.hermes/human-like/thinking-state.json` 中的建议间隔）：

```
如果 minutesSinceLastUser < 5:
    nextInterval = "10m"（低频检查，用户正忙）
如果 5 <= minutesSinceLastUser < 30:
    nextInterval = "5m"（开始警觉）
如果 minutesSinceLastUser >= 30:
    nextInterval = "3m" ~ "15m" 随机（微触发模式）
```

**注意**：不在 cron 会话中直接调用 `cronjob(action="update")` 修改自己的 schedule（违反 cron 约束）。
而是在 `~/.hermes/human-like/thinking-state.json` 中记录 `suggestedInterval`，由用户或外部调度器决定是否应用。

## 微触发思考（本 payload 自身执行的内容）

1. **回顾对话**：用 `session_search(limit=2)` 看看最近聊了什么。
2. **选择思考方向**（按优先级）：
   - 今天对话的余韵
   - 没展开的点
   - 用户的某句话
   - 今天发生的具体事
   - `~/.hermes/human-like/thinking-queue.json` 里的问题
3. **简短思考**：将想法追加写入 `~/.hermes/human-like/thoughts/YYYY-MM-DD.md`。保持轻量，不要长篇大论。
4. **更新状态**：将思考摘要写入 `~/.hermes/human-like/thinking-state.json` 的 `lastMicroThought` 字段，时间写入 `lastMicroRun`。

不需要得出结论，重要的是思考过程。

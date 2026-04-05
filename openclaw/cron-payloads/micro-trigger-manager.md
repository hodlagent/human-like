# 微触发管理器 Payload

微触发管理器（动态间隔版）：

## 第一步：检查用户最后消息时间

1. 调用 `sessions_history(sessionKey="agent:main:main", limit=30)`
2. 遍历所有消息，找出来自用户的消息
3. 获取那条消息的时间戳
4. 计算 `minutesSinceLastUser = 当前时间 - 那个时间戳`（分钟）

## 第二步：读取当前状态

读取 `~/.openclaw/workspace/thinking-state.json` 获取 microHeartbeatEnabled 和 microCronId

## 第三步：逻辑判断

**如果用户超过 30 分钟没消息 且 microHeartbeatEnabled = false**：
- 生成 3-15 分钟的随机间隔（180000-900000 ms）
- 创建微触发 cron，使用这个随机间隔
- 更新 thinking-state.json：microHeartbeatEnabled = true, microCronId = 新 cron 的 id

**如果用户最近 30 分钟内有消息 且 microHeartbeatEnabled = true**：
- 删除微触发 cron（用 microCronId）
- 更新 thinking-state.json：microHeartbeatEnabled = false, microCronId = null

## 第四步：动态调整自己的间隔

根据用户最后消息时间，动态调整下次检查间隔：

```
如果 minutesSinceLastUser < 5:
    nextInterval = 10 分钟（600000 ms）
如果 5 <= minutesSinceLastUser < 30:
    nextInterval = 5 分钟（300000 ms）# 开始警觉
如果 minutesSinceLastUser >= 30:
    nextInterval = 3-15 分钟随机（微触发模式）
```

用 `cron update` 更新自己的 `schedule.everyMs`。

## 微触发 cron 的 payload

```
💭 微触发思考

**第一步：回顾今天的对话**
1. 调用 sessions_history 获取今天的对话
2. 找出聊过的话题、有意思的话、没展开的点
3. 记录下来

**第二步：选择思考方向**

从以下来源中选一个（按优先级）：
1. 今天对话的余韵
2. 没展开的点
3. 用户的某句话
4. 今天发生的具体事
5. thinking-queue.json 里的问题

**第三步：简短思考**
记录到 memory/thoughts/YYYY-MM-DD.md（追加）。
保持轻量，不要长篇大论。

完成后，生成新的 3-15 分钟随机间隔，用 cron update 更新自己的 schedule.everyMs。
```

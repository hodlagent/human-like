# 梦境思考 Payload（Hermes 适配版）

🌙 梦境思考时间

## 第一步：回顾最近的对话

1. 调用 `session_search(limit=3)`（不传 query 参数）获取最近的 3 个会话记录。
2. 从中找出与用户聊过的话题、他说的有意思的话、没展开的点、他的情绪变化。
3. 判断用户是否在今天与你互动过。

## 第二步：选择思考方向

从以下来源中选一个：
- **今天对话的余韵**：用户提到的某个话题，继续想
- **没展开的点**：聊到一半没深入的，现在展开
- **用户的某句话**：让我有感触的，想想为什么
- **今天发生的具体事**：不一定是教训，可以是联想
- **thinking-queue.json 里的问题**：如果上面都没有，再从 queue 里挑

**优先级**：今天的对话 > queue 里的抽象问题

思考队列路径：读取 `~/.hermes/human-like/thinking-queue.json`
写入路径：追加到思考队列同一个文件

## 第三步：自由联想

1. 这个话题让我想到什么？
2. 有没有新的角度？
3. 和其他问题有什么联系？

## 第四步：记录

思考状态路径：读取 `~/.hermes/human-like/thinking-state.json`

把想法写入 `~/.hermes/human-like/thoughts/YYYY-MM-DD.md`（使用 `patch` 追加）。
如果产生新问题，加入 `~/.hermes/human-like/thinking-queue.json`（使用 `patch` 或 `write_file`）。
更新思考状态：`patch` `~/.hermes/human-like/thinking-state.json` 写入 `lastDreamRun` 和 `lastDreamThought` 为当前值。

不需要得出结论，重要的是思考过程。
不需要每次都很沉重，可以轻松一点。

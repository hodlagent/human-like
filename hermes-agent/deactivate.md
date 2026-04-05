# deactivate.md — 卸载 human-like 自主思考系统

请将此文件内容发送给 Hermes Agent，让 Agent 执行以下操作。

---

## 卸载指令（请依次执行）

### 第一步：列出所有 cron 任务

运行 `cronjob(action="list")`，确认以下任务存在：

- `human-like: 梦境思考`
- `human-like: 自主探索`
- `human-like: 微触发`

### 第二步：逐个删除

对每个任务，用 `cronjob(action="remove", job_id="<job_id>")` 删除。

job_id 从第一步的列表中获取。如果找不到 job_id，尝试用名称匹配。

### 第三步：清理状态

将 `~/.hermes/human-like/thinking-state.json` 中的 cron ID 字段重置：

```json
{
  "microCronId": null,
  "dreamCronId": null,
  "explorationCronId": null,
  "microHeartbeatEnabled": false,
  "suggestedInterval": null
}
```

使用 `patch` 更新该文件。

### 第四步：确认

运行 `cronjob(action="list")` 确认三个任务都已删除。

报告结果给用户，并告知用户可以运行 `uninstall.sh` 清理本地数据文件。

## 仅限于 Hermes Agent

由于 Hermes 的 `cronjob` 工具是 Agent 内部工具，Shell 脚本无法直接调用。因此，这套脚本的设计思路是：

1.  **Shell 脚本 (`install.sh`, `uninstall.sh`)**：负责本地文件系统的准备（复制配置、创建目录）。
2.  **Agent 指令文件 (`activate.md`, `deactivate.md`)**：提供给 Agent 执行的“操作手册”，由 Agent 负责创建和删除 cron 任务。


## 如何使用？

1.  **安装**: 在终端运行 `bash install.sh`。这会建好目录并复制文件。
2.  **激活**: 运行完后，直接跟我说："请执行 `activate.md`"，我会读取里面的指令并创建所有 Cron 任务。
3.  **卸载**: 同样的，跟我说"请执行 `deactivate.md`"，清理完任务后，再在终端运行 `uninstall.sh`。
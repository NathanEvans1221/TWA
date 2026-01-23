---
name: bubblewrap_troubleshooter
description: Automatically handles common Bubblewrap build issues like connection errors and JVM memory limits.
---

# Bubblewrap Troubleshooter

這項技能旨在解決 Bubblewrap 建置過程中常見的問題，特別是記憶體不足與連線問題。

## 功能

1.  **自動化建置工具**：提供封裝好的 PowerShell 腳本，自動執行更新、修正配置並建置。
2.  **記憶體修正**：自動將 `gradle.properties` 中的 JVM 記憶體設定從預設的 `1536m` 降低至 `512m`。

## 使用方法

### 自動化建置 (推薦)

使用此 Skill 提供的腳本來進行建置。假設您在專案根目錄：

```powershell
# 執行 skills 內的建置腳本，並指定 android 專案路徑
.agent/skills/bubblewrap_troubleshooter/scripts/build.ps1 -AppDirectory android-app
```

如果您已經在 `android-app` 目錄內：

```powershell
../.agent/skills/bubblewrap_troubleshooter/scripts/build.ps1
```

此腳本會依序執行：
1. `bubblewrap update` (更新專案)
2. 修改 `gradle.properties` (修正記憶體)
3. `bubblewrap build` (建置 APK)

### 手動排解

若需手動操作，核心修正步驟如下：

1. 修改 `android-app/gradle.properties`：
   ```properties
   org.gradle.jvmargs=-Xmx512m
   ```

2. 若遇到 Keystore 錯誤，需刪除並重建：
   ```powershell
   Remove-Item android.keystore
   bubblewrap init --manifest http://localhost:8088/manifest.json
   ```

# 行程管家 · iOS 原生试用版（iPhone）

> 需要：**macOS + Xcode**（App Store 免费下载，约 10 GB）、iPhone、数据线、Apple ID（免费即可）。
> 这台 Windows 电脑无法编译/签名 iOS App，Mac 上的步骤是本方案唯一需要手工操作的部分。

## 一、这个工程是什么

- 原生 iOS App（SwiftUI + WKWebView），**App 内嵌单文件原型**（HTML/CSS/JS 全部内联），完全离线、不请求网络。
- 桌面图标与应用名：**行程管家**；点开即进入原型，没有地址栏。
- 原型更新后只需替换 `TripMate/Resources/index.html`（在 Windows 上用工具生成）。

## 二、Windows 上先做一步：生成内嵌页面

按 `Win + R`，粘贴下面一整行，回车：

```
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\Liuzefeng\Documents\deepseek-harness\default-workspace\trip_mate\tools\build_ios.ps1"
```

生成 `ios/TripMate/Resources/index.html`（如已存在、且原型没更新，可跳过）。
原型以后更新时，重新运行这条命令即可。

## 三、Mac 上安装到 iPhone（约 10 分钟）

1. 把整个 `trip_mate/ios` 文件夹拷到 Mac（AirDrop / U 盘 / 微信文件传输均可）。
2. 打开 Xcode（未安装：App Store 搜索 Xcode，免费安装）。
3. 双击 `ios/TripMate.xcodeproj` 打开工程。
4. 左侧点工程 `TripMate` → TARGETS 里的 `TripMate` → `Signing & Capabilities`：
   - `Team` 选择你的 Apple ID（没有的话：Xcode 菜单 → Settings → Accounts → 点“+”添加 Apple ID）；
   - `Bundle Identifier` 改成唯一值，例如 `com.liuzefeng.tripmate`（默认 `com.example.tripmate` 可能已被占用）。
5. iPhone 用数据线连 Mac，手机上点「信任此电脑」；
   然后 iPhone：**设置 → 隐私与安全性 → 开发者模式 → 打开 → 重启 iPhone**（iOS 16 及以上必须）。
6. Xcode 顶部设备选择你的 iPhone，点 **▶ Run**。
7. 首次安装后若提示“不受信任的开发者”：
   iPhone：**设置 → 通用 → VPN 与设备管理 → 选择你的 Apple ID → 信任**。
8. 回到 iPhone 桌面，出现「行程管家」图标，点击即可试用。

## 四、免费 Apple ID 的限制

- 免费账号签名的 App **7 天有效**，到期后打不开；重新连 Mac，在 Xcode 再点一次 Run 即可续期（本地数据保留）。
- 同一免费账号最多同时安装 3 个自签名 App。
- 需要长期使用、多人分发（TestFlight）需加入付费 Apple Developer Program（99 美元/年）。

## 五、常见问题

| 现象 | 处理 |
| --- | --- |
| 报 `Failed to register bundle identifier` | Bundle Identifier 被占用，改成 `com.你的名字.tripmate` 再试 |
| 报 `Signing for "TripMate" requires a development team` | 第 4 步没有选 Team |
| 报 `No profiles for ...` | 先在 Xcode → Settings → Accounts 登录 Apple ID，选好 Team 后会自动生成描述文件 |
| 安装后提示“不受信任的开发者” | 设置 → 通用 → VPN 与设备管理 → 信任你的 Apple ID |
| 打开白屏 / 提示未找到内置页面 | 先在 Windows 运行 `tools/build_ios.ps1`，确认 `ios/TripMate/Resources/index.html` 存在，再重新拷到 Mac |
| 语音无法录音 | WKWebView 对网页麦克风支持有限，原型会自动回退为文字输入或例句，属预期 |
| 重启 App 后登录状态/数据丢失 | 告诉我，可改用“App 内置本机 HTTP 服务”方案，localStorage 更稳 |
| 工程打不开 / 提示版本过低 | 需要 Xcode 14 及以上；仍不行告诉我，可用 `project.yml` + XcodeGen 重新生成 |
| 想改 App 名称或图标 | 名称：Info.plist 的 `CFBundleDisplayName`；图标：替换 `Assets.xcassets/AppIcon.appiconset` 里图片后重新 Run |

## 六、工程结构

```
ios/
  TripMate.xcodeproj/project.pbxproj    Xcode 工程
  project.yml                           备用：用 XcodeGen 重新生成工程
  TripMate/
    TripMateApp.swift                   App 入口（SwiftUI）
    WebView.swift                       WKWebView 壳：加载内嵌 index.html
    Info.plist                          应用名 / 竖屏 / 图标 / 麦克风说明
    Assets.xcassets/AppIcon.appiconset  桌面图标（蓝色麦克风）
    Resources/index.html                内嵌原型（由 tools/build_ios.ps1 生成）
```

## 七、原理与边界

- 壳只做“加载内置网页”，不含任何网络请求；数据保存在 App 沙盒内的网页存储中，卸载 App 即清空。
- 原型中的语音识别、AI 都是模拟实现；原生壳不会改变这一点。
- 页面以固定的 `https://tripmate.local/` 作为来源加载，用于保证 localStorage 与历史路由正常工作。


## 八、在 Mac 上做编译验证（不必连 iPhone）

如果只想确认“工程能不能编译通过”，不需要签名、不需要真机：

```
cd ~/Downloads/ios
xcodebuild -project TripMate.xcodeproj -scheme TripMate \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

看到 `** BUILD SUCCEEDED **` 即编译通过；失败时把错误日志发我即可。

## 九、没有 Mac 时：用 GitHub Actions 的 macOS 运行器验证编译（免费）

工程里已内置工作流 `ios-build-workflow.yml.txt`（内容即 `.github/workflows/ios-build.yml`）。
GitHub 会用云端 macOS（Xcode 15）执行 `xcodebuild` 编译，结果在仓库 Actions 页查看。

### 第一步：建仓库
1. 打开 https://github.com 注册 / 登录；
2. 右上角 “+” → New repository；
3. 名称随意（如 `tripmate-ios`），选择 **Public**（公开仓库的 Actions 免费），
   不要勾选 README / .gitignore，点 Create repository。

### 第二步：上传工程
1. 在电脑上解压 `行程管家_iOS工程.zip`，得到 `ios` 文件夹；
2. 仓库页面 → “Add file” → “Upload files”；
3. 把整个 `ios` 文件夹拖进网页，等上传完 → “Commit changes”。

### 第三步：添加工作流文件（网页里新建）
1. 仓库页面 → “Add file” → “Create new file”；
2. 文件名填：`.github/workflows/ios-build.yml`（含斜杠，会自动建目录）；
3. 用记事本打开 `ios/ios-build-workflow.yml.txt`，全选复制，粘贴到网页编辑框；
4. 点 “Commit changes”。

### 第四步：查看结果
1. 打开仓库 **Actions** 页；
2. 找到 `iOS Build Check`，等它跑完（约 3—5 分钟）；
3. 绿色对勾 = 编译通过；红色则点进去，打开 “Build for iOS Simulator” 步骤，
   把最后 30—50 行报错复制发给我，我来修工程。

> 注意：GitHub Actions 只能验证“编译”，不能把 App 装到你手机上；
> 装真机仍需 Mac 或付费云 Mac 完成签名。

## 十、本机 Windows 装 macOS 虚拟机的现实条件

- 硬件：本机 CPU 为 Intel i9-13900H（支持 VT-x），磁盘空闲 C: 70GB / D: 121GB / E: 244GB，容量够用；
- 软件：需要管理员权限安装 VMware / VirtualBox 及其驱动，并下载 macOS 安装镜像（约 13GB）与 Xcode（约 10GB）；
- 13 代 Intel 属于 macOS 非官方支持平台，需要 OpenCore 引导与补丁，安装调试通常 3—6 小时，虚拟机内 Xcode 运行较慢；
- 授权：Apple 的 macOS 软件许可仅允许在 Apple 品牌硬件上虚拟化，非 Apple 硬件上运行不符合许可条款；
- 我所在的运行环境是 Windows 非管理员沙箱、且无外网下载权限，无法代替你完成安装；
- 如果你仍然自己装好了 macOS 虚拟机，可在虚拟机里运行第八节的 `xcodebuild` 命令，把日志发我，我据此修工程错误。

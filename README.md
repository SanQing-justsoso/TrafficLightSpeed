# EdgeSpeedColor

一个给 Garmin Edge 码表用的 Connect IQ 数据字段（Data Field），用「红绿灯」的视觉语言告诉你：**你现在骑得比平均速度快还是慢**。

支持设备：**Edge 840 / Edge 540**（均为 246×322 分辨率）。

## 效果

| 状态 | 背景 | 含义 |
|------|------|------|
| 未定位 | 上绿 / 中黄 / 下红 三段 | GPS 尚未定位，中间显示 `--` 占位 |
| 实时速度 > 平均速度 3% | 整格 **绿色** | 你冲得比均速快 |
| 实时速度在 ±3% 内 | 整格 **黄色** | 稳定巡航 |
| 实时速度 < 平均速度 -3% | 整格 **红色** | 掉速了 |

数值始终使用深色字，在红 / 黄 / 绿背景上都清晰可读。

## 显示内容

- **大字**：实时速度（如 `32.5`）
- **小字**：速度单位（`km/h` 或 `mph`，随码表单位设置自动切换）
- **右上角小字**：平均速度
- **顶部标题**：`Speed / Avg`

## 技术要点

- 语言：Monkey C（Garmin Connect IQ SDK）
- 类型：`WatchUi.DataField`（复杂数据字段，自定义 `onUpdate` 绘制）
- 单位自适应：公制 `km/h`，英制 `mph`
- 红绿灯阈值：平均速度的 ±3%

## 项目结构

```
EdgeSpeedColor/
├── manifest.xml              # 应用清单（声明 Edge 840 / 540）
├── monkey.jungle             # 编译入口
├── source/
│   ├── App.mc                # 应用入口
│   └── View.mc               # 核心逻辑与绘制
├── resources/
│   ├── drawables/            # 图标
│   └── strings/              # 应用名等字符串
└── build.sh                  # 编译脚本（见下文）
```

## 编译

### 前置条件

1. 安装 [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)（本仓库基于 9.2.0）
2. 通过 SDK Manager 下载 **Edge 840** 和 **Edge 540** 的设备数据
3. 生成开发者密钥 `developer_key.der`（VS Code 安装 Monkey C 插件后，`Ctrl+Shift+P` → `Monkey C: Generate Developer Key`）
4. 将 `developer_key.der` 放到项目根目录

> ⚠️ `developer_key.der` 是私钥，**切勿提交到仓库**，已在 `.gitignore` 中排除。

### 编译命令

```bash
bash build.sh
```

会分别为两个设备生成独立的 `.prg`：

- `bin/EdgeSpeedColor-edge840.prg`
- `bin/EdgeSpeedColor-edge540.prg`

> 注意：`build.sh` 中的 `SDK_DIR` 路径需要改成你自己的 SDK 安装位置。

## 安装到码表

1. 码表用 USB 连接电脑，会显示为一个可移动磁盘
2. 将对应设备的 `.prg` 文件拷贝到 `GARMIN/APPS/` 目录
3. 断开 USB，码表重启
4. 进入骑行活动页 → 编辑数据页 → 添加数据字段 → Connect IQ 分类 → 选择 **EdgeSpeedColor**

## License

MIT

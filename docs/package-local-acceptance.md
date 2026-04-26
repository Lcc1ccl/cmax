# cmax 本地真实包体验收

## 目标

在**不触发正式 release 上传 / 签名公证**的前提下，打出一个可直接安装验收的 Release 包体。

## 本地执行

```bash
cd cmax
./scripts/package-local-acceptance.sh
```

默认行为：

- 构建 universal Release `Cmax.app`
- 生成 `cmax-macos-local.dmg`
- 构建并输出 `remote-daemon-assets/`
- 将同一份 `remote-daemon-assets/` 一并打进 `Cmax.app/Contents/Resources/remote-daemon-assets/`
- 将 embedded remote-daemon manifest 注入 app bundle
- 对 app 做 ad-hoc codesign，便于本机直接打开验收

可选参数：

```bash
./scripts/package-local-acceptance.sh --output-dir /tmp/cmax-preview
./scripts/package-local-acceptance.sh --release-tag preview-my-branch
./scripts/package-local-acceptance.sh --skip-dmg
```

> 注意：这不是正式发布包。它不会上传 GitHub Release，也不会执行 Developer ID signing / notarization。

## GitHub Actions 自动打包

仓库新增 `Package cmax preview` workflow：

- `push` 到 `main` 时自动运行
- 也支持 `workflow_dispatch` 手动触发
- 产出 artifact：
  - `Cmax.app`
  - `cmax-macos-local.dmg`
  - `package-info.json`
  - `remote-daemon-assets/*`

该 workflow 仅用于**预打包 / 验收包**，正式对外发布仍走 `release.yml`。正式发布同样采用 ad-hoc codesign + 非 notarized DMG，不依赖 Apple Developer ID。

预打包 artifact 的 `Cmax.app` 也会自带 `remote-daemon-assets`，因此本地解压后可直接验收 remote daemon bootstrap，不依赖额外 GitHub Release 资产上传。

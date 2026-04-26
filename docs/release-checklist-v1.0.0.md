# cmax v1.0.0 release checklist

## 1. 必配 GitHub Secret

`Release cmax app` workflow 不使用 Apple Developer ID / notarization。仓库级 secret 只需要：

- `SPARKLE_PRIVATE_KEY`：用于签名 Sparkle appcast 更新包。

可选：

- `SENTRY_AUTH_TOKEN`：未配置会自动跳过 dSYM 上传，不阻塞 release。

## 2. macOS 发布签名策略

当前按小型开源项目的常见做法发布：

- 构建 universal Release `Cmax.app`
- 对 `.app` 做 ad-hoc codesign：`codesign --sign -`
- 用 `hdiutil` 生成 `cmax-macos.dmg`
- 不执行 Apple Developer ID signing
- 不执行 notarization / stapling
- Sparkle appcast 仍由 `SPARKLE_PRIVATE_KEY` 签名，保证自动更新包完整性

因此发布流程不需要以下 Apple secrets：

- `APPLE_CERTIFICATE_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_RELEASE_PROVISIONING_PROFILE_BASE64`
- `APPLE_SIGNING_IDENTITY`
- `APPLE_ID`
- `APPLE_APP_SPECIFIC_PASSWORD`
- `APPLE_TEAM_ID`

用户首次打开非 notarized app 时，可能需要通过 Finder 右键打开或在系统设置中允许打开。

## 3. GitHub / Runner 必配项

当前仓库 workflow：

- `.github/workflows/package-preview.yml`：push 到 `main` 或手动触发，产出预览打包 artifact
- `.github/workflows/release.yml`：push tag `v*` 或手动触发，产出正式发布 / dry-run artifact
- `.github/workflows/ci.yml`：常规 CI

运行依赖：

- Preview runner：`macos-15`
- Release runner：`warp-macos-26-arm64-6x`

如果仓库没有 WarpBuild runner，请把 release workflow 的 `runs-on` 改成你可用的 macOS runner 标签。

## 4. 当前仓库状态基线

已核对当前首发基线：

- Release app：`Cmax.app`
- Release Bundle ID：`com.cmaxterm.app`
- App executable / bundled CLI：仍为 `cmux`
- `MARKETING_VERSION = 1.0.0`
- `CURRENT_PROJECT_VERSION = 80`
- `.release-policy.json`:
  - `productVersion = 1.0.0`
  - `upstreamVersion = 0.63.2`
- Sparkle feed：`https://github.com/Lcc1ccl/cmax/releases/latest/download/appcast.xml`
- release 资产名：`cmax-macos.dmg`

## 5. 打正式 tag 前

先确保：

- 当前工作树整理为你准备发布的最终提交
- `CHANGELOG.md` 顶部保留对应版本说明
- `SPARKLE_PRIVATE_KEY` 已配置
- runner 可用

然后执行：

```bash
./scripts/release-pretag-guard.sh
git tag v1.0.1
git push origin v1.0.1
```

> `v1.0.0` 已经存在时，不建议移动旧 tag；常规做法是发一个新的 patch tag。

## 6. Tag 后应看到的结果

```bash
gh run watch --repo Lcc1ccl/cmax
```

GitHub Release 应出现：

- `cmax-macos.dmg`
- `appcast.xml`
- `cmuxd-remote-manifest.json`
- `cmuxd-remote-checksums.txt`
- 各平台 `cmuxd-remote-*` 资产

并且以下步骤应通过：

- ad-hoc codesign verify
- DMG create / verify
- Sparkle appcast generation
- GitHub attestation

## 7. 出错时怎么处理

- 如果 tag workflow 在**上传资产前**失败：修完后直接重跑该 tag workflow
- 如果同一 tag 已出现**部分 immutable 资产**：先删掉错误的 Release / tag，或手工清掉冲突资产，再重跑
- 不要移动已有正式 tag 来替换产物；优先发布新的 patch tag

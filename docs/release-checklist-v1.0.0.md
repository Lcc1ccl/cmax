# cmax v1.0.0 release checklist

## 1. 必配 GitHub Secrets

`Release cmax app` workflow 依赖以下仓库级 secrets：

- `SPARKLE_PRIVATE_KEY`
- `APPLE_CERTIFICATE_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_RELEASE_PROVISIONING_PROFILE_BASE64`
- `APPLE_SIGNING_IDENTITY`
- `APPLE_ID`
- `APPLE_APP_SPECIFIC_PASSWORD`
- `APPLE_TEAM_ID`

可选：

- `SENTRY_AUTH_TOKEN`（未配置会自动跳过 dSYM 上传，不阻塞 release）

## 2. Apple 侧必须匹配的值

当前 release 流程**没有改 Bundle ID**，所以 Apple 侧材料必须匹配现有签名约束：

- 正式 Bundle ID：`com.cmuxterm.app`
- 当前 release entitlement app id：`7WLXT3NR37.com.cmuxterm.app`
- 当前 Team ID：`7WLXT3NR37`
- provisioning profile 必须是 **Developer ID / all devices**
- provisioning profile 必须包含：`com.apple.developer.web-browser.public-key-credential = true`

对应到 secrets：

- `APPLE_SIGNING_IDENTITY`：应是类似 `Developer ID Application: <Your Name or Org> (7WLXT3NR37)`
- `APPLE_RELEASE_PROVISIONING_PROFILE_BASE64`：base64 后的 `.provisionprofile` 文件内容
- `APPLE_CERTIFICATE_BASE64`：base64 后的 Developer ID Application 证书 `.p12`
- `APPLE_CERTIFICATE_PASSWORD`：该 `.p12` 的导出密码
- `APPLE_ID` / `APPLE_APP_SPECIFIC_PASSWORD` / `APPLE_TEAM_ID`：用于 notarization 的 Apple 账号配置

## 3. GitHub / Runner 必配项

当前仓库 workflow 已经收敛为只剩：

- `.github/workflows/ci.yml`
- `.github/workflows/release.yml`

运行依赖：

- CI runner：`warp-macos-15-arm64-6x`
- Release runner：`warp-macos-26-arm64-6x`

如果你的仓库没有这些 runner，release 不会成功，需要二选一：

1. 你已有 WarpBuild / 对应 runner 标签，直接可用
2. 没有的话，先把 workflow 的 `runs-on` 改成你自己可用的 macOS runner 标签

## 4. 当前仓库状态基线

已核对当前首发基线：

- `MARKETING_VERSION = 1.0.0`
- `CURRENT_PROJECT_VERSION = 80`
- `.release-policy.json`:
  - `productVersion = 1.0.0`
  - `upstreamVersion = 0.63.2`
- Sparkle feed：`https://github.com/Lcc1ccl/cmax/releases/latest/download/appcast.xml`
- release 资产名：`cmax-macos.dmg`
- 当前仓库尚无 tag：`no-tag`

## 5. 首发前最后动作

在真正打 tag 前，先确保：

- 当前工作树整理为你准备发布的最终提交
- `CHANGELOG.md` 顶部保留 `1.0.0` 首发说明
- 所有必要 secrets 已填完
- runner 可用

然后执行：

```bash
./scripts/release-pretag-guard.sh
git tag v1.0.0
git push origin v1.0.0
```

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

- app notarization
- dmg notarization
- Sparkle appcast generation
- GitHub attestation

## 7. 出错时怎么处理

- 如果 tag workflow 在**上传资产前**失败：修完后直接重跑该 tag workflow
- 如果同一 tag 已出现**部分 immutable 资产**：先删掉错误的 Release / tag，或手工清掉冲突资产，再重跑
- 不要对同一正式 tag 反复覆盖已签名产物，除非你明确是在做紧急 reroll

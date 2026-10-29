# nkuhn-vmw/homebrew-tap

Homebrew formulas for tools I maintain.

## Install

```bash
brew tap nkuhn-vmw/tap
brew install cfctx
```

Current Homebrew versions require explicit trust for community taps. If Homebrew
reports an untrusted tap, review this repository, run `brew trust --tap
nkuhn-vmw/tap`, and retry. This trusts formula code from this tap.

## Formulas

| Formula | Description |
|---|---|
| [`cfctx`](Formula/cfctx.rb) | Per-shell Cloud Foundry / Tanzu context switcher ([repo](https://github.com/nkuhn-vmw/cfctx)) |
| [`opencode-tanzu`](Formula/opencode-tanzu.rb) | [opencode](https://opencode.ai) provider plugin for Tanzu Platform GenAI ([repo](https://github.com/nkuhn-vmw/opencode-tanzu)) — V1 and native V2/beta adapters; activate the matching runtime as described below |
| [`ws`](Formula/ws.rb) | KL AgentFS client. Requires internal Harbor pull access; see [private installs](#private-ws-installs). Source and releases remain private. |
| [`klbench`](Formula/klbench.rb) | Kuhn Labs LLM benchmark suite ([repo](https://github.com/nkuhn-vmw/klbench)) — activates at the v1.0.0 tag; pins to the PyPI sdist once published |

## Private ws installs

Ask your administrator for the trusted Harbor hostname and **pull-only** access
to its private `ws` project. Connect to the internal network/VPN. No GitHub
repository access, GitHub token, or repository write permission is needed.

```bash
brew tap nkuhn-vmw/tap
# Review this tap before trusting its formula and external command code:
brew trust --tap nkuhn-vmw/tap
brew install jq
export HOMEBREW_WS_REGISTRY='harbor.example.com' # replace with the supplied hostname
brew ws-install
ws version
klportal workspace agentfs key | ws connect --key -
ws sync
```

Sign in to Harbor with SSO first. In **User Profile**, copy your **CLI secret**.
The helper asks for your Harbor username, then curl prompts for the CLI secret;
do not enter your SSO password. The helper exchanges it for a short-lived token
scoped to pulling `ws/client`, passes that token to Homebrew for this invocation,
and does not save the CLI secret. Homebrew verifies the binary's pinned SHA-256.
Only use a registry hostname supplied through a trusted channel: this is where
your credential is sent. TLS verification remains enabled.

Use `brew ws-install upgrade` or `brew ws-install reinstall` for subsequent
operations. A plain `brew upgrade` cannot authenticate an uncached `ws` download;
use the helper if it fails. The registry hostname can be saved in your shell
profile; do not save the CLI secret or `HOMEBREW_WS_TOKEN` there. Homebrew caches
the downloaded binary locally. Short-lived tokens can be visible to other local
users while Homebrew's download curl runs, so use a trusted machine. The helper
handles your CLI secret, which carries your Harbor account's permissions; review
and trust its code as carefully as the formula.

For HTTP 401/403, check your CLI secret and private-project pull permission.
For DNS/TLS failures, check VPN and your system's trusted CA configuration; do
not disable certificate verification. Public CI checks the formula without
credentials. Authenticated download/install tests run from the private source
repository against a reviewed tap commit on an internal runner.

## Tanzu provider: OpenCode V1 and V2 / beta

Install the runtime separately, then:

```bash
brew install nkuhn-vmw/tap/opencode-tanzu
# Existing OpenCode V1:
opencode-tanzu-install --runtime v1
opencode providers login -p tanzu

# OpenCode V2 / beta (plugin 0.3.0+):
opencode-tanzu-install --runtime v2
export TANZU_GENAI_BASE_URL='https://genai-proxy.example.com/instance/openai/v1'
export TANZU_GENAI_API_KEY_FILE="$HOME/.config/tanzu/api-key"
# If your V2 executable is not named opencode2:
export OPENCODE_V2_BIN='/absolute/path/to/v2/opencode'
opencode-tanzu-v2
```

The token file contains the raw service-key API key and should be mode 0600
inside a private directory. V2 reads it again for each request, supporting
rotation. Its wrapper isolates config/data/cache/state from V1; see the
[full guide](https://github.com/nkuhn-vmw/opencode-tanzu/blob/main/docs/opencode-v2.md)
for XDG overrides, source/project installs, private CA configuration, model
selection, verification and troubleshooting. The [v0.3.0 release](https://github.com/nkuhn-vmw/opencode-tanzu/releases/tag/v0.3.0)
records the tested stable and beta runtime versions. See the
[validation record](https://github.com/nkuhn-vmw/opencode-tanzu/blob/main/docs/validation-standalone-v2.md)
for the live inference timeout and browser validation limitations.
The Homebrew formula stages files only; activation runs as your user and uses
the same installer as the source repository. No CF buildpack is needed.

After `brew upgrade opencode-tanzu`, rerun the installer for each runtime.
Uninstall with `opencode-tanzu-install --runtime v2 --uninstall` (or `v1`),
then `brew uninstall opencode-tanzu` if no runtime uses it. Plugin uninstall
retains credentials, config and sessions. `--project` targets the current
project instead of global configuration.

## Updating a formula

For `ws`, first publish the unchanged release binaries to the private Harbor
project using the maintainer publishing script from the internal network, then
update all four blob digests and SHA-256 pins together. Keep the version tag immutable and
retained in Harbor. There is no public fallback or automatic livecheck for `ws`.

Most formula updates happen automatically via the auto-bump GitHub Action in
the source repos (they open a PR here on every new `v*` tag). Manual bumps:

```bash
# Compute SHA256 of the new release tarball:
curl -fsSL https://github.com/<owner>/<repo>/archive/refs/tags/<tag>.tar.gz | shasum -a 256

# Edit Formula/<name>.rb — update `url` and `sha256`, then commit + push.
```

## License

Apache-2.0 — matches the formulas' upstream projects.

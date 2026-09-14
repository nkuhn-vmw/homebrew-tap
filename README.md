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
| [`klbench`](Formula/klbench.rb) | Kuhn Labs LLM benchmark suite ([repo](https://github.com/nkuhn-vmw/klbench)) — activates at the v1.0.0 tag; pins to the PyPI sdist once published |

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

Most formula updates happen automatically via the auto-bump GitHub Action in
the source repos (they open a PR here on every new `v*` tag). Manual bumps:

```bash
# Compute SHA256 of the new release tarball:
curl -fsSL https://github.com/<owner>/<repo>/archive/refs/tags/<tag>.tar.gz | shasum -a 256

# Edit Formula/<name>.rb — update `url` and `sha256`, then commit + push.
```

## License

Apache-2.0 — matches the formulas' upstream projects.

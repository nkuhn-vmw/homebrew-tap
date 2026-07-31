# nkuhn-vmw/homebrew-tap

Homebrew formulas for tools I maintain.

## Install

```bash
brew tap nkuhn-vmw/tap
brew install cfctx
```

## Formulas

| Formula | Description |
|---|---|
| [`cfctx`](Formula/cfctx.rb) | Per-shell Cloud Foundry / Tanzu context switcher ([repo](https://github.com/nkuhn-vmw/cfctx)) |
| [`opencode-tanzu`](Formula/opencode-tanzu.rb) | [opencode](https://opencode.ai) provider plugin for Tanzu Platform GenAI ([repo](https://github.com/nkuhn-vmw/opencode-tanzu)) — after `brew install`, run `opencode-tanzu-install` to copy the plugin into `~/.config/opencode/plugins` |
| [`klbench`](Formula/klbench.rb) | Kuhn Labs LLM benchmark suite ([repo](https://github.com/nkuhn-vmw/klbench)) — activates at the v1.0.0 tag; pins to the PyPI sdist once published |

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

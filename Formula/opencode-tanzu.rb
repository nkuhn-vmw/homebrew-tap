class OpencodeTanzu < Formula
  desc "Opencode provider plugin for Tanzu Platform GenAI (community, unsupported)"
  homepage "https://github.com/nkuhn-vmw/opencode-tanzu"
  url "https://github.com/nkuhn-vmw/opencode-tanzu/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "da8d179cab831d334bcf88bb986fac03da4b09e724fc0e0098096aa937626476"
  license "Apache-2.0"

  def install
    libexec.install "src", "bin", "install.sh"
    (bin/"opencode-tanzu-install").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/install.sh" "$@"
    EOS
    (bin/"opencode-tanzu-v2").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/opencode-tanzu-v2" "$@"
    EOS
  end

  def caveats
    <<~EOS
      Install OpenCode separately, then activate the matching provider:

        opencode-tanzu-install --runtime v1
        opencode-tanzu-install --runtime v2

      V1: opencode providers login -p tanzu
      V2: set TANZU_GENAI_BASE_URL and TANZU_GENAI_API_KEY_FILE, then run
          opencode-tanzu-v2

      The V2 wrapper isolates config and state from V1. It expects opencode2
      on PATH; set OPENCODE_V2_BIN if your V2 executable has another name.
      After upgrades, rerun the installer for each runtime you use.
      Remove a runtime's plugin with --runtime v1|v2 --uninstall.
      Credentials and sessions are retained.

      Guide: https://github.com/nkuhn-vmw/opencode-tanzu/blob/main/docs/opencode-v2.md
    EOS
  end

  test do
    assert_path_exists libexec/"src/opencode-tanzu.js"
    system bin/"opencode-tanzu-install", "--runtime", "v2"
    assert_path_exists testpath/".config/opencode-tanzu-v2/opencode/plugins/opencode-tanzu-v2/index.js"
    system bin/"opencode-tanzu-install", "--runtime", "v2", "--uninstall"
    refute_path_exists testpath/".config/opencode-tanzu-v2/opencode/plugins/opencode-tanzu-v2/index.js"
    # The plugin runs inside opencode's own runtime, not system node, so node is
    # not a dependency. Use it only as an opportunistic syntax/import smoke check
    # when it happens to be available (it may not be in brew's test sandbox).
    node = which("node")
    system node, "--input-type=module", "-e", "await import('#{libexec}/src/opencode-tanzu.js')" if node
  end
end

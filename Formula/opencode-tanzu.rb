class OpencodeTanzu < Formula
  desc "Opencode provider plugin for Tanzu Platform GenAI (community, unsupported)"
  homepage "https://github.com/nkuhn-vmw/opencode-tanzu"
  url "https://github.com/nkuhn-vmw/opencode-tanzu/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "b7356f944e6f6c05fa93f3d01980f105077eeccd11dccebbc00e62734a1eb75d"
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
      Install OpenCode V2 (verified: 2.0.18), then activate the native provider:

        opencode-tanzu-install

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
    system bin/"opencode-tanzu-install"
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

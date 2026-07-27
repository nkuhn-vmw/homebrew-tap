class OpencodeTanzu < Formula
  desc "Opencode provider plugin for Tanzu Platform GenAI (community, unsupported)"
  homepage "https://github.com/nkuhn-vmw/opencode-tanzu"
  url "https://github.com/nkuhn-vmw/opencode-tanzu/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "1940bd435c20a2698b69d3e8398d2bf88e7e81fbde9d5f37238fc55108bf64ef"
  license "Apache-2.0"

  def install
    libexec.install Dir["src/*.js"]

    # Homebrew must not write into $HOME, so the copy into opencode's plugin
    # directory is a user-run step. opencode loads plugin files flat — no
    # subdirectories — hence the plain file copy.
    (bin/"opencode-tanzu-install").write <<~EOS
      #!/bin/bash
      set -euo pipefail
      target="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/plugins"
      if [ "${1:-}" = "--uninstall" ]; then
        rm -f "$target"/opencode-tanzu*.js
        echo "Removed opencode-tanzu from $target"
        exit 0
      fi
      mkdir -p "$target"
      cp "#{libexec}"/*.js "$target"/
      echo "Installed opencode-tanzu #{version} into $target"
      echo "Next: opencode providers login -p tanzu"
    EOS
  end

  def caveats
    <<~EOS
      The plugin is staged in #{libexec}. To activate it, copy it into
      opencode's plugin directory (~/.config/opencode/plugins):

        opencode-tanzu-install

      After `brew upgrade opencode-tanzu`, run it again to pick up the new
      version. Remove with:

        opencode-tanzu-install --uninstall
    EOS
  end

  test do
    assert_path_exists libexec/"opencode-tanzu.js"
    # The plugin runs inside opencode's own runtime, not system node, so node is
    # not a dependency. Use it only as an opportunistic syntax/import smoke check
    # when it happens to be available (it may not be in brew's test sandbox).
    node = which("node")
    system node, "--input-type=module", "-e", "await import('#{libexec}/opencode-tanzu.js')" if node
  end
end

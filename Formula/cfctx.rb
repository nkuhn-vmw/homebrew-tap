class Cfctx < Formula
  desc "Per-shell CF/Tanzu context switcher (kubectx for CF/Ops Manager/BOSH/CredHub)"
  homepage "https://github.com/nkuhn-vmw/cfctx"
  url "https://github.com/nkuhn-vmw/cfctx/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "813044260ddafe9fe659a02a0c679d5d51e7d77aba58dfc64c6964be0019d554"
  license "Apache-2.0"
  head "https://github.com/nkuhn-vmw/cfctx.git", branch: "main"

  depends_on "bash" => :test

  def install
    libexec.install "cfctx.sh"
    bash_completion.install "completions/cfctx.bash" => "cfctx"
    zsh_completion.install  "completions/cfctx.zsh"  => "_cfctx"
    pkgshare.install "examples", "docs"
    prefix.install "LICENSE", "README.md"
  end

  def caveats
    <<~EOS
      cfctx is a sourced shell function (it mutates your parent shell's env).
      To activate, add this line to your ~/.zshrc or ~/.bashrc:

          source "#{opt_libexec}/cfctx.sh"

      Optional — point cfctx at a directory of `om` env files to auto-discover
      foundations by name:

          export CFCTX_OM_ENV_DIR="$HOME/.om-env"

      Then open a new shell:
          cfctx              # list configured foundations
          cfctx help         # full usage

      Optional integrations:
          brew install jq     # for CF_API / CF-creds auto-detection from Ops Manager
          brew install fzf    # for `cfctx pick` interactive picker

      Docs: https://github.com/nkuhn-vmw/cfctx
    EOS
  end

  test do
    # Source the function into a subshell and verify it responds.
    output = shell_output("#{Formula["bash"].opt_bin}/bash -c 'source #{opt_libexec}/cfctx.sh && cfctx version'")
    assert_match "cfctx #{version}", output
  end
end

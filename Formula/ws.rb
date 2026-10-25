class Ws < Formula
  desc "KL AgentFS client: sync agent memory, instructions and skills with S3"
  homepage "https://github.com/nkuhn-vmw/agent-workspace"
  license "Apache-2.0"

  # Static Go binaries from the GitHub release; sha256 values are copied from
  # the release's SHA256SUMS (identical to a local `make dist`).
  on_macos do
    on_arm do
      url "https://github.com/nkuhn-vmw/agent-workspace/releases/download/v0.18.0/ws-darwin-arm64"
      sha256 "ae5767780a70d63ce6f8da3b4bb5d2719a3d50db98d0cc6057cb619d3df0b070"
    end
    on_intel do
      url "https://github.com/nkuhn-vmw/agent-workspace/releases/download/v0.18.0/ws-darwin-amd64"
      sha256 "647005e8b9ff896cc0061c8634db645d4e411e57674fd0ac741b962bdd57ea44"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/nkuhn-vmw/agent-workspace/releases/download/v0.18.0/ws-linux-arm64"
      sha256 "2ebcb908f662aba7ab024f2f7727e5e5c15402ac36b47bd053d477625c76c04d"
    end
    on_intel do
      url "https://github.com/nkuhn-vmw/agent-workspace/releases/download/v0.18.0/ws-linux-amd64"
      sha256 "a816460d25b21d74a56ebceaf40c66d5c130a02cd7f97799284ea96ff943fc16"
    end
  end

  def install
    bin.install Dir["ws-*"].first => "ws"
  end

  def caveats
    <<~EOS
      Connect this machine to your portal workspace's KL AgentFS instance:

        klportal workspace agentfs key | ws connect --key -
        ws sync

      The key is stored in ~/.config/ws/connection.json (mode 0600).
      Guide: https://github.com/nkuhn-vmw/agent-workspace/blob/main/docs/connect.md
    EOS
  end

  test do
    assert_match "ws #{version}", shell_output("#{bin}/ws version")
    # ws connect never echoes the secret and writes a private connection file.
    key = <<~JSON
      {"endpoint_url":"https://s3.example.com","bucket":"agentfs","instance_prefix":"g/","prefix":"g/",
       "access_key_id":"AKTEST","secret_access_key":"brew-test-secret"}
    JSON
    out = pipe_output("#{bin}/ws connect --key - --dir #{testpath}/fs", key)
    refute_match "brew-test-secret", out
    assert_match "the whole instance", out
    conn = testpath/".config/ws/connection.json"
    assert_equal "600", format("%o", conn.stat.mode & 0777)
  end
end

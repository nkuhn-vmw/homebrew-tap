class Ws < Formula
  desc "KL AgentFS client: sync agent memory, instructions and skills with S3"
  homepage "https://github.com/nkuhn-vmw/homebrew-tap#private-ws-installs"
  version "0.18.0"
  license "Apache-2.0"
  revision 1

  # The operator supplies the trusted internal registry; no credentials or
  # internal hostname are published in this tap. Load without credentials for
  # readall/info/style. Authentication is required only when fetching.
  registry = ENV.fetch("HOMEBREW_WS_REGISTRY", "harbor.example.invalid")
  unless registry.match?(/\A[a-zA-Z0-9](?:[a-zA-Z0-9.-]*[a-zA-Z0-9])?(?::[0-9]{1,5})?\z/)
    raise "HOMEBREW_WS_REGISTRY must be a trusted hostname, without scheme or path"
  end

  headers = ["Authorization: Bearer #{ENV.fetch("HOMEBREW_WS_TOKEN", "")}"]

  livecheck do
    skip "Private Harbor distribution; maintainers verify the release pins"
  end

  # Each raw OCI layer is the unchanged official release binary. Its immutable
  # blob digest is the same SHA-256 already pinned by this formula.
  on_macos do
    on_arm do
      url "https://#{registry}/v2/ws/client/blobs/sha256:ae5767780a70d63ce6f8da3b4bb5d2719a3d50db98d0cc6057cb619d3df0b070",
          headers: headers
      sha256 "ae5767780a70d63ce6f8da3b4bb5d2719a3d50db98d0cc6057cb619d3df0b070"
    end
    on_intel do
      url "https://#{registry}/v2/ws/client/blobs/sha256:647005e8b9ff896cc0061c8634db645d4e411e57674fd0ac741b962bdd57ea44",
          headers: headers
      sha256 "647005e8b9ff896cc0061c8634db645d4e411e57674fd0ac741b962bdd57ea44"
    end
  end

  on_linux do
    on_arm do
      url "https://#{registry}/v2/ws/client/blobs/sha256:2ebcb908f662aba7ab024f2f7727e5e5c15402ac36b47bd053d477625c76c04d",
          headers: headers
      sha256 "2ebcb908f662aba7ab024f2f7727e5e5c15402ac36b47bd053d477625c76c04d"
    end
    on_intel do
      url "https://#{registry}/v2/ws/client/blobs/sha256:a816460d25b21d74a56ebceaf40c66d5c130a02cd7f97799284ea96ff943fc16",
          headers: headers
      sha256 "a816460d25b21d74a56ebceaf40c66d5c130a02cd7f97799284ea96ff943fc16"
    end
  end

  def install
    # Raw blob downloads are staged under their digest, not the release name.
    bin.install "sha256:#{stable.checksum}" => "ws"
  end

  def caveats
    <<~EOS
      Connect this machine to your portal workspace's KL AgentFS instance:

        klportal workspace agentfs key | ws connect --key -
        ws sync

      The key is stored in ~/.config/ws/connection.json (mode 0600).
      Installs/upgrades require Harbor pull access: brew ws-install upgrade
      Guide: https://github.com/nkuhn-vmw/homebrew-tap#private-ws-installs
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

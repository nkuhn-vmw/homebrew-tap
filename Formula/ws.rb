class Ws < Formula
  desc "Private agent-state backup engine for Cloud Foundry agent buildpacks"
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
      KL AgentFS was retired on 2026-11-18, so ws connect and ws sync have
      nothing left to connect to; the next release removes them. On a
      workstation ws is an operator tool for the private-state backup
      (for example ws restore --state).

      Installs/upgrades require Harbor pull access: brew ws-install upgrade
      Guide: https://github.com/nkuhn-vmw/homebrew-tap#private-ws-installs
    EOS
  end

  test do
    assert_match "ws #{version}", shell_output("#{bin}/ws version")
  end
end

"""Public checks for the private formula, requiring no registry credential."""
from pathlib import Path
import re
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PrivateDistribution(unittest.TestCase):
    def test_blob_digest_matches_homebrew_integrity_pin(self):
        source = (ROOT / "Formula/ws.rb").read_text()
        pairs = re.findall(
            r'url "https://#\{registry\}/v2/ws/client/blobs/sha256:([a-f0-9]{64})",'
            r'\s+headers: headers\s+sha256 "([a-f0-9]{64})"', source
        )
        self.assertEqual(len(pairs), 4)
        self.assertEqual(len({digest for digest, _ in pairs}), 4)
        for digest, pin in pairs:
            self.assertEqual(digest, pin)
        self.assertNotIn("releases/download", source)
        self.assertNotIn("mirror ", source)

    def test_bootstrap_rejects_url_credentials_and_paths_before_auth(self):
        import os
        self.assertTrue(os.access(ROOT / "cmd/brew-ws-install", os.X_OK))
        for host in ("http://example.com", "user:secret@example.com", "example.com/path", ""):
            result = subprocess.run(
                ["bash", str(ROOT / "cmd/brew-ws-install")],
                env={**os.environ, "HOMEBREW_WS_REGISTRY": host},
                capture_output=True, text=True,
            )
            self.assertEqual(result.returncode, 2)
            self.assertIn("trusted Harbor hostname", result.stderr)


if __name__ == "__main__":
    unittest.main()

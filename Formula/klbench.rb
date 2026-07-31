class Klbench < Formula
  include Language::Python::Virtualenv

  desc "Kuhn Labs LLM benchmark — real-usability benchmarks against any endpoint"
  homepage "https://github.com/nkuhn-vmw/klbench"
  # Until the first PyPI release, install from the repo tag. On release,
  # switch url/sha256 to the PyPI sdist and run `brew audit --new klbench`.
  url "https://github.com/nkuhn-vmw/klbench.git", tag: "v1.0.0"
  version "1.0.0"
  license "Apache-2.0"

  depends_on "python@3.12"

  resource "jsonschema" do
    url "https://pypi.org/simple/jsonschema/", using: :homebrew_curl
    # placeholder: pin real sdist url+sha256 before publishing the tap
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "klbench", shell_output("#{bin}/klbench --help")
  end
end

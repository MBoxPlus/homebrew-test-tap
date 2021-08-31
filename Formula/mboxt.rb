class Mboxt < Formula
  VERSION = "1.2.2-alpha.20210831040618".freeze
  REPO = "MBoxPlus/mbox".freeze

  version VERSION
  desc "Missing toolchain for mobile development"
  homepage "https://github.com/#{REPO}"
  url "https://github.com/#{REPO}/releases/download/v#{VERSION}/mbox-#{VERSION}.tar.gz"
  sha256 "c7402204f19ff77f7b68fa75c3c98e08538667b39b03d32038c0432cf7be2826"
  license "GPL-2.0-only"

  def install
    cp_r ".", libexec, preserve: true
    bin.install_symlink libexec/"MBoxCore/MBoxCLI" => "mboxt"
    bin.install_symlink libexec/"MBoxCore/MDevCLI" => "mdevt"

    # Prevent formula installer from changing dylib id.
    # The dylib id of our frameworks is just like "@rpath/xxx/xxx" and is NOT expected to absolute path.
    Dir[libexec/"*/*.framework"].each do |framework|
      system "tar",
             "-czf",
             "#{framework}.tar.gz",
             "-C",
             File.dirname(framework),
             File.basename(framework)
      rm_rf framework
    end
  end

  def post_install
    Dir[libexec/"*/*.framework.tar.gz"].each do |pkg|
      system "tar", "-zxf", pkg, "-C", File.dirname(pkg)
      rm_rf pkg
    end
  end

  def caveats
    s = <<~EOS
      \e[33mPlease restart the terminal\e[0m.
      Use 'mboxt --help' or 'mboxt [command] --help' to display help information about the command.
    EOS
    s += "mboxt only supports macOS version ≥ 15.0 (Catalina)" if MacOS.version < :catalina
    s
  end

  test do
    assert_match "CLI Core Version", shell_output("mboxt --version --no-launcher").strip
  end
end

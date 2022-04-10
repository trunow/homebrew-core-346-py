class Moarvm < Formula
  desc "Virtual machine for NQP and Rakudo Perl 6"
  homepage "https://moarvm.org"
  url "https://github.com/MoarVM/MoarVM/releases/download/2022.03/MoarVM-2022.03.tar.gz"
  sha256 "fb71cd13912464482b99b33f0c06e9fd7c51a151c6e632a9220cf93c5855fdaf"
  license "Artistic-2.0"

  livecheck do
    url "https://github.com/MoarVM/MoarVM.git"
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 arm64_monterey: "9166013b6ab100c8fc2e40ce1e5758dfb841e02349602e1b64a16aafb6ab0b14"
    sha256 arm64_big_sur:  "24e491e822abc0ab158521eac5beb9c2a82dcff7971a060769e4ddd5ce79dbdb"
    sha256 monterey:       "a1d5c7d4e58d88422d167f46e056f7c10847aac78a993467ce03160779acbf8d"
    sha256 big_sur:        "3e08d7afe42ccc5606375d69bba68e2772e87736d2a38c4b019964afc4b69d81"
    sha256 catalina:       "10df00e4d29eabd6c97db11a5401203938e13d74bceadcbff00bd03b8fc373a0"
    sha256 x86_64_linux:   "1898ddea7dad0c2a1ebd80c486bdd41daa417bb0dd12561c743988a9832159b3"
  end

  depends_on "libatomic_ops"
  depends_on "libffi"
  depends_on "libtommath"
  depends_on "libuv"

  conflicts_with "rakudo-star", because: "rakudo-star currently ships with moarvm included"

  resource "nqp" do
    url "https://github.com/Raku/nqp/releases/download/2022.03/nqp-2022.03.tar.gz"
    sha256 "a95e778970c4d09c091d2aa299c05036208ce4b4b0d3a7af373198c12258b306"
  end

  def install
    libffi = Formula["libffi"]
    ENV.prepend "CPPFLAGS", "-I#{libffi.opt_lib}/libffi-#{libffi.version}/include"
    configure_args = %W[
      --has-libatomic_ops
      --has-libffi
      --has-libtommath
      --has-libuv
      --optimize
      --prefix=#{prefix}
    ]
    system "perl", "Configure.pl", *configure_args
    system "make", "realclean"
    system "make"
    system "make", "install"
  end

  test do
    testpath.install resource("nqp")
    out = Dir.chdir("src/vm/moar/stage0") do
      shell_output("#{bin}/moar nqp.moarvm -e 'for (0,1,2,3,4,5,6,7,8,9) { print($_) }'")
    end
    assert_equal "0123456789", out
  end
end

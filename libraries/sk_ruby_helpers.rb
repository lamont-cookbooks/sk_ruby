class SKRubyHelpers
  def self.do_compile?(pkg_path)
    !::File.exist?(pkg_path)
  end
end

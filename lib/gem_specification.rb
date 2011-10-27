class Gem::Specification
  alias_method :__licenses, :licenses

  def licenses
    ary = (__licenses || []).select { |l| l.length > 0 }
    ary.length == 0 ? guess_licenses : ary
  end
  
  def guess_licenses
    licenses = []
    Dir.foreach(full_gem_path) do |filename|
      filename_without_extension = File.basename(filename, File.extname(filename)).downcase
      if filename_without_extension.include?("license")
        parts = filename.split('-')
        if (parts.length >= 2)
          licenses << parts[0].upcase
        else
          licenses = guess_licenses_from_file_contents File.join(full_gem_path, filename)
        end
      elsif filename_without_extension.include?("readme")
        licenses = guess_licenses_from_file_contents File.join(full_gem_path, filename)
      end
      break if licenses.length > 0
    end
    licenses << :unknown if licenses.length == 0
    licenses
  end

  private
  
  def guess_licenses_from_file_contents(path)
    licenses = []
    file_handle = File.new(path, "r")
    while (line = file_handle.gets) && (licenses.size == 0)
      line = line.strip
      # positive matches
      [ /released under the (.*) license/i, /same license as (.*)/i, /^(.*) License, see/i, /^(.*) license$/i, /\(the (.*) license\)/i, /^license: (.*)/i, /^released under the (.*) license/i ].each do |r|
        res = Regexp.new(r).match(line)
        next unless res
        licenses << res.to_s
        break
      end
    end
    file_handle.close
    licenses
  end
  
end


class Array
  def to_ranges
    compact.sort.uniq.inject([]) do |r, x|
      r.empty? || r.last.last.succ != x ? r << (x..x) : r[0..-2] << (r.last.first..x)
    end
  end
end

class GhostScriptParser

  ALLOWED_DEVICES = [:inkcov]

  def initialize(gs_output, device)
    # Instance variables
    @gs_output = gs_output
    @colored_pages = []
    @device = device
    unless ALLOWED_DEVICES.include? device
      raise Exception.new "not in list of allowed devices\n try one of: #{ALLOWED_DEVICES.join(',')}"
    end
  end

  def colored_pages
    if @colored_pages.length==0 and @device == :inkcov
      current_page = 0
      @gs_output.each_line do |line|
        page_line = line.match(/Page [0-9]+/)
        if page_line
          current_page = page_line.to_s.split(' ').last.to_i
        elsif current_page > 0 and line.start_with? ' '
          parts = line.scan(/(\d+[.]\d+)/)
          #  0.05803  0.05803  0.05803  0.00000 CMYK OK
          # first three equal is grey! ignore key (black)
          unless (parts.first == parts[1]) and (parts.first == parts[2])
            # first C,M,Y are different, colored page
            @colored_pages.push current_page.to_i
          end
        end
      end
      @colored_pages
    else
      @colored_pages
    end
  end

  def colored_pages?
    colored_pages.length > 0
  end

  # e.g. 1,3-4 todo: find a better name
  def colored_pages_range_string
    output = []
    @colored_pages.to_ranges.each do |range|
      range_array = range.to_a
      if range_array.length > 1
        output.push "#{range_array.first}-#{range_array.last}"
      else
        output.push range_array.first.to_s
      end
    end
    output.join(',')
  end

end
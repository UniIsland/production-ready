require "csv"
require "ruby-pinyin"
require 'vcardigan'

CSV_HEADER = ["fn", "tel", "tel", "tel", "tel", "tel", "email", "email", "email",
  "email", "email", "org", "title", "url", "url", "url", "url", "url", "note", "note", "bday"]

def phonetic_name(name)
	pinyin = PinYin.of_string(name).reject {|s| s.empty?} .join ' '
	return pinyin[0] == name[0] ? false : ["x-phonetic-first-name", pinyin]
	
end
def row2properties(row)
  return [] if row[0] == 'fn'
  r = []
  row.each_index do |i|
    val = row[i]
    next if val.nil? or val.empty?
    key = CSV_HEADER[i]
    r << [key, val]
    if key == 'fn'
      pinyin = phonetic_name(val)
      r << pinyin if pinyin
    end
  end
  r
end
def parse_row(row)
  properties = row2properties row
  return if properties.size == 0 or properties[0][0] != 'fn'
  vcard = VCardigan.create(:version => '3.0')
	properties.each do |property|
    key,val = property
    case key
    when 'fn'
      vcard.n val
      vcard.fn val
    else
      vcard.send key, val
    end
	end
  begin
    $vcards << vcard.to_s
  rescue VCardigan::EncodingError
    p properties, vcard
    return
  end
end

$vcards = open('./output.vcf', 'wb')

CSV.foreach('./output.csv') do |row|
  parse_row row
end

$vcards.close

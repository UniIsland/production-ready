require 'csv'
require 'vcardigan'

FIELDS = {
  'n' => 1,
  'fn' => 1,
  'tel' => 5,
  'email' => 5,
  'org' => 3,
  'title' => 3,
  'url' => 5,
  'nickname' => 1,
  'note' => 4,
  'adr' => 1,
  'bday' => 1,
  'impp' => 1,
}

def prep
  index = {}
  length = 0
  header = []

  FIELDS.each do |name,len|
    index[name] = [length, len]
    length += len
    if len == 1
      header << name
    else
      len.times { |i| header << name + (i+1).to_s }
    end
  end
  [index,length,header]
end
def vcard2row vcard
  row = Array.new $vlength, ''
  vcard.instance_variable_get('@fields').each do |name,property|
    next unless $vindex.has_key? name
    idx, len = $vindex[name]
    property.uniq! { |s| s.value }
    psize = property.size
    if name == 'n'
      row[idx] = property[0].values.reject {|i| i.empty?} .join(';')
    elsif psize == 1
      row[idx] = property[0].value
    else
      property[0,len].each_index do |i|
        row[idx+i] = property[i].value
      end
    end
  end
  row
end

$vindex, $vlength, $vheader = prep
text = ''
rows = []

vcf = open('./input.vcf')
while l = vcf.gets do
  text << l
  next if l.strip != 'END:VCARD'
  vcard = VCardigan.parse text
  text = ''
  rows << vcard2row(vcard)
end
vcf.close

csv = CSV.open('./input.csv', 'wb')
csv << $vheader
rows.uniq.each { |row| csv << row }
csv.close
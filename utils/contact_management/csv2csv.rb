require 'csv'
require 'set'

#CSV_HEADER = [nil,"fn","tel","tel","tel","tel","tel","email","email","email",
#  "email","email","org",nil,nil,"title",nil,nil,"url","url","url","url","url",
#  nil,"note",nil,nil,nil,nil,"bday",nil]
CSV_HEADER = ["fn", "tel", "tel", "tel", "tel", "tel", "email", "email", "email",
  "email", "email", "org", "title", "url", "url", "url", "url", "url", "note", "note", "bday"]
FIELDS = {
  'fn' => 1,
  'tel' => 5,
  'email' => 5,
  'org' => 1,
  'title' => 1,
  'url' => 5,
  'note' => 2,
  'bday' => 1,
}

$contacts = {}
$map = {
  'tel' => {},
  'email' => {},
  'url' => {},
  'alias' => {},
}

def sanitize_val(key, val)
    case key
    when 'tel'
      val.delete! '- '
      case val
      when /^[1-9][0-9]{0,8}$/, /^\+/ then val
      when /^10[0-9]{8}$/ then val[2,8]
      when /^010[0-9]{8}$/ then val[3,8]
      when /^[48]00[0-9]{7}$/ then val
      when /^[1-9][0-9]{9}$/ then '+1' + val
      when /^1[358][0-9]{9}$/ then '+86' + val
      when /^852[0-9]{8}$/, /^8610[0-9]{8}$/, /^861[358][0-9]{9}$/ then '+' + val
      else val
      end
    when 'email'
      val.downcase
    when 'url'
      val = 'http://' + val unless val.include? '://'
      val.downcase
    else
      val
    end
end
def sanitize_row(row)
  r = []
  row.each_index do |i|
    key = CSV_HEADER[i]
    val = row[i]
    next unless key and val
    val = sanitize_val key, val
    r << [key, val]
  end
  r
end
def find_existing_contact(properties)
  properties.each do |property|
    key,val = property
    case key
    when 'fn'
      return val if $contacts.has_key? val
      return $map['alias'][val] if $map['alias'].has_key? val
    when 'tel', 'email', 'url'
      return $map[key][val] if $map[key].has_key? val
    end
  end
  return nil
end
def update_contact(fn, properties)
  contact = $contacts[fn]
  properties.each do |property|
    key,val = property
    case key
    when 'fn'
      if fn != val
        $map['alias'][val] = fn unless $map['alias'].has_key? val
        contact['note'] = Set.new unless contact.has_key? 'note'
        contact['note'] << 'FN: ' + val
      end
    when 'tel', 'email', 'url', 'note'
      contact[key] = Set.new unless contact.has_key? key
      unless contact[key].include? val
        contact[key] << val
        $map[key][val] = fn unless key == 'note' or $map[key].has_key? val
      end
    when 'org', 'title', 'bday'
      if ! contact.has_key? key
        contact[key] = val
      elsif contact[key] != val
        contact['note'] = Set.new unless contact.has_key? 'note'
        contact['note'] << key.upcase + ': ' + val
      end
    end
  end
end
def add_contact(properties)
  fn = ''
  contact = {}
  properties.each do |property|
    key,val = property
    case key
    when 'fn'
      fn = val
      contact['fn'] = val
    when 'tel', 'email', 'url', 'note'
      contact[key] = Set.new unless contact.has_key? key
      unless contact[key].include? val
        contact[key] << val
        $map[key][val] = fn unless key == 'note'
      end
    when 'org', 'title', 'bday'
      contact[key] = val
    end
  end
  $contacts[fn] = contact
end
def parse_row(row)
  properties = sanitize_row row
  fn = find_existing_contact properties
  if fn
    update_contact(fn, properties)
  else
    add_contact(properties)
  end
end
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
def contact2row(contact)
  row = Array.new $vlength, nil
  contact.each do |k,v|
    idx, len = $vindex[k]
    if %w{tel email url note}.include? k
      v = v.to_a
      v.each_index { |i| row[idx+i] = v[i] }
    else
      row[idx] = v
    end
  end
  row
end

CSV.foreach('./input.csv') do |row|
  parse_row row
end

$vindex, $vlength, $vheader = prep

csv = CSV.open('./output.csv', 'wb')
csv << $vheader
$contacts.each do |fn, contact|
  csv << contact2row(contact)
end
csv.close

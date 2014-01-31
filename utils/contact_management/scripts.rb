require 'set'
require 'vcardigan'

vd = ''
vs = Set.new
vh = {}
open('./t1.vcf') do |f|
  while l=f.gets do
    vd << l
    if l.strip == 'END:VCARD'
      v = VCardigan.parse(vd)
      v.instance_variable_get('@fields').each do |p,ps|
        next if p.size > 10 or ! p.index(/[=\/]/).nil?
        vs << p
        vh[p] = Set.new unless vh.has_key? p
        ps.each do |pp|
          next if pp.to_s.nil?
          vh[p] << pp.to_s.split(':')[0]
        end
      end
      vd = ''
    end
  end
end


vd = ''
vs = Set.new
vss = Set.new
vh = {}
open('./t1.vcf') do |f|
  while l=f.gets do
    vd << l
    if l.strip == 'END:VCARD'
      v = VCardigan.parse(vd)
      v.instance_variable_get('@fields').each do |p,ps|
        next if p.size > 10 or ! p.index(/[=\/]/).nil?
        vs << p
        ps.uniq! { |s| s.to_s }
        vh[p] = 1 unless vh.has_key? p
        pss = ps.size
        vh[p] = pss if pss > vh[p]
        vss << v if pss > 5
      end
      vd = ''
    end
  end
end

vss.each do |v|
  begin
    puts v
  rescue VCardigan::EncodingError
    v.fn 'None'
    retry
  end
  puts
end;nil


vd = ''
vs = Set.new
vh = {}
open('./t1.vcf') do |f|
  while l=f.gets do
    vd << l
    if l.strip == 'END:VCARD'
      v = VCardigan.parse(vd)
      v.instance_variable_get('@fields').each do |p,ps|
        next if p == 'photo' or p.size > 10 or ! p.index(/[-=\/]/).nil?
        vs << p
        ps.uniq! { |s| s.value }
        pss = ps.size
        vh[p] = {} unless vh.has_key? p
        vh[p][pss] = 0 unless vh[p].has_key? pss
        vh[p][pss] += 1
        if pss > 5
          puts v.fn
          puts p
          ps.each { |s| puts s.value }
          puts
        end
      end
      vd = ''
    end
  end
end

v = VCardigan.parse 'BEGIN:VCARD
VERSION:3.0
PRODID:-//Apple Inc.//Mac OS X 10.9.1//EN
N:Su;Yang;;;
FN:Su Yang
ORG:J P Morgan Asset Management Limited
TITLE:Manager
EMAIL;TYPE=["INTERNET", "WORK"];TYPE=pref:yang.su@jpmorgan.com
TEL;TYPE=["CELL", "VOICE"];TYPE=pref:+85290696647
TEL;TYPE=["CELL", "VOICE"]:13823667990
TEL;TYPE=["CELL", "VOICE"]:85290696647
TEL;TYPE=["WORK", "FAX"]:85228685013
TEL;TYPE=["WORK", "VOICE"]:85222651188
TEL;TYPE=["WORK", "VOICE"]:85228009823
NOTE:Card Scanned on 08-07-2012
item1.URL;TYPE=pref:linkedin://#profile/203032059
item1.X-ABLABEL:HomePage
X-ABUID:1D3718DE-22EC-4360-96C5-A956668AD104
END:VCARD'

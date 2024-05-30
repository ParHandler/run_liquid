# coding: UTF-8
require 'liquid'
require 'json'
require 'nokogiri'
require 'xml/to/hash'
require 'cgi'

def unescape_new_line text
    text.gsub("\\\\", '~tyu~').gsub("\\n", "\n").gsub('~tyu~', '\\')
end

def apply_liquid template_fn, data_fn, out_fn
    template = File.open(template_fn, 'rb:UTF-8').read
    data = JSON.parse('{"data":' + File.open(data_fn, 'rb').read+'}')
    liquid_template = Liquid::Template.parse(template)
    out_text = unescape_new_line(liquid_template.render(data))
    File.open(out_fn, 'w') { |file| file.write(out_text) }
    puts out_fn
end

def apply_xslt template_fn, data_fn, out_fn
    xml_doc = Nokogiri::XML(File.read(data_fn,))
    xslt = Nokogiri::XSLT(File.read(template_fn))
    out_text = unescape_new_line(CGI.unescape_html(xslt.apply_to(xml_doc).to_s))
    File.open(out_fn, 'w') { |file| file.write(out_text) }
    puts out_fn
end

#tag::iformat[]
AsciidocDocAutomation = Class.new do
  def iformat(node)
    value = node.to_s
    re = /^([0-9]{4})-([0-9]{2})-([0-9]{2})$/
    vm = value.match(re)
    value = "#{vm[3]}.#{vm[2]}.#{vm[1]}" if !!(value =~ re)
    "&#8203;#{value}&#8203;"
  end
end
#end::iformat[]

apply_liquid 'pu_sql.pu.liquid', 'schema.json', 'pu_sql.pu'
apply_liquid 'adoc_sql.adoc.liquid', 'schema.json', 'adoc_sql.adoc'

Nokogiri::XSLT.register "uri:asciidoc:doc:automation", AsciidocDocAutomation
apply_xslt 'adoc_egrul.xslt', 'prim_egrul.xml', 'adoc_egrul.adoc'
apply_xslt 'adoc_egrul_xsd.xslt', 'prim_egrul.xsd', 'adoc_egrul_xsd.adoc'
apply_xslt 'adoc_egrul_xsd.xslt', 'fns-vipul-types.xsd', 'adoc_egrul_xsd2.adoc'
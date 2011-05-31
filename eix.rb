require 'xmlsimple'

class EixPlugin < Plugin

  def get_eix(arg)
    versions = []
    overlays = {}
    arg = arg.match(/\w+\-?\w+\/?\w+/)

    result = %x[eix -e --only-names '#{arg}'].split("\n")

    if not result.length > 0
      return 'No matches found.'
    elsif result.length > 1
      return "Please be more precise: #{result.join ' '}"
    end

    xml_result = XmlSimple.xml_in %x[eix -e '#{arg}' --xml]

    xml_result['category'][0]['package'][0]['version'].each do |p|
      repo = p['repository'] ||= 'Gentoo'
      overlays[p['repository']] ||= [] 
      overlays[p['repository']] << p['id']
    end

    reply = String.new
    overlays.each do |k, v|
      reply << "#{k}: #{v.join ' '}; "
    end
    reply
  end

  def eix(m, params)
    m.reply get_eix(params[:arg])
  end
end
plugin = EixPlugin.new
plugin.map 'eix :arg'

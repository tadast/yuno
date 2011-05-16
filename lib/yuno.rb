require 'net/http'
require 'rubygems'
require 'nokogiri'
require 'cgi'
# everything is stolen from meme_generator gem
class Yuno
  class Error < RuntimeError; end
  VERSION = '0.0.1'
  USER_AGENT = "yuno/#{VERSION} Ruby/#{RUBY_VERSION}"

  def self.run argv = ARGV
    generator = ARGV

    abort "yuno 'first line' 'second line' | yuno 'second line'" if ARGV.empty?

    yuno = new generator
    link = yuno.generate(*ARGV)
    yuno.paste(link)

    if $stdout.tty?
      puts link
    else
      puts yuno.fetch link
    end
    link
  rescue Interrupt
    exit
  rescue SystemExit
    raise
  rescue Exception => e
    puts e.backtrace.join "\n\t" if $DEBUG
    abort "ERROR: #{e.message} (#{e.class})"
  end

  def initialize generator
  end

  def generate *args
    url = URI.parse 'http://diylol.com/meme-generator/y-u-no/memes'
    res = nil
    location = nil

    args.unshift "Y U NO" if  args.size <= 1

    post_data = { 'post[line1]'  => args[0],
                  'post[line2]'    => args[1],
                  'accept_tos[accepted]' => "1" }

    Net::HTTP.start url.host do |http|
      post = Net::HTTP::Post.new url.path
      post['User-Agent'] = USER_AGENT
      post.set_form_data post_data

      res = http.request post

      location = res['Location']
      redirect = url + location

      get = Net::HTTP::Get.new redirect.request_uri
      get['User-Agent'] = USER_AGENT

      res = http.request get
    end

    if Net::HTTPSuccess === res then
      doc = Nokogiri.HTML res.body
      doc.css("link[rel=\"image_src\"]").first['href']
    else
      raise Error, "diylol appears to be down, got #{res.code}"
    end
  end

  def fetch link
    url = URI.parse link
    res = nil

    Net::HTTP.start url.host do |http|
      get = Net::HTTP::Get.new url.request_uri
      get['User-Agent'] = USER_AGENT

      res = http.request get
    end
    res.body
  end

  def paste link
    require 'pasteboard'
    clipboard = Pasteboard.new
    jpeg = fetch link
    clipboard.put_jpeg_url jpeg, link
  rescue LoadError
    clipboard = %w{/usr/bin/pbcopy /usr/bin/xclip}.find { |path| File.exist? path }

    if clipboard
      IO.popen clipboard, 'w' do |io| io.write link end
    end
  end
end
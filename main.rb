require 'ox'
require 'open-uri'
require 'date'
require 'githubchart'
require 'sinatra'
require 'sinatra/reloader' if development?
require "mini_magick"
require "tempfile"
set :bind, '0.0.0.0'

def date_articles(blog_url)
  oldest_date = Date.today - 366
  dates = (oldest_date..Date.today).map { |e| [e.strftime("%F"), 0] }.to_h
  catch(:nested_break) do
    sitemap_root_url = "#{blog_url}/sitemap.xml"
    xml = open(sitemap_root_url).read
    site_map_urls = Ox.load(xml, mode: :hash_no_attrs)[:sitemapindex][:sitemap]
    # 先頭は記事ではない為除外
    1..14.times do |index|
      site_map_url = site_map_urls[index][:loc]
      xml = open(site_map_url).read
      urls = Ox.load(xml, mode: :hash_no_attrs)
      if urls[:urlset] && urls[:urlset].length > 0
        # urlが１つだけだと配列にならないのでflatten
        urls = [urls[:urlset][:url]].flatten.map{|e| e[:lastmod]}
        urls.each do |lastmod|
          lastmod = Date.parse(lastmod)
          if lastmod >= oldest_date
            dates[lastmod.strftime("%F")] += 1
          else
            throw :nested_break
          end
        end
      end
    end
  end
  return dates
end

def generate_grass(dates)
  options = {
    data: GithubStats::Data.new(dates.to_a)
  }
  return GithubChart.new(options).render('svg')
end

get '/grass' do
  if params[:url]
    dates = date_articles(params[:url])
    svg = generate_grass(dates)
    Tempfile.open(["grass", ".svg"]) do |img_s|
      img_s.puts svg
      Tempfile.open(["grass", ".png"]) do |img_p|
        MiniMagick::Tool::Convert.new do |convert|
          convert << img_s.path
          convert << img_p.path
        end
        send_file(img_p.path)
      end
    end
  else
    "url is required"
  end
end

get '/' do
  erb :index
end

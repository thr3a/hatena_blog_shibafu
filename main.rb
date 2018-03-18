require 'ox'
require 'open-uri'
require 'date'
require 'githubchart'
require 'sinatra'
require 'sinatra/reloader' if development?
require "mini_magick"
require "tempfile"

def date_articles(blog_url)
  oldest_date = Date.today - 366
  dates = (oldest_date..Date.today).map { |e| [e.strftime("%F"), 0] }.to_h
  catch(:nested_break) do
    5.times do |num|
      sitemap_url =  "#{blog_url.gsub(/\/$/, "")}/sitemap.xml?page=#{num + 1}"
      puts sitemap_url
      begin
        xml = open(sitemap_url).read
      rescue => e
        throw :nested_break
      else
        lastmods = Ox.load(xml, mode: :hash_no_attrs)[:urlset][:url].map{|e| e[:lastmod]}
        lastmods.each do |lastmod|
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
  @is_dev = Sinatra::Base.environment == 'development'
  erb :index  
end
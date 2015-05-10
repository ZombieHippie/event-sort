async = require 'async'
cheerio = require 'cheerio'
request = require 'request'
fs = require 'fs'

try
  data = require './data.json'
catch error
  data = {}

updateData = (key, value) ->
  data[key] = value
  fs.writeFileSync "./data.json", JSON.stringify data, null, 2
  console.log "Updated data[#{key}]"

domain = "http://calendar.missouristate.edu"
# Use the index page of all the department course catalogs
# to obtain links to each course offering webpage.
retrieveEventURLs = (callback) ->
  # event_urls[date] = Array
  event_urls = {}
  eventWeekIndexURL = "/default.aspx?category=week"
  request domain + eventWeekIndexURL, (error, response, body) ->
    if error
      callback error

    else
      $index = cheerio.load body
      $index("#ContentColumn .ColumnTrpl").find(">h4").each ->
        h4 = $index(@).text()
        dl = $index(@).next()
        event_urls[h4] = []
        dl.find(">dt").each ->
          time_dt = $index(@)
          event_link = $index(@).next().find("a")
          time_str = time_dt.text()
          time_mil = time_str.replace /(\d+)\:(\d+)[\s\S]+([ap])\.m\./, (match, h, m, ap) ->
            h = parseInt(h)
            h = if ap is "p" then String(h + 12) else if h < 10 then "0"+String(h) else String(h) 
            "#{h}:#{m}"
          info = {
            name: event_link.text()
            href: event_link.attr("href")
            time: time_mil
          }
          event_urls[h4].push info

        return
        li = $index @
        [abbr, name] = li.text().split /\s+\-\s+/
        event_urls[abbr] = {
          name,
          href: li.find("a").attr("href").replace(domain, "")
        }
      callback null, event_urls

if true # not data.event_urls
  retrieveEventURLs (error, event_urls) ->
    if error
      console.error "Error on retrieveEventURLs:"
      console.error error

    else
      updateData "event_urls", event_urls

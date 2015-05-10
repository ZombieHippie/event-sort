async = require 'async'
cheerio = require 'cheerio' 
request = require 'request'
fs = require 'fs'

dlParsers = {
  "Date, Time and Location": (dl)->
    dl.text().trim()
  "Other Dates and Times": (dl) ->
    dl.text().trim()
  "Event Details": (dl) ->
    dl.text().trim()
  "Event Sponsor": (dl) ->
    dl.text().trim()
  "Admission": (dl) ->
    dl.text().trim()
  "Admission Cost": (dl) ->
    dl.text().trim()
  "Contact": (dl) ->
    dl.text().trim()
  "Buy Tickets Online": (dl) ->
    dl.text().trim()
  "Event Website": (dl) ->
    dl.text().trim()
  "Admittance": (dl) ->
    dl.text().trim()
}

# Take cheerio (jQuery) context, and divItem event element, and parse into an object
parseEventPage = ($, div) ->
  div = $ div
  info = {
    title: div.find("h2").text().trim()
  }

  div.find(">dt").each ->
    dt = $ @
    dl = dt.next()
    title = dt.text().trim().slice(0,-1)
    if dlParsers[title]?
      info[title] = dlParsers[title](dl)
    else
      console.log "Unused parser: #{title}, #{dl.text().trim()}"
  return info

# Use the catalog page of a department to research associated courses 
retrieveEventInfo = (eventURL, callback) ->
  request eventURL, (error, response, body) ->
    if error
      callback error

    else
      $evt = cheerio.load body
      callback null, parseEventPage($evt, $evt("#ContentColumn .ColumnTrpl"))

day_list = require('./data.json').event_urls

new_day_list = {}
async.eachSeries( Object.keys(day_list)
  , (day, day_done) ->
    new_day_list[day] = []
    events = day_list[day].sort((a,b)->a.time.localeCompare(b.time))
    async.eachSeries( events
      , (event_info, done) ->
        info = event_info
        retrieveEventInfo event_info.href, (error, retrieved_info) ->
          if error
            done error

          else
            for k, v of retrieved_info 
              info[k] = v
            new_day_list[day].push info
            done()
      , day_done 

      )
  , (error) ->
    if error then console.error "error!", error
    else
      fs.writeFileSync "./events.json", JSON.stringify(new_day_list)
      fs.writeFileSync "./events-test.json", JSON.stringify(new_day_list,null,2)
  )
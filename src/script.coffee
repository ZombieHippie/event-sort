days = {}
daysDate = {}
$(".day").each ->
  days[@.id] = $ @

colWidth = $(".cols>div").width()
maxHeight = document.body.offsetHeight

$(".event").each ->
  evt = $ @
  whenE = evt.find(".when li")[0]
  startTime = moment whenE.dataset.start
  startTimeDay = startTime.format "dddd"
  if not daysDate[startTimeDay]?
    daysDate[startTimeDay] = startTime.format("L")
    days[startTimeDay].find("h2").after("<div class=\"date\">"+startTime.format("L")+"</span>")

  else if daysDate[startTimeDay] isnt startTime.format("L")
    # ensure that we are in the same week
    evt.remove()
    return
    
  startTimeHour = startTime.format("h:mm a")
  if startTimeHour is "12:00 am"
    evt.remove()
    return
  else
    evt.prepend "<span class=\"big-hour\">#{startTimeHour}</span>"
  
  dayE = days[startTimeDay]
  colE = dayE.find ">.cols>div:last-child"
  if colE.height() + evt.height() > maxHeight
    dayE.find(">.cols").append "<div></div>"
    dayE.width(dayE.width() + colWidth)
    colE = dayE.find ">.cols>div:last-child"
    $("body").width($("body").width() + colWidth)

  evt.appendTo colE

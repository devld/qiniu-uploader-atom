
path = require 'path'

module.exports =
  isImageFile: (file) ->
    ext = path.extname(file).toLowerCase().substr(1)
    return ext in ['jpg', 'jpeg', 'png', 'bmp', 'webp', 'gif']

  makeQiNiuKey: (template, file) ->
    date = new Date

    month = date.getMonth() + 1
    month = '0' + month if month < 10
    day = date.getDate()
    day = '0' + day if day < 10
    hour = date.getHours()
    hour = '0' + hour if hour < 10
    minute = date.getMinutes()
    minute = minute + '0' if minute < 10
    second = date.getSeconds()
    second = '0' + second if second < 10

    template = template.replace /{year}/g, date.getFullYear()
    template = template.replace /{month}/g, month
    template = template.replace /{day}/g, day

    template = template.replace /{hour}/g, hour
    template = template.replace /{minute}/g, minute
    template = template.replace /{second}/g, second

    template = template.replace /{timestamp}/g, date.getTime()
    template = template.replace /{filename}/g, path.basename(file)

    template

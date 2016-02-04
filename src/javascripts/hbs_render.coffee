handlebars = require('handlebars')
fs = require('fs')

module.exports =
  (template, variables) ->
    template_file = fs.readFileSync("app/views/templates/#{template}.hbs")
    source = template_file.toString()
    template = handlebars.compile(source)
    template variables

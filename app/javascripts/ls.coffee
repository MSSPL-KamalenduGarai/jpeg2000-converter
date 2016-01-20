$ = require('jQuery')
child_process = require('child_process')

run_ls = ->
  ls = child_process.spawn('ls', ['-lah'])

  ls.stdout.on('data', (data) ->
    console.log("stdout: #{data}")
    console.log data.toString()
    ls_out = data.toString().replace(/(?:\r\n|\r|\n)/g, '<br />')
    $('#container').append(ls_out)
    scroll_terminal()
  )

  ls.stderr.on('data', (data) ->
    console.log("stderr: #{data}")
  )

  ls.on('close', (code) ->
    console.log("child process exited with code #{code}")
    # console.log 'done'
  )

run_ffprobe = ->
  ffprobe = child_process.spawn('ffprobe',
    ['-print_format', 'json', '/home/jason/code/canfee/canfee-out.mp4'])

  # by default it logs to stderr
  ffprobe.stderr.on('data', (data) ->
    console.log("stderr: #{data}")
    # console.log data.toString()
    ffprobe_out = data.toString()
      .replace(/(?:\r\n|\r|\n)/g, '<br>')
      .replace('  ', '&nbsp;&nbsp;')
      .replace("\t", '&nbsp;&nbsp;')
    $('#container').append(ffprobe_out)

    scroll_terminal()
  )

  ffprobe.on('close', (code) ->
    console.log("child process exited with code #{code}")
    # console.log 'done'
  )

run_du = ->
  du = child_process.spawn('du', ['-h', '.'])

  du.stdout.on 'data', (data) ->
    du_out = data.toString().replace(/(?:\r\n|\r|\n)/g, '<br>')
    console.log 'du data'
    $('#container').append(du_out)
    scroll_terminal()
  

  du.on('close', -> console.log 'closed')

scroll_terminal = ->
  $('#container').append("<br><br>")
  myDiv = $("#container")
  myDiv.animate({ scrollTop: myDiv.prop("scrollHeight") - myDiv.height() }, 100)


$(document).ready ->
  $('#ls').on('click', run_ls)

  $(document).ready ->
    $('#ffprobe').on('click', run_ffprobe)

  $(document).ready ->
    $('#du').on('click', run_du)

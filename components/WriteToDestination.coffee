{Component, helpers, InPorts, OutPorts} = require 'noflo'
gulp = require 'gulp'


class WriteToDestination extends Component

  description: 'Equivalent to gulp.dest'
  icon: 'folder'

  constructor: ->
    @inPorts = new InPorts
      path:
        datatype: 'string'
        description: 'The path to be passed to gulp.dest'
        required: true

      stream:
        datatype: 'object'
        description: 'The stream to be piped to gulp.dest'
        required: true

    @outPorts = new OutPorts
      stream:
        datatype: 'object'
        description: 'The stream returned from piping to gulp.dest'


module.exports =
  getComponent: ->
    component = new WriteToDestination

    config =
      in: [
        'path'
        'stream'
      ]
      out: 'stream'

    helpers.WirePattern component, config, (data, groups, outPort) ->
      stream = data.stream.pipe gulp.dest(data.path)
      outPort.send stream

    return component

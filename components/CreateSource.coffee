{Component, InPorts, OutPorts} = require 'noflo'
gulp = require 'gulp'


class CreateSource extends Component

  description: 'Equivalent to gulp.src'
  icon: 'folder-open'

  constructor: ->
    @options = null

    @inPorts = new InPorts
      glob:
        datatype: 'all'
        description: 'The glob(s) to be passed to gulp.src'
        required: true

      options:
        datatype: 'object'
        description: 'The options to be passed to gulp.src'

    @outPorts = new OutPorts
      stream:
        datatype: 'object'
        description: 'The stream returned by gulp.src'
        required: true


    @inPorts.glob.on 'data', (data) =>
      stream = gulp.src data, @options
      @outPorts.stream.send stream

    @inPorts.options.on 'data', (data) =>
      @options = data


module.exports =
  getComponent: -> new CreateSource

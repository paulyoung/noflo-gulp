{Component, helpers, InPorts, OutPorts} = require 'noflo'
gulp = require 'gulp'


class WatchFiles extends Component

  description: 'Equivalent to gulp.watch'
  icon: 'eye'

  constructor: ->
    @options = null

    @inPorts = new InPorts
      glob:
        datatype: 'all'
        description: 'The glob(s) to be passed to gulp.watch'
        required: true

      options:
        datatype: 'object'
        description: 'The options to be passed to gulp.watch'

      tasks:
        datatype: 'string'
        description: 'The names of the tasks to be passed to gulp.watch'
        required: true
        addressable: true

    @outPorts = new OutPorts
      eventEmitter:
        datatype: 'object'
        description: 'The EventEmitter returned by gulp.watch'


    @inPorts.options.on 'data', (data) =>
      @options = data


module.exports =
  getComponent: ->
    component = new WatchFiles

    config =
      in: [
        'glob'
        'tasks'
      ]
      out: 'eventEmitter'
      arrayPolicy:
        in: 'all'

    helpers.WirePattern component, config, (data, groups, outPort) ->
      {glob, tasks:taskPackets} = data
      tasks = (value for key, value of taskPackets)
      eventEmitter = gulp.watch glob, component.options, tasks
      outPort.send eventEmitter

    return component

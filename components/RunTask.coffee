{Component, InPorts} = require 'noflo'
gulp = require 'gulp'


class RunTask extends Component

  description: 'Equivalent to gulp.start'
  icon: 'arrow-right'

  constructor: ->
    @inPorts = new InPorts
      name:
        datatype: 'string'
        description: 'The name of the task to be passed to gulp.start'
        required: true


    @inPorts.name.on 'data', (data) ->
      gulp.start data


module.exports =
  getComponent: -> new RunTask

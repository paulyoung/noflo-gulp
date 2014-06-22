noflo = require 'noflo'
{Component, InPorts, OutPorts} = noflo
gulp = require 'gulp'
path = require 'path'


class CreateTask extends Component

  description: 'Equivalent to gulp.task'
  icon: 'plus'

  constructor: ->
    @dependencies = null

    @inPorts = new InPorts
      graph:
        datatype: 'string'
        description: 'The graph which represents the task'
        required: true

      dependencies:
        datatype: 'string'
        description: 'The names of the dependencies to be passed to gulp.task'
        addressable: true

    @outPorts = new OutPorts
      name:
        datatype: 'string'
        description: 'The name of the task created by gulp.task'


    @inPorts.graph.on 'data', (data) =>
      extension = path.extname data
      name = path.basename data, extension

      gulp.task name, @dependencies, (callback) ->
        baseDir = process.cwd()
        noflo.loadFile data, baseDir, -> callback()

      @outPorts.name.send name

    @inPorts.dependencies.on 'data', (data) =>
      @dependencies ?= []
      @dependencies.push data


module.exports =
  getComponent: -> new CreateTask

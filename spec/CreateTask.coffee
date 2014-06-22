{expect} = require 'chai'
gulp = require 'gulp'
noflo = require 'noflo'
sinon = require 'sinon'
CreateTask = require '../components/CreateTask'


describe 'CreateTask', ->

  component = null

  graph = null
  dependencies = null

  name = null


  beforeEach ->
    component = CreateTask.getComponent()

    graph = noflo.internalSocket.createSocket()
    component.inPorts.graph.attach graph

    dependencies = []

    dependencyOne = noflo.internalSocket.createSocket()
    component.inPorts.dependencies.attach dependencyOne
    dependencies.push dependencyOne

    dependencyTwo = noflo.internalSocket.createSocket()
    component.inPorts.dependencies.attach dependencyTwo
    dependencies.push dependencyTwo

    name = noflo.internalSocket.createSocket()
    component.outPorts.name.attach name


  describe 'graph', ->

    it 'should be required', ->
      required = component.inPorts.graph.isRequired()
      expect(required).to.be.true

    it 'should be a string', ->
      dataType = component.inPorts.graph.getDataType()
      expect(dataType).to.equal 'string'


    context 'when sent', ->

      it 'should have its name passed to gulp.task', ->
        graphName = 'build'
        stub = sinon.stub gulp, 'task'

        graph.send "graphs/#{graphName}.json"

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[0]).to.equal graphName

        stub.restore()


      it 'should create a task that loads the graph', (done) ->
        graphName = 'build'
        graphPacket = "graphs/#{graphName}.json"
        stub = sinon.stub noflo, 'loadFile'

        name.on 'data', (data) ->
          gulp.start graphName

          try
            expect(stub.calledOnce).to.be.true
            expect(stub.firstCall.args[0]).to.equal graphPacket
            done()
          catch e
            done e

        graph.send graphPacket

        stub.restore()


      it 'should send the name of the task created by gulp.task', (done) ->
        graphName = 'build'
        graphPacket = "graphs/#{graphName}.json"
        stub = sinon.stub gulp, 'task', -> graphName

        name.on 'data', (data) ->
          try
            expect(data).to.equal graphName
            done()
          catch e
            done e

        graph.send graphPacket

        stub.restore()


  describe 'dependencies', ->

    it 'should not be required', ->
      required = component.inPorts.dependencies.isRequired()
      expect(required).to.be.false

    it 'should be a string', ->
      dataType = component.inPorts.dependencies.getDataType()
      expect(dataType).to.equal 'string'

    it 'should be addressable', ->
      addressable = component.inPorts.dependencies.isAddressable()
      expect(addressable).to.be.true


    context 'when not sent', ->

      it 'should pass null to gulp.task', ->
        stub = sinon.stub gulp, 'task'

        graph.send 'graphs/build.json'

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[1]).to.be.null

        stub.restore()


    context 'when sent', ->

      it 'should be passed to gulp.task', ->
        dependencyPackets = ['lint', 'compile']
        stub = sinon.stub gulp, 'task'

        for dependencyPacket, index in dependencyPackets
          dependencies[index].send dependencyPacket

        graph.send 'graphs/build.json'

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[1]).to.deep.equal dependencyPackets

        stub.restore()


  describe 'name', ->

    it 'should not be required', ->
      required = component.outPorts.name.isRequired()
      expect(required).to.be.false

    it 'should be a string', ->
      dataType = component.outPorts.name.getDataType()
      expect(dataType).to.equal 'string'

{expect} = require 'chai'
gulp = require 'gulp'
noflo = require 'noflo'
sinon = require 'sinon'
WatchFiles = require '../components/WatchFiles'


describe 'WatchFiles', ->

  component = null

  glob = null
  options = null
  tasks = null

  eventEmitter = null


  beforeEach ->
    component = WatchFiles.getComponent()

    glob = noflo.internalSocket.createSocket()
    component.inPorts.glob.attach glob

    options = noflo.internalSocket.createSocket()
    component.inPorts.options.attach options

    tasks = []

    taskOne = noflo.internalSocket.createSocket()
    component.inPorts.tasks.attach taskOne
    tasks.push taskOne

    taskTwo = noflo.internalSocket.createSocket()
    component.inPorts.tasks.attach taskTwo
    tasks.push taskTwo

    eventEmitter = noflo.internalSocket.createSocket()
    component.outPorts.event_emitter.attach eventEmitter


  describe 'glob', ->

    it 'should be required', ->
      required = component.inPorts.glob.isRequired()
      expect(required).to.be.true

    it 'should be a string or an array', ->
      dataType = component.inPorts.glob.getDataType()
      expect(dataType).to.equal 'all'


    context 'when sent', ->

      it 'should be passed to gulp.watch', ->
        globPacket = '**/*.coffee'
        stub = sinon.stub gulp, 'watch'

        glob.send globPacket
        tasks[0].send 'compile'
        tasks[1].send 'reload'

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[0]).to.equal globPacket

        stub.restore()


      it 'should send the event emitter from gulp.watch', (done) ->
        globPacket = '**/*.coffee'
        fakeWatchEventEmitter = 'fakeWatchEventEmitter'
        stub = sinon.stub gulp, 'watch', -> fakeWatchEventEmitter

        eventEmitter.on 'data', (data) ->
          try
            expect(data).to.equal fakeWatchEventEmitter
            done()
          catch e
            done e

        glob.send globPacket
        tasks[0].send 'compile'
        tasks[1].send 'reload'

        stub.restore()


  describe 'options', ->

    it 'should not be required', ->
      required = component.inPorts.options.isRequired()
      expect(required).to.be.false

    it 'should be an object', ->
      dataType = component.inPorts.options.getDataType()
      expect(dataType).to.equal 'object'


    context 'when not sent', ->

      it 'should pass null to gulp.watch', ->
        stub = sinon.stub gulp, 'watch'

        glob.send '**/*.coffee'
        tasks[0].send 'compile'
        tasks[1].send 'reload'

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[1]).to.be.null

        stub.restore()


    context 'when sent', ->

      it 'should be passed to gulp.watch', ->
        optionsPacket = { cwd: '~' }
        stub = sinon.stub gulp, 'watch'

        glob.send '**/*.coffee'
        options.send optionsPacket
        tasks[0].send 'compile'
        tasks[1].send 'reload'

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[1]).to.deep.equal optionsPacket

        stub.restore()


  describe 'tasks', ->

    it 'should be required', ->
      required = component.inPorts.tasks.isRequired()
      expect(required).to.be.true

    it 'should be a string', ->
      dataType = component.inPorts.tasks.getDataType()
      expect(dataType).to.equal 'string'

    it 'should be addressable', ->
      addressable = component.inPorts.tasks.isAddressable()
      expect(addressable).to.be.true


    context 'when sent', ->

      it 'should be passed to gulp.watch', ->
        taskPackets = ['compile', 'reload']
        stub = sinon.stub gulp, 'watch'

        glob.send '**/*.coffee'
        tasks[index].send taskPacket for taskPacket, index in taskPackets

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[2]).to.deep.equal taskPackets

        stub.restore()


      it 'should send the event emitter from gulp.watch', (done) ->
        fakeWatchEventEmitter = 'fakeWatchEventEmitter'
        stub = sinon.stub gulp, 'watch', -> fakeWatchEventEmitter

        eventEmitter.on 'data', (data) ->
          try
            expect(data).to.equal fakeWatchEventEmitter
            done()
          catch e
            done e

        glob.send '**/*.coffee'
        tasks[0].send 'compile'
        tasks[1].send 'reload'

        stub.restore()


  describe 'event emitter', ->

    it 'should not be required', ->
      required = component.outPorts.event_emitter.isRequired()
      expect(required).to.be.false

    it 'should be an object', ->
      dataType = component.outPorts.event_emitter.getDataType()
      expect(dataType).to.equal 'object'

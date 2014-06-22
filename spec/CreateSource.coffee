{expect} = require 'chai'
gulp = require 'gulp'
noflo = require 'noflo'
sinon = require 'sinon'
CreateSource = require '../components/CreateSource'


describe 'CreateSource', ->

  component = null

  glob = null
  options = null

  stream = null


  beforeEach ->
    component = CreateSource.getComponent()

    glob = noflo.internalSocket.createSocket()
    component.inPorts.glob.attach glob

    options = noflo.internalSocket.createSocket()
    component.inPorts.options.attach options

    stream = noflo.internalSocket.createSocket()
    component.outPorts.stream.attach stream


  describe 'glob', ->

    it 'should be required', ->
      required = component.inPorts.glob.isRequired()
      expect(required).to.be.true

    it 'should be a string or an array', ->
      dataType = component.inPorts.glob.getDataType()
      expect(dataType).to.equal 'all'


    context 'when sent', ->

      it 'should be passed to gulp.src', ->
        globPacket = '**/*.coffee'
        stub = sinon.stub gulp, 'src'

        glob.send globPacket

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[0]).to.equal globPacket

        stub.restore()


      it 'should send the stream from gulp.src', (done) ->
        globPacket = '**/*.coffee'
        fakeSourceStream = 'fakeSourceStream'
        stub = sinon.stub gulp, 'src', -> fakeSourceStream

        stream.on 'data', (data) ->
          try
            expect(data).to.equal fakeSourceStream
            done()
          catch e
            done e

        glob.send globPacket

        stub.restore()


  describe 'options', ->

    it 'should not be required', ->
      required = component.inPorts.options.isRequired()
      expect(required).to.be.false

    it 'should be an object', ->
      dataType = component.inPorts.options.getDataType()
      expect(dataType).to.equal 'object'


    context 'when not sent', ->

      it 'should pass null to gulp.src', ->
        stub = sinon.stub gulp, 'src'

        glob.send '**/*.coffee'

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[1]).to.be.null

        stub.restore()


    context 'when sent', ->

      it 'should be passed to gulp.src', ->
        optionsPacket = { read: false }
        stub = sinon.stub gulp, 'src'

        options.send optionsPacket
        glob.send '**/*.coffee'

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[1]).to.deep.equal optionsPacket

        stub.restore()


  describe 'stream', ->

    it 'should be required', ->
      required = component.outPorts.stream.isRequired()
      expect(required).to.be.true

    it 'should be an object', ->
      dataType = component.outPorts.stream.getDataType()
      expect(dataType).to.equal 'object'

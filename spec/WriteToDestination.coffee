{expect} = require 'chai'
gulp = require 'gulp'
noflo = require 'noflo'
sinon = require 'sinon'
WriteToDestination = require '../components/WriteToDestination'


describe 'WriteToDestination', ->

  component = null

  path = null
  inStream = null

  outStream = null


  beforeEach ->
    component = WriteToDestination.getComponent()

    path = noflo.internalSocket.createSocket()
    component.inPorts.path.attach path

    inStream = noflo.internalSocket.createSocket()
    component.inPorts.stream.attach inStream

    outStream = noflo.internalSocket.createSocket()
    component.outPorts.stream.attach outStream


  describe 'path', ->

    it 'should be required', ->
      required = component.inPorts.path.isRequired()
      expect(required).to.be.true

    it 'should be a string', ->
      dataType = component.inPorts.path.getDataType()
      expect(dataType).to.equal 'string'


    context 'when sent', ->

      it 'should be passed to gulp.dest', ->
        pathPacket = 'lib'
        stub = sinon.stub gulp, 'dest'

        fakeStream = { pipe: (stream) -> stream }

        path.send pathPacket
        inStream.send fakeStream

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[0]).to.equal pathPacket

        stub.restore()


  describe 'stream (in)', ->

    it 'should be required', ->
      required = component.inPorts.stream.isRequired()
      expect(required).to.be.true

    it 'should be an object', ->
      dataType = component.inPorts.stream.getDataType()
      expect(dataType).to.equal 'object'


    context 'when sent', ->

      it 'should have the stream from gulp.dest piped to it', ->
        fakeDestinationStream = 'fakeDestinationStream'
        stub = sinon.stub gulp, 'dest', -> fakeDestinationStream

        fakeStream = { pipe: (stream) -> stream }
        spy = sinon.spy fakeStream, 'pipe'

        path.send 'lib'
        inStream.send fakeStream

        expect(spy.calledOnce).to.be.true
        expect(spy.firstCall.args[0]).to.equal fakeDestinationStream

        stub.restore()


      it 'should send the stream from pipe', (done) ->
        stub = sinon.stub gulp, 'dest', -> 'fakeDestinationStream'

        fakePipeStream = 'fakePipeStream'
        fakeStream = { pipe: (stream) -> fakePipeStream }

        outStream.on 'data', (data) ->
          try
            expect(data).to.equal fakePipeStream
            done()
          catch e
            done e

        path.send 'lib'
        inStream.send fakeStream

        stub.restore()


  describe 'stream (out)', ->

    it 'should not be required', ->
      required = component.outPorts.stream.isRequired()
      expect(required).to.be.false

    it 'should be an object', ->
      dataType = component.outPorts.stream.getDataType()
      expect(dataType).to.equal 'object'

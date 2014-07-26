{expect} = require 'chai'
gulp = require 'gulp'
noflo = require 'noflo'
sinon = require 'sinon'
RunTask = require '../components/RunTask'


describe 'RunTask', ->

  component = null
  name = null


  beforeEach ->
    component = RunTask.getComponent()

    name = noflo.internalSocket.createSocket()
    component.inPorts.name.attach name


  describe 'name', ->

    it 'should be required', ->
      required = component.inPorts.name.isRequired()
      expect(required).to.be.true

    it 'should be a string', ->
      dataType = component.inPorts.name.getDataType()
      expect(dataType).to.equal 'string'


    context 'when sent', ->

      it 'should be passed to gulp.start', ->
        namePacket = 'lint'
        stub = sinon.stub gulp, 'start'

        name.send namePacket

        expect(stub.calledOnce).to.be.true
        expect(stub.firstCall.args[0]).to.equal namePacket

        stub.restore()

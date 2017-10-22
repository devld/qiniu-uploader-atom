{CompositeDisposable} = require 'atom'
config = require './config'

FileUploadView = require './lib/file-uploader'
ClipboardUploadView = require './lib/clipboard-uploader'

module.exports =

  config: config

  activate: (state) ->

    @disposable = new CompositeDisposable

    @disposable.add atom.commands.add(
      'atom-workspace',
      'qiniu-uploader-atom:upload-to-qiniu': => @uploadToQiNiu(false)
    )

    @disposable.add atom.commands.add(
      'atom-workspace',
      'qiniu-uploader-atom:upload-to-qiniu-from-clipboard': => @uploadToQiNiu(true)
    )

  deactivate: ->
    @disposable.dispose()

  serialize: ->

  uploadToQiNiu: (fromClip) ->
    if fromClip
      new ClipboardUploadView
    else
      new FileUploadView

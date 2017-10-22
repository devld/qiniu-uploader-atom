{$, View, TextEditorView} = require "atom-space-pen-views"
{CompositeDisposable} = require 'atom'

{isImageFile} = require '../utils'

QiNiuUploader = require './qiniu/qiniu-uploader'

{dialog, app} = require('electron').remote

clipboard = require 'clipboard'

fs = require 'fs'
path = require 'path'
lastPath = null

defaultPath = app.getPath 'pictures'

module.exports =
class UploadView extends View
  @content: ->
    @div class: 'qiniu-uploader-atom-upload-view', =>
      @label 'File Path'
      @subview 'filePath', new TextEditorView(mini: true)
      @button 'Open File Chooser', outlet: 'openDialog', class: 'btn'
      @label 'Uploading...', class: 'tip ok', outlet: 'uploadingView'
      @label '', class: 'tip err', outlet: 'errorView'
      @div class: 'image-scope', outlet: 'imagePreview', =>
        @label 'Preview'
        @img outlet: 'imageView'

  initialize: ->
    @uploader = new QiNiuUploader

    @previousFocusView = $(document.activeElement)

    @disposable = new CompositeDisposable
    @disposable.add atom.commands.add 'atom-workspace',
      'core:cancel': => @destroy()
      'core:confirm': => @startUpload()
    @panel = atom.workspace.addModalPanel
      item: this

    @openDialog.on 'click', => @openChooser()
    @openDialog.focus()

  destroy: ->
    @panel?.destroy()
    @previousFocusView?.focus()

  detached: ->
    @disposable?.dispose()

  openChooser: ->
    file = dialog.showOpenDialog
      title: 'Choose a file to upload'
      defaultPath: lastPath || (defaultPath if defaultPath)
      properties: ['openFile']
    @filePath.focus()

    return unless file && file.length > 0

    @filePath.setText file[0]
    lastPath = path.dirname file[0]

    @updateImagePreview file[0]

  updateImagePreview: (file) ->
    if isImageFile file
      @imageView.attr('src', file)
      @imagePreview.show()
    else
      @imagePreview.hide()

  startUpload: ->
    file = @filePath.getText()
    unless file
      @openChooser()
      return
    fs.stat file, (e, stat) =>
      return unless !e && stat.isFile()
      @uploadingView.show() # start upload
      @errorView.hide()
      @upload file

  upload: (file) ->
    url = atom.config.get 'qiniu-uploader-atom.qiniuPublicDomain'
    @uploader.uploadFile file, (succ, hash, key, err) =>
        @uploadingView.hide()
        unless succ
          @errorView.text "Failed: #{err}"
          @errorView.show()
          return
        atom.clipboard.write url + key
        atom.notifications.addSuccess 'The url has been copied to the clipboard.'
        @destroy()

{$, View, TextEditorView} = require "atom-space-pen-views"
{CompositeDisposable} = require 'atom'

QiNiuUploader = require './qiniu/qiniu-uploader'

clipboard = require 'clipboard'

{isImageFile} = require '../utils'

imageExt = '.png'

module.exports =
class UploadView extends View
  @content: ->
    @div class: 'qiniu-uploader-atom-upload-view', =>
      @label 'Image Filename'
      @subview 'filename', new TextEditorView(mini: true)
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

    @defaultName = "#{new Date().getTime()}#{imageExt}"
    @filename.setText @defaultName

    @filename.focus()
    @getImageFromClipBoard()

  getImageFromClipBoard: ->
    @img = clipboard.readImage()
    if @img.isEmpty()
      atom.notifications.addInfo 'There is no image copied to clipboard.'
      @destroy()
      return
    @imageView.attr 'src', @img.toDataURL()
    @imagePreview.show()

  destroy: ->
    @panel?.destroy()
    @previousFocusView?.focus()

  detached: ->
    @disposable?.dispose()

  startUpload: ->
    @uploadingView.show()
    @errorView.hide()
    name = @filename.getText() || @defaultName
    name += imageExt if not name.endsWith imageExt
    imgData = @img.toPNG()

    url = atom.config.get 'qiniu-uploader-atom.qiniuPublicDomain'
    @uploader.uploadData imgData, name, (succ, hash, key, err) =>
      @uploadingView.hide()
      unless succ
        @errorView.text "Failed: #{err}"
        @errorView.show()
        return
      atom.clipboard.write url + key
      atom.notifications.addSuccess 'The url has been copied to the clipboard.'
      @destroy()

qiniu = require 'qiniu'
{makeQiNiuKey} = require '../../utils'

makeUploadToken = (ak, sk, scope) ->
  mac = new qiniu.auth.digest.Mac ak, sk
  options =
    scope: scope
  putPolicy = new qiniu.rs.PutPolicy options
  return putPolicy.uploadToken mac

checkConfig = () ->
  ak = atom.config.get 'qiniu-uploader-atom.qiniuAk'
  sk = atom.config.get 'qiniu-uploader-atom.qiniuSk'
  bucket = atom.config.get 'qiniu-uploader-atom.bucket'
  keyFormat = atom.config.get 'qiniu-uploader-atom.keyFormat'
  unless ak && sk && bucket && keyFormat
    atom.workspace.open('atom://config/packages/qiniu-uploader-atom')
    return
  return {
    ak: ak
    sk: sk
    bucket: bucket
    keyFormat: keyFormat
  }

module.exports =
class QiNiuUploader
  constructor: () ->
    @config = new qiniu.conf.Config
    @config.zone = qiniu.zone.Zone_z0

  uploadFile: (file, cb) ->
    return cb && cb(false, null, null, 'Please check your settings.') unless info = checkConfig()
    putExtra = new qiniu.form_up.PutExtra
    formUploader = new qiniu.form_up.FormUploader @config
    formUploader.putFile makeUploadToken(info.ak, info.sk, info.bucket),
      makeQiNiuKey(info.keyFormat, file), file, putExtra,
      (err, resBody, resInfo) =>
        cb && cb(
          !!!err && resInfo?.statusCode == 200,
          resBody?.hash,
          resBody?.key,
          resBody?.error
        )

  uploadData: (data, filename, cb) ->
    return cb && cb(false, null, null, 'Please check your settings.') unless info = checkConfig()
    putExtra = new qiniu.form_up.PutExtra
    formUploader = new qiniu.form_up.FormUploader @config
    formUploader.put makeUploadToken(info.ak, info.sk, info.bucket),
      makeQiNiuKey(info.keyFormat, filename), data, putExtra,
      (err, resBody, resInfo) =>
        cb && cb(
          !!!err && resInfo?.statusCode == 200,
          resBody?.hash,
          resBody?.key,
          resBody?.error
        )

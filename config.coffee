
module.exports =
  qiniuAk:
    title: 'QiNiu Access Key'
    default: ''
    type: 'string'

  qiniuSk:
    title: 'QiNiu Secret Key'
    default: ''
    type: 'string'

  bucket:
    title: 'QiNiu Bucket Name'
    default: ''
    type: 'string'

  keyFormat:
    title: 'QiNiu Key Format'
    type: 'string'
    description: '
        Available key:\n
          {year}, {month}, {date}, {hour}, {minute}, {second}, {timestamp}, {filename}
      '
    default: '{year}/{month}/{filename}'

  qiniuPublicDomain:
    title: 'QiNiu Public Download Domain'
    description: 'Must end with \'/\''
    default: ''
    type: 'string'

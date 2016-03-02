# ROT13 the email address.
module.exports = (obj, cb) =>
  cb null, obj.email.replace(/[a-zA-Z]/g, (c) ->
      String.fromCharCode (if ((if c <= "Z" then 90 else 122)) >= (c = c.charCodeAt(0) + 13) then c else c - 26)
  ) if obj.email?

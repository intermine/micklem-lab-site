{ blað } = require 'blad'

marked = require 'marked'

class exports.NewsDocument extends blað.Type

    render: (done) ->
        @body = marked @body
        done @
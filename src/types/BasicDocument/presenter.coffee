{ blað } = require 'blad'

marked = require 'marked'

class exports.BasicDocument extends blað.Type

    render: (done) ->
        # Markdown?
        @body = marked @body if @body?

        done @
marked = require 'marked'

class exports.NewsDocument

    render: (done) ->
        @body = marked @body
        done @
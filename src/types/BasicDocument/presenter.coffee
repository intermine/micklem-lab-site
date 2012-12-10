marked = require 'marked'

class exports.BasicDocument

    render: (done) ->
        # Markdown?
        @body = marked @body if @body?

        done @
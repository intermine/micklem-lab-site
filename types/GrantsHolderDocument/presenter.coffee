{ blað } = require 'blad'

marked = require 'marked'

class exports.GrantsHolderDocument extends blað.Type

    render: (done) ->
        # Get all current grants underneath.
        @grants = ( (g.summary = marked g.summary ; g) for g in @children(0) when g.current )

        # Markdown.
        @body = marked @body
        
        # We done.
        done @
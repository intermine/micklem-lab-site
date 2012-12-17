{ blað } = require 'blad'

marked = require 'marked'

class exports.PeopleHolderDocument extends blað.Type

    render: (done) ->
        preferential = []
        # Do we have preferential names?
        if @preferential and @preferential.length isnt 0
            # Do we have more than one?
            if @preferential.indexOf(',') isnt -1
                # Replace space following a comma and split.
                preferential = @preferential.replace(/,([\s])+/g, ',').split(',')
            else
                preferential = [ @preferential ]

        # Sort people Gos first, then by surname.
        @people = @children(0).sort (a, b) =>
            others = -> if b.name.split(' ').pop() > a.name.split(' ').pop() then -1 else 1
            switch preferential.length
                when 0
                    return others()
                when 1
                    console.log a.name, b.name
                    if a.name is preferential[0] then return -1
                    else if b.name is preferential[0] then return 1
                    else return others()
                else
                    # Get their index in preferential list. -1 if not in there.
                    aIndex = preferential.indexOf(a.name) ; bIndex = preferential.indexOf(b.name)

                    # First not preferential.
                    if aIndex is -1
                        # Second not preferential.
                        if bIndex is -1 then return others()
                        # Preferential goes first.
                        else return 1
                    else
                        # Second not preferential, preferential goes first.
                        if bIndex is -1 then return -1
                        # Preferentials sorted on their list order.
                        else aIndex - bIndex

        # Markdown.
        @body = marked @body

        done @
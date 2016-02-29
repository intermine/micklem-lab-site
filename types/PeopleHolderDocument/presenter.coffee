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

        # Filter down people to active members.
        @alumni = false ; people = []
        for ch in @children(0)
            if ch.type is 'PersonDocument'
                if ch.alumnus then @alumni = true
                else people.push ch

        # Sort people Gos first, then by surname.
        @people = people.sort (a, b) =>
            # For 'normal' people sort surname first, then the rest of the names.
            others = ->
                aFirstNames = a.name.split(' ') ; bFirstNames = b.name.split(' ')
                aSurname = aFirstNames.pop()    ; bSurname = bFirstNames.pop()
                if bSurname > aSurname then -1
                else
                    if aSurname > bSurname then 1
                    else
                        if bFirstNames > aFirstNames then -1 else 1
            
            # How many preferential people do we have?
            switch preferential.length
                when 0
                    return others()
                when 1
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
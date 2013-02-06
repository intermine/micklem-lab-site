{ blað } = require 'blad'

marked = require 'marked'
kronic = require 'kronic-node'

class exports.PersonDocument extends blað.Type

    render: (done) ->
        # Get other projects.
        @siblings (siblings) =>
            @parent (parent) =>
                preferential = []
                # Do we have preferential names?
                if parent.preferential and parent.preferential.length isnt 0
                    # Do we have more than one?
                    if parent.preferential.indexOf(',') isnt -1
                        # Replace space following a comma and split.
                        preferential = parent.preferential.replace(/,([\s])+/g, ',').split(',')
                    else
                        preferential = [ parent.preferential ]

                # Filter down people to active members.
                @alumni = false ; people = []
                for sib in siblings
                    if sib.type is 'PersonDocument'
                        if sib.alumnus then @alumni = true
                        else people.push sib

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
                
                # Our publications in chronological order.
                pubs = []
                for i in [0...10]
                    if @["pubTitle#{i}"]
                        pubs.push
                            'link':      @["pubURL#{i}"] or ''
                            'title':     @["pubTitle#{i}"] or ''
                            'journal':   @["pubJournal#{i}"] or ''
                            'authors':   @["pubAuthors#{i}"] or ''
                            'published': @["pubDate#{i}"] or 0

                @publications = pubs.sort (a, b) ->
                    parseDate = (date) ->
                        return 0 if date is 0
                        [ year, month, day] = date.split(' ')
                        month = month or 'Jan' ; day = day or 1
                        p = kronic.parse([ day, month, year ].join(' '))
                        if p then p.getTime() else 0

                    if parseDate(b.published) > parseDate(a.published) then 1
                    else -1
                
                # We done.
                done @
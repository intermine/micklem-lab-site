{ blað } = require 'blad'

marked = require 'marked'
kronic = require 'kronic-node'

class exports.PersonDocument extends blað.Type

    render: (done) ->
        # Get other projects.
        @siblings (people) =>
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

                # Sort people Gos first, then by surname.
                @people = people.sort (a, b) =>
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
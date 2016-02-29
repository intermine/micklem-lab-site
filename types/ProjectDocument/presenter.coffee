{ blað }  = require 'blad'
additions = require '../additions'

request = require 'request'
marked  = require 'marked'

class exports.ProjectDocument extends blað.Type

    eSummary: 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id='

    render: (done) ->
        # Get other projects.
        @siblings (projects) =>
            # Get all siblings of the same "currency".
            @archive = false ; @notArchive = false
            @projects = []
            for p in projects
                if @current and p.current
                    if p.summary then p.summary = marked p.summary
                    @projects.push p
                else
                    if @current then @archive = true else @notArchive = true

            # Markdown.
            @body = marked @body
            
            # Do we have pubmed ids for this project?
            return done @ unless @pubmed

            # Check if data in store is old.
            if @store.isOld 'pubmedPublications', 1, 'day'
                # Grab hold of the actual publications.
                request @eSummary + @pubmed.replace(/\ /g,''), (err, res, body) =>
                    return done @ if err or res.statusCode isnt 200

                    additions.xmlToPubs body, (pubmed) =>
                        # Translate journal names.
                        pubmed.map (pub) ->
                            pub.FullJournalName = additions.translate pub.FullJournalName
                            pub

                        # Reverse chronological order sort.
                        pubmed = additions.pubmedSort pubmed

                        # Cache the new data.
                        @store.save 'pubmedPublications', pubmed, =>
                            # Finally render.
                            @publications = pubmed
                            done @
            else
                # Render the 'old' stuff.
                @publications = @store.get 'pubmedPublications'
                done @
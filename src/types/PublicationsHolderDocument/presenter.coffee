{ blað }  = require 'blad'
additions = require '../additions'

request = require 'request'

class exports.PublicationsHolderDocument extends blað.Type

    eSearch: 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmax=999&term='
    eSummary: 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id='

    render: (done) ->
        # Check if data in store is old.
        if @store.isOld 'pubmedPublications', 1, 'day'
            # Which author are we fetching publications for?
            author = encodeURIComponent "#{@author}[author]"
            # Grab hold of publication IDs.
            request @eSearch + author, (err, res, body) =>
                return done @ if err or res.statusCode isnt 200
                
                additions.xmlToIds body, (ids) =>
                    # Enrich with extra identifiers not returned by the above query.
                    if @extraIds
                        ids = ids.concat @extraIds.replace(/\s/g, '').split(',')

                    # Do we actually have any new publications to get?
                    oldIds = @store.get 'pubmedPublicationIds'
                    if oldIds and not (ids < oldIds or oldIds < ids)
                        # Render the 'old' stuff.
                        @publications = @store.get 'pubmedPublications'
                        done @
                    else
                        # Save the new IDs.
                        @store.save 'pubmedPublicationIds', ids, =>

                            # Grab hold of the actual publications.
                            request @eSummary + ids.join(','), (err, res, body) =>
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
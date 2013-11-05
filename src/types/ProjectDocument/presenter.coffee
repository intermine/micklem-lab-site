{ blað } = require 'blad'

request  = require 'request'
kronic   = require 'kronic-node'
marked   = require 'marked'
sax      = require('sax').parser(true)

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

                    @xmlToPubs body, (pubmed) =>
                        # Reverse chronological order sort.
                        pubmed = pubmed.sort (a, b) ->
                            parseDate = (date) ->
                                return 0 if date is 0
                                
                                [ year, month, day ] = date.split(' ')
                                year = parseInt(year) ; month = month or 'Jan' ; day = parseInt(day) or 1
                                
                                p = kronic.parse([ day, month, year ].join(' '))
                                if p then p.getTime() else 0

                            if parseDate(b.PubDate) > parseDate(a.PubDate) then 1
                            else -1

                        # Cache the new data.
                        @store.save 'pubmedPublications', pubmed, =>
                            # Finally render.
                            @publications = pubmed
                            done @
            else
                # Render the 'old' stuff.
                @publications = @store.get 'pubmedPublications'
                done @

    # Take eSummary XML and call back with publications.
    xmlToPubs: (xml, cb) ->
        docs = [] ; doc = {} ; tag = {} ; authors = []

        sax.onattribute = (attr) -> tag[attr.name] = attr.value

        sax.onclosetag = (node) ->
            switch node
                when 'DocSum'
                    doc.Authors = authors
                    docs.push doc
                    doc = {} ; authors = []
                when 'Id'
                    doc.Id = tag.Text
                    tag = {}
                when 'Item'
                    switch tag.Name
                        when 'PubDate', 'FullJournalName', 'Title' then doc[tag.Name] = tag.Text
                        when 'Author' then authors.push tag.Text
                    tag = {}

        sax.ontext = (text) ->
            text = text.replace(/\s+/g, ' ')
            if text isnt ' ' then tag.Text = text

        sax.onend = -> cb docs

        sax.write(xml).close()
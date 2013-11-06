sax    = require('sax').parser(true)
kronic = require 'kronic-node'

# Translation rules.
rules =
    'Bioinformatics (Oxford, England)': 'Bioinformatics'
    'Current biology : CB': 'Current biology'
    'Development (Cambridge, England)': 'Development'
    'Science (New York, N.Y.)': 'Science'

module.exports =
    translate: (input) ->
        rules[input] ?= input # save us if not present
        rules[input]

    # Take eSearch XML and call back with ids.
    xmlToIds: (xml, cb) ->
        open = false ; ids = []
        
        sax.onopentag = (node) -> open = node.name is 'Id'
        sax.ontext = (text) -> if open and parseInt text then ids.push text
        sax.onend = -> cb ids.sort()
        
        sax.write(xml).close()

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

    # PubMed publications reverse chronological order sort.
    pubmedSort: (arr, key='PubDate') ->
        arr.sort (a, b) ->
            parseDate = (date) ->
                return 0 if date is 0
                
                [ year, month, day ] = date.split(' ')
                year = parseInt(year) ; month = month or 'Jan' ; day = parseInt(day) or 1
                
                p = kronic.parse([ day, month, year ].join(' '))
                if p then p.getTime() else 0

            if parseDate(b[key]) > parseDate(a[key]) then 1
            else -1

    # Sort people by their name.
    peopleSort: (arr) ->
        arr.sort (a, b) ->
            # For 'normal' people sort surname first, then the rest of the names.
            aFirstNames = a.name.split(' ') ; bFirstNames = b.name.split(' ')
            aSurname = aFirstNames.pop()    ; bSurname = bFirstNames.pop()
            if bSurname > aSurname then -1
            else
                if aSurname > bSurname then 1
                else
                    if bFirstNames > aFirstNames then -1 else 1
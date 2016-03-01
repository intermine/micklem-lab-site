request = require 'request'

additions = require './additions.coffee'

E_SEARCH = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmax=999&term='
E_SUMMARY = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id='

module.exports = (data, cb) =>
    # Which author are we fetching publications for?
    author = encodeURIComponent "#{data.author}[author]"
    # Grab hold of publication IDs.
    request E_SEARCH + data.author, (err, res, body) =>
      return do cb if err or res.statusCode isnt 200

      additions.xmlToIds body, (ids) =>
        # Enrich with extra identifiers not returned by the above query.
        if 'extraIds' in data
          ids = ids.concat data.extraIds.replace(/\s/g, '').split(',')

        # Grab hold of the actual publications.
        request E_SUMMARY + ids.join(','), (err, res, body) =>
          return do cb if err or res.statusCode isnt 200

          additions.xmlToPubs body, (pubmed) =>
            # Translate journal names.
            pubmed.map (pub) ->
              pub.FullJournalName = additions.translate pub.FullJournalName
              pub

            # Reverse chronological order sort.
            cb null, additions.pubmedSort pubmed

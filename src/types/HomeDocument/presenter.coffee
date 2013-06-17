{ blað } = require 'blad'

marked   = require 'marked'
request  = require 'request'
kronic   = require 'kronic-node'
sax      = require('sax').parser(true)

class exports.HomeDocument extends blað.Type

    # Hardcode the link to Twitter RSS.
    twitter: 'http://twitter-rss.com/user_timeline.php?screen_name=intermineorg'

    render: (done) ->
        # Markdown.
        @welcomeText = marked @welcomeText

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

        # Children documents.
        @sub = {}
        for page in @children 1 # not direct descendants
            @sub[page.type] ?= []

            # Sub parsing.
            switch page.type
                when 'ProjectDocument', 'GrantDocument'
                    if page.home # should show on homepage?
                        page.summary = marked page.summary
                        @sub[page.type].push page
                else
                    @sub[page.type].push page

        # Randomize projects and funding.
        @sub.ProjectDocument = randomArray @sub.ProjectDocument
        @sub.GrantDocument = randomArray @sub.GrantDocument

        # Check if data in store is old.
        if @store.isOld 'tweet', 1, 'day'
             # Fetch the latest tweet.
            request @twitter, (err, res, body) =>
                return done @ if err or res.statusCode isnt 200
                
                @rssToTweet body, (tweet) =>
                    # Cache the new data.
                    @store.save 'tweet', tweet, =>
                        # Get the tweet, add ago time and render.
                        @tweet = @store.get 'tweet'
                        @tweet.ago = kronic.format new Date @tweet.pubDate
                        done @
        else
            # Get the tweet, add ago time and render.
            @tweet = @store.get 'tweet'
            @tweet.ago = kronic.format new Date @tweet.pubDate
            done @
    
    # Get the latest tweet from an RSS feed.
    rssToTweet: (xml, cb) ->
        step = 0 ; _ref = null; tweet = [] ; ids = []
        
        # An item will have a title tag.
        sax.onopentag = (node) ->
            switch step
                # Are we entering the first item?
                when 0
                    # OK then switch our step to 'entry mode'.
                    step = 1 if node.name is 'item'
                
                # Are we in entry mode?
                when 1
                    # Then push this inner node.
                    tweet.push _ref = { 'attr': node.name, 'value': '' }
        
        # The first item has been processed. Do not allow any more editing.
        sax.onclosetag = (name) ->
            step = 2 if name is 'item'
        
        # ... and then we can scoop its text.
        sax.ontext = (text) ->
            # Get the last pushed element.
            _ref.value = _ref.value + text.replace(/(\r\n|\n|\r|\t)/gm, '') if step is 1 and _ref
        
        # Return tweet object from an array.
        sax.onend = ->
            obj = {}
            ( obj[attr] = value for { attr, value } in tweet )
            cb obj
        
        sax.write(xml).close()

# Seed array randomly.
randomArray = (arr) ->
    i = arr.length
    return [] if i is 0
    while --i
        j = Math.floor(Math.random() * (i + 1))
        tempi = arr[i]
        tempj = arr[j]
        arr[i] = tempj
        arr[j] = tempi
    arr
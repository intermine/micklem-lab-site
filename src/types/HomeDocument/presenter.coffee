{ blað }  = require 'blad'
additions = require '../additions'

marked  = require 'marked'
request = require 'request'
kronic  = require 'kronic-node'
Twit    = require 'twit'

class exports.HomeDocument extends blað.Type

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

        @publications = additions.pubmedSort pubs, 'published'

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

        # Do we have Twitter env vars?
        opts = {}
        ( opts[do v[8...].toLowerCase] = process.env[v] for v in [
            'TWITTER_CONSUMER_KEY'
            'TWITTER_CONSUMER_SECRET'
            'TWITTER_ACCESS_TOKEN'
            'TWITTER_ACCESS_TOKEN_SECRET'
        ] when process.env[v] )

        return done @ if Object.keys(opts).length isnt 4

        # Do we have it cached?
        if @store.isOld 'tweet', 1, 'day'
            # New client.
            (new Twit(opts)).get 'statuses/user_timeline', (err, res) =>
                return done @ if err
                return done @ unless res instanceof Array
                return done @ unless res.length

                tweet = res[0]

                # Format date.
                tweet.created_at = kronic.format new Date tweet.created_at

                # Cache it.
                @store.save 'tweet', tweet, =>
                    # Finally render.
                    @tweet = tweet
                    done @

        else
            # Render the 'old' stuff.
            @tweet = @store.get 'tweet'
            done @

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
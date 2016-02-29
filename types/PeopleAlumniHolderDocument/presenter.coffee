{ blað }  = require 'blad'
additions = require '../additions'

marked = require 'marked'

class exports.PeopleAlumniHolderDocument extends blað.Type

    render: (done) ->
        # Get people on the same level as us.
        @siblings (people) =>
            # Only give us people.
            alumni = ( p for p in people when p.type is 'PersonDocument' and p.alumnus )

            # Sort people.
            @alumni = additions.peopleSort alumni

            done @
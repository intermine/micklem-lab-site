{ blað } = require 'blad'

marked = require 'marked'

class exports.PeopleAlumniHolderDocument extends blað.Type

    render: (done) ->
        # Get people on the same level as us.
        @siblings (people) =>
            # Only give us people.
            alumni = ( p for p in people when p.type is 'PersonDocument' and p.alumnus )

            # Sort people.
            @alumni = alumni.sort (a, b) =>
                # For 'normal' people sort surname first, then the rest of the names.
                aFirstNames = a.name.split(' ') ; bFirstNames = b.name.split(' ')
                aSurname = aFirstNames.pop()    ; bSurname = bFirstNames.pop()
                if bSurname > aSurname then -1
                else
                    if aSurname > bSurname then 1
                    else
                        if bFirstNames > aFirstNames then -1 else 1

            done @
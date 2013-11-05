# Translation rules.
rules =
    'Bioinformatics (Oxford, England)': 'Bioinformatics'
    'Current biology : CB': 'Current biology'
    'Development (Cambridge, England)': 'Development'
    'Science (New York, N.Y.)': 'Science'

module.exports =
    'translate': (input) ->
        rules[input] ?= input # save us if not present
        rules[input]
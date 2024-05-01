Langs = {
    ['ES'] = {
        Seats = ' Plazas',

    },
    ['EN'] = {
        Test = 'Test EN'
    },
}



function Text(key, ...)
    local translation = Langs[Conce.userLang][key]
    if translation then
        return (translation):format(...)
    else
        return 'Not locale: ' .. key
    end
end

print(Text('Test'))



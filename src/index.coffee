readline = require 'readline'
fs = require 'fs'
path = require 'path'
util = require 'util'
objectAssign = require 'object-assign'

getHomeDir = ->
    return process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE

historyPath = (name) ->
    path.resolve getHomeDir(), '.' + name + '.qrepl'

colors =
    red: 31
    green: 32
    yellow: 33
    blue: 34
    magenta: 35
    cyan: 36

colored = (s, color) ->
    color_code = colors[color] or 0
    prefix = '\x1b[' + color_code + 'm'
    suffix = '\x1b[0m'
    return prefix + s + suffix

module.exports = (name, fn, options={}) ->

    loadHistory = (cb) ->
        fs.readFile historyPath(name), (err, history_data) ->
            return cb null, [] if !history_data
            history_lines = history_data.toString().trim().split('\n')
            history_lines.reverse()
            cb null, history_lines

    saveHistory = (line) ->
        fs.appendFileSync historyPath(name), line + '\n'

    rl = readline.createInterface objectAssign
        input: process.stdin
        output: process.stdout
    , options

    # Overload readline's addHistory to save to our history file
    rl_addHistory = rl._addHistory
    rl._addHistory = ->
        last = rl.history[0]
        line = rl_addHistory.call(rl)
        saveHistory(line) if last != line
        return line

    # Bootstrap history from file
    loadHistory (err, saved_history) ->
        rl.history.push.apply(rl.history, saved_history)

    prompt_text = '> '
    rl.setPrompt colored(prompt_text, 'cyan'), prompt_text.length

    rl.prompt()

    rl.on 'line', (line) ->
        line = line.trim()
        fn line, (err, result) ->
            if err?
                if Array.isArray err
                    err.map (err) ->
                        console.error colored(err.message, 'red')
                else
                    console.error err
            else if result?
                if typeof result == 'string'
                    console.log result
                else
                    console.log util.inspect result, {colors: true, depth: null}
            rl.prompt()


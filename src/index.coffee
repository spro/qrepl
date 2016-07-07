readline = require 'readline'
fs = require 'fs'
path = require 'path'
util = require 'util'

getHomeDir = ->
    return process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE

historyPath = (name) ->
    path.resolve getHomeDir(), '.' + name + '.qrepl'

module.exports = (name, fn) ->

    loadHistory = (cb) ->
        fs.readFile historyPath(name), (err, history_data) ->
            return cb null, [] if !history_data
            history_lines = history_data.toString().trim().split('\n')
            history_lines.reverse()
            cb null, history_lines

    saveHistory = (line) ->
        fs.appendFile historyPath(name), line + '\n'

    rl = readline.createInterface
        input: process.stdin
        output: process.stdout

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
    color = 36
    prefix = '\x1b[' + color + 'm'
    suffix = '\x1b[0m'
    rl.setPrompt prefix + prompt_text + suffix, prompt_text.length

    rl.prompt()

    rl.on 'line', (line) ->
        line = line.trim()
        fn line, (err, result) ->
            console.log util.inspect result, {colors: true, depth: null}
            rl.prompt()


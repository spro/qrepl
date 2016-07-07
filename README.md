# qrepl

Quick repl helper

```
npm install qrepl
```

```coffee
qrepl = require 'qrepl'

history_name = 'test'

runLine = (line, cb) ->
    cb null, 'your line was ' + line

qrepl history_name, runLine
```

```
> hello
your line was hello
```

A history file will be saved as `~/.[history_name].qrepl`

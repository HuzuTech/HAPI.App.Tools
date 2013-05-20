tools = require "./src/tools.coffee"

build = (callback) ->
    tools.print "Building lib", true
    tools.cmd "coffee", ["-c", "-o", "lib/", "src/"], ->
        tools.print "Done"
        callback?()

task "build", "build the js lib", ->
    build()

task "version", "write and commit the package version", ->
    version (v) ->
        writePackageVersion v, ->
            commitVersion()

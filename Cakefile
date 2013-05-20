tools = require "./src/tools.coffee"

build = (callback) ->
    tools.print "Building lib", true
    tools.localCmd "coffee", ["-c", "-o", "lib/", "src/"], ->
        tools.print "Done"
        callback?()

task "build", "build the js lib", ->
    build()

task "version", "write and commit the package version", ->
    tools.version (v) ->
        tools.writePackageVersion v, ->
            tools.commitVersion v

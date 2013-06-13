fs = require "fs"
os = require "os"
child_process = require "child_process"

class Tools
    localBin: "./node_modules/.bin"

    print: (msg, header = false) ->
        console.log "####################################################" if header
        console.log msg

    cmd: (cmd, args, callback, local=false) ->
        isWindows = os.platform().match /^win/
        cmd = "#{@localBin}/#{cmd}" if local
        if isWindows
            args.unshift cmd
            args.unshift "node" if local
            cmd = args.join " "
            @exec cmd, callback
        else
            @spawn cmd, args, callback

    localCmd: (cmd, args, callback) ->
        @cmd cmd, args, callback, true

    spawn: (cmd, args, callback) ->
        @print "#{cmd} #{args?.join ' '}"
        p = child_process.spawn cmd, args
        p.stdout.setEncoding("utf8")
        p.stdout.on "data", (data) ->
            process.stdout.write data
        p.stderr.setEncoding('utf8')
        p.stderr.on "data", (data) ->
            process.stderr.write data
        p.on "exit", (code) ->
            callback?(code)

    exec: (cmd, callback) ->
        # use this to return a value to the callback
        child_process.exec cmd, (err, stdout, stderr) =>
            @print "#{cmd}"
            @print stdout, false
            @print "'#{cmd}': ERROR: #{err}", false if err
            callback? stdout[..-2]

    fetchTags: (callback) ->
        @cmd "git", ["fetch", "--tags"], callback

    currentTag: (callback) ->
        @fetchTags =>
            @exec "git describe --abbrev=0", callback

    mergesSinceTag: (tag, callback) ->
        @exec "git rev-list #{tag}..HEAD --count --merges", callback

    version: (callback) ->
        @currentTag (tag) =>
            @mergesSinceTag tag, (merges) ->
                callback "#{tag}.#{merges}"

    writeToPackageJson: (hash, callback) ->
        pkg = "package.json"
        fs.readFile pkg, (err, str) ->
            json = JSON.parse str
            for k, v of hash
                json[k] = v
            fs.writeFile pkg, JSON.stringify(json, null, 4), callback

    writePackageVersion: (version, callback) ->
        @writeToPackageJson version: version, callback

    commitVersion: (version, callback) ->
        @cmd "git", ["add", "package.json"], =>
            @cmd "git", ["commit", "-m", "Version #{version}"], callback

    push: (branch, callback) ->
        @cmd "git", ["push", "--tags", "origin", branch], callback

    publish: (callback) ->
        @cmd "npm", ["publish"], callback

    release: (callback) ->
        @version (v) =>
            @writePackageVersion v, =>
                @commitVersion v, =>
                    @push "master"

module.exports = new Tools

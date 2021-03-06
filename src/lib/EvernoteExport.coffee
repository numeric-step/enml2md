fs = require 'graceful-fs'
path = require 'path'
mkdirp = require 'mkdirp'
Parser = require('./Parser').Parser

class EvernoteExport

  constructor: (filename) ->
    this.filename = filename
    this.count = 0
    this.done = false

  export: (exportDirectory, cbDone) ->
    enex = this
    mkdirp this._resourceDirectory(exportDirectory), (err) ->
      # make export directory (foo) and resource directory (foo/resources) at the same time
      throw err if err
      eachProc = (note) ->
        enex._exportNote exportDirectory, note
        enex._exportAttachments exportDirectory, note
      doneProc = () ->
        enex.done = true
        cbDone() if cbDone
      enex.each eachProc, doneProc

  _uniqueFilename: (filename) ->
    buildFilename = () ->
      filename + if i == 0 then "" else " (" + i + ")"
    i = 0
    i += 1 while fs.existsSync buildFilename()
    buildFilename()

  _exportNote: (exportDirectory, note) ->
    notePath = this._uniqueFilename(exportDirectory + '/' + note.filename())
    fs.writeFileSync notePath, note.toString()
    fs.utimesSync notePath, note.updated, note.created

  _exportAttachments: (exportDirectory, note) ->
    for hash, attachment of note.attachments
      resourceDirectory = this._resourceDirectory exportDirectory
      filePath = resourceDirectory + '/' + attachment.exportFileName()
      dirPath = path.dirname filePath
      unless fs.existsSync(dirPath)
        fs.mkdirSync dirPath
      unless fs.existsSync(filePath)
        fs.writeFileSync filePath, attachment.data

  _resourceDirectory: (exportDirectory) ->
    exportDirectory + '/resources'
  
  each: (cbEach, cbEnd) ->
    parser = new Parser this, cbEach, cbEnd
    parser.parse this.filename

exports.EvernoteExport = EvernoteExport

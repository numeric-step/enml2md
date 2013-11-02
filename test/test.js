var enml2md = require('../lib/enml2md.js'),
  should = require('should'),
  fs = require('fs')

describe('EvernoteExport', function(){
  describe('#notesCount()', function(){
    it('should return `1` for `fiture1.enex`.', function(done){
      testNotesCount('./test/fixtures/fixture1.enex', 1, done);
    });
    it('should return `2` for `fiture2.enex`.', function(done){
      testNotesCount('./test/fixtures/fixture2.enex', 2, done);
    });
  });
});

function testNotesCount(enml_filename, expect, done) {
  var enml = new enml2md.EvernoteExport(enml_filename);
  var count_async = enml.notesCount();
  count_async.on('done', function(count) {
    count.should.equal(expect);
    done();
  });
}

describe('Note', function(){
  var note_enml = fs.readFileSync('./test/fixtures/note.enex');
  var note = enml2md.Note.parse(note_enml);
  it('.parseNote() should return a note object.', function(){
    note.should.be.an.instanceof(enml2md.Note);
  });
  it('#title should return a title.', function(){
    note.title.should.equal('a single note fixture');
  });
  it('#created should return a date.', function(){
    var date = new Date(2013, 11, 2, 10, 7, 9); // 20131102T100709Z
    note.created.should.be.an.instanceof(Date);
    note.created.should.eql(date);
  });
  it('#updated should return a date.', function(){
    var date = new Date(2013, 11, 2, 10, 7, 13); // 20131102T100713Z
    note.updated.should.be.an.instanceof(Date);
    note.updated.should.eql(date);
  });
});
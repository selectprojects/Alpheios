Notes on LSJ

The src directory contains source files containing actual LSJ content, either
original or derivative.

The xml_prod_files directory contains files used in the production processes.

src:
lsj.xml.gz -
  The original LSJ in one file as obtained from the Perseus project.
  The Greek strings are encoded in betacode.
lsj.tar.gz -
  lsj.xml broken up into individual files by letter.  Greek in betacode.
ulsj-main.xml -
ulsj-alpha.xml ... ulsj-omega.xml
  LSJ broken apart by letter, since the unitary file was too large for some
  tools, and with the Greek strings converted to Unicode Greek characters.
  ulsj-main.xml contains the prefatory material and includes the files for
  individual letters, hence could be used for loading the entire dictionary,
  if desired.  Note: A few character entities (like &mdash;) were
  expanded in the conversion process.
  DTD locations have been changed to point to local files.  These may need
  to be changed for DTD-aware processing, depending on environment.
  The original http-based locations are in the original lsj.xml (but the
  TEI URL is broken).  The individual letter files have had sufficient header
  and wrapper elements added to make them work as standalone files.
  They would need modification to be loaded with the main file.
ulsj-meanings.xml
  List of lemmas, ids, and short definitions extracted from the full LSJ.
ulsj-index.xml
  Index file used by ulsj-lookup.xquery to map lemmas to LSJ ids.

xml_prod_files:
lsjbeta2uni.xsl:
  Transform to change from betacode to Unicode encoding of Greek.
lsj-meanings.query:
  Query to extract short definitions from lsj-*.xml files.
ulsj-meanings.query:
  Query to extract short definitions from ulsj-*.xml files.
  Same as lsj-meainings.query with lemmas converted to Unicode.
meaning2text.xsl
  Transform to produce lookup text file from lsj-meanings.xml.
umeaning2text.xsl
  Transform to produce lookup text file from ulsj-meanings.xml.
  Same as meaning2text.xsl without betacode conversion.
umeaning2index.xsl
  Transform to produce index file (ulsj-index.xml) from ulsj-meanings.xml.
ulsj-lookup.xquery
  Query running under eXist REST interface that takes Greek lemma and
  returns the corresponding LSJ entry formatted in HTML
tei.xsl, langfilter.xsl
  Transforms to convert TEI XML to HTML

Production processes:
Conversion from betacode to Unicode
- Apply lsjbeta2uni.xsl to each individual lsj-<letter>.xml file, saving
  the output to ulsj-<letter>.xml.
- Apply lsjbeta2uni.xsl to lsj-main.xsl and save to ulsj-main.xsl.  The
  includes of individual letter files will have to be temporarily commented
  out in the input file and restored in the output file.

Creation of short definitions file
- Execute ulsj-meanings.xquery, saving the output to ulsj-meanings.xml.
- Apply umeanings2txt to ulsj-meanings.xml, saving the output to
  lsj-meanings-raw.dat.
- Sort lsj-meanings-raw.dat, saving the output to lsj-meanings.dat.
- Edit lsj-meanings.dat and remove the first few (about 8) lines that
  contain miscellaneous malformed entries (missing lemma and lemma starting
  with "<" or "[").

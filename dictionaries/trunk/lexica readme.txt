Notes on lexica
===============

Files are organized under <root>/lexica/<lang>/<code>
(.../dictionaries/<lang>/<code> in SVN).
Language codes:
  grc = Ancient Greek
  lat = Latin
  ara = Arabic
The combinations of <lang>/<code> in use:
  grc/lsj = A Greek-English Lexicon (LSJ)
  grc/ml = An Intermediate Greek-English Lexicon (Middle Liddell)
  grc/aut = A Homeric Dictionary (Autenrieth)
  lat/ls = A Latin Dictionary (Lewis & Short, 1897)
  ara/sal = An Advanced Learner's Arabic-English Dictionary (Salmoné, 1889)

The src directories contains source files containing actual lexicon content,
either original or derivative.

The xml_prod_files directories contains files used in the production processes.

.../<lang> and .../<lang>/xml_prod_files contain files that are applicable to
all lexica of the given language.

General xml_prod_files:
-----------------------
<lang>-beta2uni.xsl:
  Transform to change from betacode to Unicode encoding of Greek.
ara-trans2uni.xsl:
  Change betacode and Buckwalter encodings to Unicode in Salmoné.
<lang>-addkeys.xsl
  Transform to add key values to short definitions file
    key1 = lemma with aggressive removal
      for grc, this is vowel length diacritics, diaeresis, and caps
      for lat, this is vowel length diacritics and caps
    key2 = '@' + lemma with less aggressive removal
      for grc and lat, this is vowel length diacritics only
lexi-meanings2data.xquery
  Query to transform short definitions file to client/server data files
  Parameters:
    e_docname = name of document to transform
    e_output = what to produce:
      ids = key to lexicon id mapping
      defs = key to short def mapping
      index = key to id in xml format

<code> xml_prod_files:
----------------------
<lang>-<code>-lex2meanings.query:
  Query to extract short definitions from <code> xml files.

lat/ls src:
--------
ls.xml.gz -
  The original LS in one file as obtained from the Perseus project.
  The Greek strings are encoded in betacode.
ls.tar.gz -
  ls.xml broken up into individual files by letter.  Greek in betacode.
uls-main.xml -
uls-A.xml ... uls-Z.xml
  LS broken apart by letter, since the unitary file was too large for some
  tools, and with the Greek strings converted to Unicode Greek characters.
  uls-main.xml contains the prefatory material and includes the files for
  individual letters, hence could be used for loading the entire dictionary,
  if desired.  Note: Some entities (like &mdash;) were expanded in the
  conversion process.
  DTD locations have been changed to point to local files.  These may need
  to be changed for DTD-aware processing, depending on environment.
  The original http-based locations are in the original ls.xml (but the
  TEI URL is broken).  The individual letter files have had sufficient header
  and wrapper elements added to make them work as standalone files.
  They would need modification to be loaded with the main file.

<repository/xml_ctrl_files/xquery:
----------------------------------
lexi-id2xml.xquery
lexi-id2html.xquery
lexi-lemma2xml.xquery
lexi-lemma2html.xquery
  Queries running under eXist REST interface that takes lexicon entry id or
  lemma and return the corresponding lexicon entry formatted in XML or
  HTML

<repository>/xml_ctrl_files_xslt:
---------------------------------
alpheios-lexi-tei.xsl
  Transform to convert TEI XML to HTML

Production processes:
=====================
Conversion from betacode to Unicode
- Apply <lang>-beta2uni.xsl to each individual lexicon xml file, saving
  the output to same file name with 'u' prepended.
  (For Arabic, ara-trans2uni.xsl)

Creation of short definitions files
- Execute <lang>-<code>-lex2meanings.xquery, saving the output to
  <lang>-<code>-meanings-1.xml.
- Transform using <lang>-addkeys.xsl, saving the output to
  <lang>-<code>-meanings.xml.
- Execute lexi-meanings2data.xquery with params
    docname=<lang>-<code>-meanings.xml
    output=index
  saving output to <lang>-<code>-index.xml
  (For Arabic, ara-sal-meanings2data.xquery)
- Execute lexi-meanings2data.xquery with params
    docname=<lang>-<code>-meanings.xml
    output=ids
  saving output to <lang>-<code>-ids.raw
- Execute lexi-meanings2data.xquery with params
    docname=<lang>-<code>-meanings.xml
    output=defs
  saving output to <lang>-<code>-defs.raw
  Note:  This step is not necessary if the short definitions for a
  given language are available through another means, for example
  William Whitaker's Words for Latin.
- Edit <lang>-<code>-ids.raw and <lang>-<code>-defs.raw, removing xml
  declaration and leading spaces.
  Convert any entities to text (e.g. &lt;, &gt;).
- Sort and dedup: sort | uniq < <lang>-<code>-ids.raw > <lang>-<code>-ids.dat
  Same with defs, saving to <lang>-<code>-defs.dat.

Procedure for loading eXist data from SVN
=========================================
Lexicon data:
<repository>/dictionaries/<lang>/<code>/trunk/src/u*.xml
 -> /db/lexica/<lang>/<code>/

Indexes
<repository>/dictionaries/<lang>/<code>/trunk/src/<lang>-<code>-index.xml
 -> /db/indexes

XQueries
<repository>/xml_ctl_files/xquery/trunk/lexi-id2html.xml
<repository>/xml_ctl_files/xquery/trunk/lexi-id2xml.xml
<repository>/xml_ctl_files/xquery/trunk/lexi-lemma2html.xml
<repository>/xml_ctl_files/xquery/trunk/lexi-lemma2xml.xml
 -> /db/xquery

Stylesheets
<repository>/xml_ctl_files/xslt/alpheios-lexi-tei.xsl
<repository>/xml_ctl_files/xslt/beta-uni-util.xsl
<repository>/xml_ctl_files/xslt/beta2uni.xsl
<repository>/xml_ctl_files/xslt/uni2beta.xsl
<repository>/basic-reader/trunk/skin/alpheios-beta2unicode.xsl
<repository>/basic-reader/trunk/skin/alpheios-uni2betacode.xsl
 -> /db/xslt

Client-side setup
<repository>/dictionaries/<lang>/<code>/trunk/src/<lang>-<code>-defs.dat
<repository>/dictionaries/<lang>/<code>/trunk/src/<lang>-<code>-ids.dat
  -> <greek>/chrome/alpheios-greek.jar/content where <lang>=grc
  -> <latin>/chrome/alpheios-latin.jar/content where <lang>=lat

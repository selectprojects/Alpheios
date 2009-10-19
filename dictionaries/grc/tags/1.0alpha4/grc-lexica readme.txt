Notes on Greek lexica
=====================

Files are organized under <root>/lexica/grc/<code>
(.../dictionaries/grc/<code> in SVN).
There are currently three codes in use:
  lsj = A Greek-English Lexicon (LSJ)
  ml = An Intermediate Greek-English Lexicon (Middle Liddell)
  aut = A Homeric Dictionary (Autenrieth)

The src directories contains source files containing actual lexicon content,
either original or derivative.

The xml_prod_files directories contains files used in the production processes.

.../grc and .../grc/xml_prod_files contain files that are applicable to
all Greek lexica.

General xml_prod_files:
-----------------------
grc-beta2uni.xsl:
  Transform to change from betacode to Unicode encoding of Greek.
grc-addkeys.xsl
  Transform to add key values to short definitions file
    key1 = lemma with vowel length diacritics, diaeresis, and caps removed
    key2 = '@' + lemma with only vowel length diacritics removed
grc-meanings2data.xquery
  Query to transform short definitions file to client/server data files
  Parameters:
    docname = name of document to transform
    output = what to produce:
      ids = key to lexicon id mapping
      defs = key to short def mapping
      index = key to id in xml format

<code> xml_prod_files:
----------------------
grc-<code>-lex2meanings.query:
  Query to extract short definitions from <code> xml files.
grc-aut-addids.xquery (Autenrieth only)
  Query to add id attribute to entries in xml.

lsj src:
--------
lsj.xml.gz -
  The original LSJ in one file as obtained from the Perseus project.
  The Greek strings are encoded in betacode.
lsj.tar.gz -
  lsj.xml broken up into individual files by letter.  Greek in betacode.
ulsj-main.xml -
ulsj-01-alpha.xml ... ulsj-027-omega.xml
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

ml src:
-------
ml.xml
  The original xml from the Perseus project with Greek strings in betacode.
uml.xml
  With strings converted to Unicode Greek characters.
mlcorrections.txt
  Notes on corrections made to original.

aut src:
--------
A_Homeric_Dictionary_for_Schools_and_Col.pdf
  Scanned version of the 1891 printed edition.
autenrieth.original.xml
  The original xml from the Perseus project with Greek strings in betacode.
autenrieth.xml
  With numerous corrections of long vowel marks, etc.
uautenrieth.xml
  With strings converted to Unicode Greek characters.
autcorrections.txt
  Notes on corrections made to original.

<repository/xml_ctrl_files/xquery:
----------------------------------
lexi-id2xml.xquery
lexi-id2html.xquery
lexi-lemma2xml.xquery
lexi-lemma2html.xquery
  Queries running under eXist REST interface that takes lexicon entry id or
  Greek lemma and return the corresponding lexicon entry formatted in XML or
  HTML

<repository>/xml_ctrl_files_xslt:
---------------------------------
alpheios-lexi-tei.xsl
  Transform to convert TEI XML to HTML

Production processes:
=====================
Conversion from betacode to Unicode
- Apply grc-beta2uni.xsl to each individual lexicon xml file, saving
  the output to same file name with 'u' prepended.

Creation of short definitions files
- Execute grc-<code>-lex2meanings.xquery, saving the output to
  grc-<code>-meanings-1.xml.
- Transform using grc-addkeys.xsl, saving the output to
  grc-<code>-meanings.xml.
- Execute grc-<code>-meanings2data.xquery with
    docname=grc-<code>-meanings.xml
  execute with
    output=ids
  saving output to grc-<code>-ids.raw
  execute with
    output=defs
  saving output to grc-<code>-defs.raw
  execute with
    output=index
  saving output to grc-<code>-index.xml
- Edit grc-<code>-ids.raw and grc-<code>-defs.raw, removing xml
  declaration and leading spaces.
  Convert any entities to text (e.g. &lt;, &gt;).
- Sort and dedup: sort | uniq < grc-<code>-ids.raw > grc-<code>-ids.dat
  Same with defs, saving to grc-<code>-defs.dat.

Procedure for loading eXist data from SVN
=========================================
Lexicon data:
<repository>/dictionaries/greek/aut/trunk/src/uautenrieth.xml
 -> /db/lexica/grc/aut/
<repository>/dictionaries/greek/LSJ/trunk/src/ulsj-*.xml
 -> /db/lexica/grc/lsj/
<repository>/dictionaries/greek/ml/trunk/src/uml.xml
 -> /db/lexica/grc/ml/

Indexes
<repository>/dictionaries/greek/aut/trunk/src/grc-aut-index.xml
<repository>/dictionaries/greek/LSJ/trunk/src/grc-lsj-index.xml
<repository>/dictionaries/greek/ml/trunk/src/grc-ml-index.xml
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
<repository>/dictionaries/greek/aut/trunk/src/grc-aut-defs.dat
<repository>/dictionaries/greek/aut/trunk/src/grc-aut-ids.dat
<repository>/dictionaries/greek/lsj/trunk/src/grc-lsj-defs.dat
<repository>/dictionaries/greek/lsj/trunk/src/grc-lsj-ids.dat
<repository>/dictionaries/greek/ml/trunk/src/grc-ml-defs.dat
<repository>/dictionaries/greek/ml/trunk/src/grc-ml-ids.dat
  -> <greek>/chromes/alpheios-greek.jar/content

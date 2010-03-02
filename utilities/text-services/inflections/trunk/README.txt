Process for pre-preparing texts for inflection frequency analysis:

Prerequisities:
Source XML in TEI format
Treebank for Source XML loaded in eXist repository

1. Identify source TEI xml
2. Extract individual words from the TEI xml by transforming with tei-extract-words.xsl (supply parameter e_uni2beta=1 to transform unicode to beta)
3. start morphology service 
4. run get-morph.pl aginst output of step 2
5. transform output of step 5 to unicode using morph-beta-uni.xsl
6. load output of step 5 into eXist repository in morphology collection
   using naming convention: <docid>.morph.all.xml
7. load source TEI xml into eXist repository in alpheios_enhanced collection
   using naming convention: <docid>.<lang>.xml)
8. run morph-filter.xquery againt document loaded in step 6 to disambiguate morphology service output using the treebanked data
9. load output of step 5 into eXist repository in morphology collection
   using naming convention: <docid>.morph.xml

TODO:

1. use correct CTS urns for documents and reference pointers
2. add alternative to step 9 to use morphology service output without treebank disambiguation
3. when using treebank, modify morph-filter.xquery to figure out which inflection to use if multiple match


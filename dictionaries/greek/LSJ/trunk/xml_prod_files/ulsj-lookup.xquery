import module namespace request="http://exist-db.org/xquery/request";  
import module namespace transform="http://exist-db.org/xquery/transform";  
declare option exist:serialize "method=xhtml media-type=text/html";

(: get lemma from request :)
let $lemma := request:get-parameter("l", ())

(:
  find entry in index
  Note: Lemma attribute in index corresponds to entryFree/@key in LSJ.
  Key attribute in index is LSJ lemma with vowel length and diaeresis
  stripped.  We use the first entry for which either key or lemma
  matches the requested lemma.
 :)
let $index-entry :=
  doc("/db/indexes/ulsj-index.xml")
      //entry[@key = $lemma][1]
let $index-entry :=
  if (not(exists($index-entry)))
  then
    doc("/db/indexes/ulsj-index.xml")
        //entry[@lemma = $lemma][1]
  else $index-entry

(: get dictionary entry :)
let $dict-entry :=
  collection("/db/lsj")//entryFree[@id = string($index-entry/@id)]

return
  (: if no lemma, give error msg :)
  if (not(exists($lemma)))
  then
    element error { "No lemma specified" }
  (: if no entry, give error msg :)
  else if (not(exists($dict-entry)))
  then
    element error { "Lemma ", $lemma, " not found" }
  else
    (: transform TEI entry to HTML :)
    transform:transform(
      <TEI.2><text><body>{ $dict-entry }</body></text></TEI.2>,
      doc("/db/xslt/tei.xsl"),
      ())

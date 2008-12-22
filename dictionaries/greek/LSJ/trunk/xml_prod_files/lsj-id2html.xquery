import module namespace request="http://exist-db.org/xquery/request";
import module namespace transform="http://exist-db.org/xquery/transform";  
declare option exist:serialize "method=xhtml media-type=text/html";

(: get ids from request and find entries :)
let $ids := request:get-parameter("n", ())
let $entries := collection("/db/lsj")//entryFree[@id = $ids]

return
  if (count($ids) = 0)
  then
    element div { "No id specified" }
  else if (count($entries) = 0)
  then
    element div { "No entries found" }
  else

  (: wrap output in <div> element :)
  element div
  {
    for $entry in $entries
    return
      element div {
        attribute lemma-id { $entry/@id },

        (: transform TEI entry to HTML :)
        transform:transform(
          <TEI.2><text><body>{ $entry }</body></text></TEI.2>,
          doc("/db/xslt/tei.xsl"),
          ())
      }
  }
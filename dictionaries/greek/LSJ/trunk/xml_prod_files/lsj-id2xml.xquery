import module namespace request="http://exist-db.org/xquery/request";

(: get ids from request and find entries :)
let $ids := request:get-parameter("n", ())
let $entries := collection("/db/lsj")//entryFree[@id = $ids]

return
  if (count($ids) = 0)
  then
    element output { "No id specified" }
  else if (count($entries) = 0)
  then
    element output { "No entries found" }
  else

  element output
  {
    for $entry in $entries
    return
      element entry
      {
        attribute lemma-id { $entry/@id },
        $entry
      }
  }
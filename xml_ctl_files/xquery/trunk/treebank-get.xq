(:
  Copyright 2009 Cantus Foundation
  http://alpheios.net

  This file is part of Alpheios.

  Alpheios is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Alpheios is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 :)

(:
  Query to retrieve data from treebank

  Form of request is:
    .../tb-get.xq?f=<file>&n=<id>
  where
    f is the base file name (without path or extensions)
    n is either sentence id or word id (<sentence#>-<word#>)
 :)

import module namespace request="http://exist-db.org/xquery/request";
declare option exist:serialize "method=xml media-type=text/xml";

let $base := request:get-parameter("f", ())
let $id := request:get-parameter("n", ())
let $docname := concat("/db/repository/treebank/", $base, ".tb.xml")

return
  if (not($base))
  then
    element error { "Treebank not specified" }
  else if (not($id))
  then
    element error { "Sentence and/or word not specified" }
  else if (not(doc-available($docname)))
  then
    element error { concat("Treebank for ", $base, " not available") }
  else
    let $sentence-id :=
      if (contains($id, "-")) then substring-before($id, "-") else $id
    let $word-id :=
      if (contains($id, "-")) then substring-after($id, "-") else ()
    let $doc := doc($docname)
    let $sentence := $doc//sentence[@id = $sentence-id]
    return
      if ($sentence)
      then
        if ($word-id)
        then
          let $word := $sentence/word[@id = $word-id]
          return
          if ($word)
          then
            $word
          else
            element error
            {
              concat("Word number ", $id, " not found")
            }
        else
          $sentence
      else
        element error
        {
          concat("Sentence number ", $sentence-id, " not found")
        }
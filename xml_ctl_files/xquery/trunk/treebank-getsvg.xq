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
  Query to retrieve SVG from treebank

  Form of request is:
    .../tb-getsvg.xq?f=<file>&s=<sentence#>
  where
    f is the base file name (without path or extensions)
    s is the sentence id
 :)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace tbs="http://alpheios.net/namespaces/treebank-svg"
              at "treebank-svg.xquery";
declare option exist:serialize "method=xml media-type=text/xml";

let $base := request:get-parameter("f", ())
let $id := request:get-parameter("s", ())
let $docname := concat("/db/repository/treebank/", $base, ".tb.xml")

return
  if (not($base))
  then
    element error { "Treebank not specified" }
  else if (not($id))
  then
    element error { "Sentence not specified" }
  else if (not(doc-available($docname)))
  then
    element error { concat("Treebank for ", $base, " not available") }
  else
    (: get SVG, using "#" as root label :)
    tbs:get-svg($docname, $id, false())
(:
  Copyright 2008-2009 Cantus Foundation
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
  XQuery to retrieve lexicon entries by id

  Form of request is:
    .../lexi-lemma2html.xq?lg=<>&lx=<>&n=<>[&n=<>...]
  where
    lg is the language of the lemma
    lx is the code for the lexicon to use
    n is the if an entry to retrieve.  Multiple ids may be specified.

  Output is returned as XML.

  Possible error messages, as plain text, are:
    "No id specified" if no n parameters were supplied
    "No entries found" if none of the ids was valid
  Other than the message if no ids were valid, invalid ids are
  silently ignored.

  There is no guarantee that the output will be returned in the same
  order as the id in the request.
 :)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace transform="http://exist-db.org/xquery/transform";  
declare option exist:serialize "method=xml media-type=text/xml";

declare variable $f_defaultLexicon :=
(
  <lx lg="grc">lsj</lx>
);

(: get lexicon files :)
let $langCode := request:get-parameter("lg", "grc")
let $lexiCode :=
  if (request:get-parameter("lx", ()))
  then
    request:get-parameter("lx", ())
  else
    $f_defaultLexicon[@lg = $langCode]
let $lexicon := collection(concat("/db/lexica/",
                                  $langCode,
                                  "/",
                                  $lexiCode))

(: get ids from request and find entries :)
let $ids := distinct-values(request:get-parameter("n", ()))
let $entries := $lexicon//entryFree[@id = $ids]
let $entries :=
  if (count($entries) = 0)
  then
    $lexicon//entry[@id = $ids]
  else
    $entries

return
  if (count($ids) = 0)
  then
    <alph:error xmlns:alph="http://alpheios.net/namespaces/tei">{
      "No id specified"
     }</alph:error>
  else if (count($entries) = 0)
  then
    <alph:error xmlns:alph="http://alpheios.net/namespaces/tei">{
      "No entries found"
    }</alph:error>
  else

  (: wrap output in <alph:output> element :)
  <alph:output xmlns:alph="http://alpheios.net/namespaces/tei">{
    for $entry in $entries
    return
      element alph:entry
      {
        attribute lemma-id { $entry/@id },
        $entry
      }
  }</alph:output>

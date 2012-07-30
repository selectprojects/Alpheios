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
  XQuery to retrieve lexicon entries

  Form of request is:
    .../lexi-get.xq?lg=<>&lx=<>&out=<>&[n|l]=<>[&[n|l]=<>...]
  where
    lg is the language of the lemma (default "grc")
    lx is the code for the lexicon to use (default is language-dependent)
    out is the output format - xml or html (default "html")
    n is the id of an entry to retrieve
    l is the lemma of an entry to retrieve

  Multiple ids may be specified by either id or lemma or a mixture of both

  Output is returned as either XML or HTML
  Entries are returned in the order of the n and l parameters.

  Possible error messages, as plain text, are:
    "No entries specified" if no n or l parameters were supplied
    "No entries found" if none of the ids or lemmas was valid
  Other than these messages, invalid values are silently ignored.
  Duplicate lemma and id parameters are removed, but no attempt is made
  to identify lemma and id pairs which may specify the same entry.
 :)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace response="http://exist-db.org/xquery/response";
import module namespace transform="http://exist-db.org/xquery/transform";  
import module namespace util="http://exist-db.org/xquery/util";
import module namespace lxget="http://alpheios.net/namespaces/lexi-get"
              at "lexi-get.xquery";

declare variable $f_defaultLexicon :=
(
  <lx lg="grc">lsj</lx>,    (: default lexicon for ancient Greek is LSJ :)
  <lx lg="lat">ls</lx>,     (: default lexicon for Latin is Lewis & Short :)
  <lx lg="la">ls</lx>,
  <lx lg="ara">sal</lx>,    (: default lexicon for Arabic is Salmoné :)
  <lx lg="ar">sal</lx>
);

(: parse parameters :)
let $params :=
  for $param in tokenize(request:get-query-string(), '&amp;')
  let $parts := tokenize($param, '=')
  return
  element param
  {
    attribute name { request:unescape-uri($parts[1], "UTF-8") },
    element value { request:unescape-uri($parts[2], "UTF-8") }
  }

(: get lexicon files :)
let $langCode :=
  if ($params[@name = "lg"])
  then
    $params[@name = "lg"][1]/value/text()
  else
    "grc"
let $lexiCode :=
  if ($params[@name = "lx"])
  then
    $params[@name = "lx"][1]/value/text()
  else
    $f_defaultLexicon[@lg = $langCode]
let $lexicon := collection(concat("/db/lexica/",
                                  $langCode,
                                  "/",
                                  $lexiCode))
let $index := doc(concat("/db/indexes/",
                         $langCode,
                         "-",
                         $lexiCode,
                         "-index.xml"))

(: get output method and set serialization options :)
let $out :=
  if ($params[@name = "out"])
  then
    lower-case($params[@name = "out"][1]/value/text())
  else
    "html"
let $dummy := util:declare-option("exist:serialize",
                                  if ($out eq "html")
                                  then
                                    "method=xhtml media-type=text/html"
                                  else
                                    "method=xml media-type=text/xml")

(: get ids and lemmas, removing duplicates :)
let $entryParams :=
  for $param at $i in $params[@name = ("n", "l")]
  where not(subsequence($params[@name = ("n", "l")], 1, $i - 1) = $param)
  return $param

(: find lexicon entries :)
let $entries :=
  for $param in $entryParams
  return
  (: if specified by id :)
  if ($param/@name = "n")
  then
    lxget:get-entry-by-id($lexicon, $param/value)
  (: if specified by lemma :)
  else
    lxget:get-entry-by-lemma($lexicon, $index, $param/value, $langCode)

(: create xml output :)
let $xml-output :=
  (: if no entry parameters supplied :)
  if (count($entryParams) = 0)
  then
    <alph:error xmlns:alph="http://alpheios.net/namespaces/tei">{
      "No entries specified"
     }</alph:error>

  (: if no entries found :)
  else if (count($entries) = 0)
  then
    <alph:error xmlns:alph="http://alpheios.net/namespaces/tei">{
      "No entries found"
    }</alph:error>
  else

  (: wrap output in <alph:output> element :)
  <alph:output xmlns:alph="http://alpheios.net/namespaces/tei">{
    lxget:get-source($lexicon),
    for $entry in $entries
    let $bodyKey := root($entry)//body/div1[1]/@n
    let $rootElem := $entry/parent::*[@type='root']
    let $rootAtt :=  
        if($rootElem)
        then attribute root { if ($rootElem/@n) then $rootElem/@n  else xs:string($rootElem/head) }
        else ()        
        
    return
      element alph:entry
      {
        attribute lemma-id { $entry/@id },
        attribute body-key { $bodyKey },
        $rootAtt,               
        $entry
      }
  }</alph:output>
let $h := response:set-header("Access-Control-Allow-Origin","*")

return
  (: if HTML output :)
  if ($out = "html")
  then
    (: transform TEI to HTML :)
    transform:transform($xml-output, doc("/db/xslt/alpheios-lexi-tei.xsl"), ())
  (: if XML output :)
  else
    $xml-output
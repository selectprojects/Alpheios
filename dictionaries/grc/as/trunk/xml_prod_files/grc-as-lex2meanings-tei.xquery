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
  XQuery to extract short definitions from Abbott-Smith Greek lexicon

  Output is in form
  <entrylist id="grc-ml">
    <entry id="$id">
      <lemma>$lemma</lemma>
      <meaning>$definition</meaning>
    </entry>
    ...
  </entrylist.
 :)

declare namespace tei = "http://www.crosswire.org/2008/TEIOSIS/namespace";

(: file global variables :)
declare variable $f_lang := "grc";
declare variable $f_code := "as";

declare variable $includeStrongsNumbers := fn:true();

(: wrap everything in <entrylist> :)
element entrylist
{
attribute id { concat($f_lang, "-", $f_code) },

let $docName := concat("/MarkLogic/workspace/alpheios/dictionaries/",
                       $f_lang, "/",
                       $f_code, "/trunk/src/abbott-smith.tei.xml")

(: invalid entries :)
let $invalids :=
(
)

(: corrections :)
let $corrections :=
  <corrections>
(:
    <entry>
      <lemma></lemma>
      <meaning></meaning>
    </entry>
 :)
  </corrections>
let $correctedLemmas := $corrections/entry/lemma/text()

(: for each entry in file :)
for $entry at $i in doc($docName)//tei:entry
let $keyParts := fn:tokenize($entry/@n, "\|")
let $lemma := $keyParts[1]
let $strongsNumber := $keyParts[2]
let $sense := $entry/tei:sense
let $meaning :=
  if ($lemma = $correctedLemmas)
  then
    (: if correction exists, use it :)
    $corrections/entry[./lemma = $lemma]/meaning/text()
  else
    for $s in $sense/fn:normalize-space(fn:string())
    return
      if (fn:ends-with($s, ";"))
      then fn:substring($s, 1, fn:string-length($s) - 1)
      else $s

(: filter out entries to be ignored :)
let $ignore :=
  for $start in
  (
    "No entry", "no entry", "' ",       "(",
    "&lt;",     "See ",     "÷G",       "?",
    "From the neuter of",   "Definition not found",
    "No definition found",  "no definition found"
  )
  return fn:starts-with($lemma, $start)

where fn:not($ignore = fn:true())

(: put out entry :)
return
  element entry
  {
    attribute id { $i },
    element lemma { $lemma },
    if (count($meaning) > 0)
    then
      element meaning
      {
        fn:concat(
          fn:string-join($meaning, "; "),
          if ($includeStrongsNumbers and fn:exists($strongsNumber))
          then fn:concat(" [", $strongsNumber, "]")
          else ""
        )
      }
    else ()
  },

(: additions :)
()
}

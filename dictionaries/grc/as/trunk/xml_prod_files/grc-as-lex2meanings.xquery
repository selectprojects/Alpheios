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

(: file global variables :)
declare variable $f_lang := "grc";
declare variable $f_code := "as";

(: wrap everything in <entrylist> :)
element entrylist
{
attribute id { concat($f_lang, "-", $f_code) },

let $docName := concat("/MarkLogic/workspace/alpheios/dictionaries/",
                       $f_lang, "/",
                       $f_code, "/trunk/src/uabbott-smith.xml")

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
for $entry in fn:subsequence(doc($docName)//entry, 2)
let $lemma := data($entry/@key)
let $sense := $entry/sense
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

(: put out entry :)
return
  element entry
  {
    $entry/@id,
    element lemma { $lemma },
    if (count($meaning) > 0)
    then
      element meaning { string-join($meaning, "; ") }
    else ()
  },

(: additions :)
()
}

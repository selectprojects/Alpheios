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
  XQuery to extract short definitions from Lewis & Short Latin lexicon

  Output is in form
  <entrylist id="lat=\-ls">
    <entry id="$id">
      <lemma>$lemma</lemma>
      <meaning>$definition</meaning>
    </entry>
    ...
  </entrylist.

 :)

(: file global variables :)
declare variable $f_lang := "lat";
declare variable $f_code := "ls";

(: wrap everything in <entrylist> :)
element entrylist
{
attribute id { concat($f_lang, "-", $f_code) },

(: full list :)
let $letters :=
(
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
  "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
  "U", "V", "X", "Y", "Z"
)
(: test list :)
(: let $letters := ( "A" ) :)

let $docPrefix := concat("/sgml/lexica/",
                         $f_lang, "/",
                         $f_code, "/uls-")
let $docPostfix := ".xml"

(: invalid entries :)
let $invalids :=
(
)

(: corrections :)
let $corrections :=
  <corrections>
  </corrections>
let $correctedLemmas := $corrections/entry/lemma/text()

(: for each letter in alphabet, process that letter's entries :)
for $letter in $letters
let $entries := doc(concat($docPrefix, $letter, $docPostfix))//entryFree

(: for each entry in file :)
for $entry in $entries
let $lemma := data($entry/@key)
let $sense := $entry/sense[exists(./hi)][1]
let $meaning :=
  if ($lemma = $correctedLemmas)
  then
    (: if correction exists, use it :)
    $corrections/entry[./lemma = $lemma]/meaning/text()
  else
    (: get first two <hi> elements :)
    let $parts :=
      for $hi in $sense/hi
      return
        normalize-space($hi)
    let $first :=
      if ($parts[1] = $invalids) then 2 else 1
    let $meaning :=
      (: if separated by "or", use concatenation else use first :)
      if ($parts[$first + 1])
      then
        let $both := concat($parts[$first], " or ", $parts[$first + 1])
        return
          if (contains(normalize-space(data($sense)), $both))
          then
            $both
          else
            $parts[$first]
      else
        $parts[$first]
    return
      (: remove trailing comma, semicolon :)
      if (ends-with($meaning, ",") or ends-with($meaning, ";"))
      then
        substring($meaning, 1, string-length($meaning) - 1)
      else
        $meaning

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
  }

(: additions :)
}

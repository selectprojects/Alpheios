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
  XQuery to extract short definitions from Middle Liddell Greek lexicon

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
declare variable $f_code := "ml";

(: wrap everything in <entrylist> :)
element entrylist
{
attribute id { concat($f_lang, "-", $f_code) },

let $docName := concat("/sgml/lexica/",
                       $f_lang, "/",
                       $f_code, "/uml.xml")

(: invalid entries :)
let $invalids :=
(
)

(: corrections :)
let $corrections :=
  <corrections>
    <entry>
      <lemma>ἄν2</lemma>
      <meaning>if haply</meaning>
    </entry>
    <entry>
      <lemma>ἕ</lemma>
      <meaning>him, her</meaning>
    </entry>
    <entry>
      <lemma>ἄλλος1</lemma>
      <meaning>another, one besides</meaning>
    </entry>
(:
    <entry>
      <lemma></lemma>
      <meaning></meaning>
    </entry>
 :)
  </corrections>
let $correctedLemmas := $corrections/entry/lemma/text()

(: for each entry in file :)
for $entry in doc($docName)//entry
let $lemma := data($entry/@key)
let $sense := $entry/sense[exists(./trans/tr)][1]
let $meaning :=
  if ($lemma = $correctedLemmas)
  then
    (: if correction exists, use it :)
    $corrections/entry[./lemma = $lemma]/meaning/text()
  else
    (: get first two <tr> elements :)
    let $parts :=
      for $tr in $sense/trans/tr
      return
        normalize-space($tr)
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
    let $meaning :=
      (: if no meaning found yet, use first sense :)
      if (string-length($meaning) = 0)
      then
        normalize-space(data($entry/sense[1]))
      else
        $meaning
    let $meaning :=
      (: if no meaning found yet, use first etymology :)
      if (string-length($meaning) = 0)
      then
        normalize-space(data($entry/etym[1]))
      else
        $meaning
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
  },

(: additions :)
()
}

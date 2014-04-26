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
  XQuery to extract short definitions from Dodson Greek lexicon

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
declare variable $f_code := "dod";

(: wrap everything in <entrylist> :)
element entrylist
{
attribute id { concat($f_lang, "-", $f_code) },

let $docName := concat("/MarkLogic/workspace/alpheios/dictionaries/",
                       $f_lang, "/",
                       $f_code, "/trunk/src/udodson.xml")

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
for $entry in fn:doc($docName)//entry
let $keyParts := fn:tokenize($entry/@n, " \| ")
let $sense := $entry/form/def[@role eq "full"]/fn:string()
let $sense :=
  if (fn:substring($sense, fn:string-length($sense)) eq ".")
  then fn:substring($sense, 1, fn:string-length($sense) - 1)
  else $sense

(: put out entry :)
return
  element entry
  {
    attribute id { fn:number($keyParts[2]) },
    element lemma { $keyParts[1] },
    element meaning { $sense }
  },

(: additions :)
()
}

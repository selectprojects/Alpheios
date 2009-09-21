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
  XQuery to retrieve lexicon entries by lemma

  Form of request is:
    .../lexi-lemma2html.xq?lg=<>&lx=<>&l=<>[&l=<>...]
  where
    lg is the language of the lemma
    lx is the code for the lexicon to use
    l is the lemma to retrieve.  Multiple lemmas may be specified.

  Output is returned as XML.

  Possible error messages, as plain text, are:
    "No lemma specified" if no l parameters were supplied
    "Lemma <l> not found" for each lemma not found in the lexicon

  Output will be returned in the same order as the lemmas in the request.
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
let $index := doc(concat("/db/indexes/",
                         $langCode,
                         "-",
                         $lexiCode,
                         "-index.xml"))

(: get lemmas from request :)
let $lemmas := distinct-values(request:get-parameter("l", ()))

return
  if (count($lemmas) = 0)
  then
    <alph:error xmlns:alph="http://alpheios.net/namespaces/tei">{
      "No lemma specified"
     }</alph:error>
  else

  (: wrap output in <alph:output> element :)
  <alph:output xmlns:alph="http://alpheios.net/namespaces/tei">{

  for $lemma in $lemmas
    (: see if we can find it directly :)
    let $dict-entry := $lexicon//entryFree[@key eq $lemma]
    let $dict-entry :=
      if (exists($dict-entry))
      then
        $dict-entry
      else
        $lexicon//entry[@key eq $lemma]
    let $dict-entry :=
      if (exists($dict-entry))
      then
        $dict-entry
      else
        (:
          transform lemma to unicode
          Note: In order to ensure precomposed unicode,
          we first convert to betacode (which will leave
          betacode input unchanged), then convert to unicode
         :)
        let $uni-lemma :=
          if ($langCode eq "grc")
          then
            let $beta-lemma :=
              transform:transform(
                <dummy/>,
                doc("/db/xslt/alpheios-uni2betacode.xsl"),
                <parameters>
                  <param name="input" value="{ $lemma }"/>
                </parameters>)
            return
              transform:transform(
                <dummy/>,
                doc("/db/xslt/alpheios-beta2unicode.xsl"),
                <parameters>
                  <param name="input" value="{ $beta-lemma }"/>
                </parameters>)
          else
            $lemma
        (: see if unicode lemma can be found directly :)
        let $dict-entry :=
          if ($uni-lemma ne $lemma)
          then
            let $temp := $lexicon//entryFree[@key eq $uni-lemma]
            return
              if (exists($temp))
              then
                $temp
              else
                $lexicon//entry[@key eq $uni-lemma]
          else ()
        return
          if (exists($dict-entry))
          then
            $dict-entry
          else
            (:
              find entry in index
              Note: Lemma attribute in index corresponds to
              entryFree/@key or entry/@key in lexicon.
              Key attribute in index is lemma with vowel length
              and diaeresis stripped and capitalization removed.
             :)
            let $index-entry := $index//entry[@key eq $uni-lemma]

            (: get dictionary entry :)
            let $temp := $lexicon//entryFree[@id eq string($index-entry/@id)]
            return
              if (exists($temp))
              then
                $temp
              else
                $lexicon//entry[@id eq string($index-entry/@id)]

    return
      if (exists($dict-entry))
      then
        element alph:entry
        {
          attribute lemma-key { $lemma },
          $dict-entry
        }
      else
        element alph:error
        {
          ("Lemma ", $lemma, " not found")
        }
  }</alph:output>

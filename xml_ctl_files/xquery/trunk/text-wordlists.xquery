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

import module namespace almt="http://alpheios.net/namespaces/alignment-match"
              at "alignment-match.xquery";

(: extract wordlists for testing and verification :)

let $root := "/sgml/textproc/1999.01.0135/od1"
let $align-name := concat($root, ".align.xml")
let $align-doc := doc($align-name)
let $l1-lang := data($align-doc//language[@lnum = "L1"]/@xml:lang)
let $l2-lang := data($align-doc//language[@lnum = "L2"]/@xml:lang)

(: get words from original text :)
let $l1-text-name := concat($root, ".pre.", $l1-lang, ".xml")
let $l1-text-words := doc($l1-text-name)//wd/text()

(: get words from aligned text :)
let $l1-align-words :=
  for $word in $align-doc//*:wds[@lnum = "L1"]/*:w/*:text/text()
  where not(matches($word, "^[“”—&quot;‘’,.:;·'?!\[\](){}-]+$"))
  return $word
let $l2-align-words :=
  for $word in $align-doc//*:wds[@lnum = "L2"]/*:w/*:text/text()
  where not(matches($word, "^[“”—&quot;‘’,.:;·'?!\[\](){}-]+$"))
  return $word

(: get words from treebank :)
let $tb-name := concat($root, ".tb.xml")
let $tb-words :=
  for $word in doc(concat($root, ".tb.xml"))//word
  where not(matches($word/@form, "^[“”—&quot;‘’,.:;·'?!\[\](){}-]+$"))
  return $word/@form

(: get words from translation :)
let $l2-text-name := concat($root, ".pre.", $l2-lang, ".xml")
let $l2-text-words := doc($l2-text-name)//wd/text()

return
(
  "&#x000A;Original Language (", $l1-lang, ")",
  count($l1-text-words),
  count($l1-align-words),
  count($tb-words),

  "&#x000A;Text/Alignment&#x000A;",
  almt:match($l1-text-words, $l1-align-words, true()),
  "&#x000A;Text/Treebank&#x000A;",
  almt:match($l1-text-words, $tb-words, true()),

  "&#x000A;&#x000A;Translation (", $l2-lang, ")",
  count($l2-text-words),
  count($l2-align-words),

  "&#x000A;Text/Alignment&#x000A;",
  almt:match($l2-text-words, $l2-align-words, true())
)
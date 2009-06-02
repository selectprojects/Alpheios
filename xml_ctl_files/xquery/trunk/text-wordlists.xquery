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

(: extract wordlists for testing and verification :)

(: get words from original text :)
let $text-words := doc("/sgml/proj10/apollod-1.grc.xml")//wd/text()

(: get words from aligned text :)
let $align-doc := doc("/sgml/proj10/apollod-1.align.xml")
let $greek-lnum := $align-doc//language[@xml:lang="grc"]/@lnum
let $align-words :=
  for $word in $align-doc//wds[@lnum = $greek-lnum]/w/text/text()
  where not(matches($word, "^[“”—&quot;‘’,.:;·'?!\[\]-]+$"))
  return
    $word

(: get words from treebank :)
let $tb-words :=
  for $word in doc("/sgml/proj10/apollod-1.tb.xml")//word
  where not(matches($word/@form, "^[“”—&quot;‘’,.:;·'?!\[\]-]+$"))
  return
    $word/@form

return
(
  count($text-words),
  count($align-words),
  count($tb-words),

  for $word at $i in $text-words
  return
    concat("&#x000A;", $word, ' ', $align-words[$i], ' ', $tb-words[$i])
)
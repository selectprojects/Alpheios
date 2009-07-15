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

(:
  External parameters
    e_adocName        name of alignment document
    e_tdocName        name of treebank document
    e_tdocId          treebank document id
 :)
declare variable $e_adocName external;
declare variable $e_tdocName external;
declare variable $e_tdocId external;

let $adoc := doc($e_adocName)
let $tdoc := doc($e_tdocName)
let $lnum := "L1"
let $awords :=
  for $word in $adoc//*:wds[@lnum=$lnum]/*:w
  return lower-case(normalize-space($word/*:text))
let $twords :=
  for $word in $tdoc//*:sentence/*:word
  return lower-case(normalize-space($word/@form))

return
  element comment
  {
    almt:match(subsequence($awords, 1), subsequence($twords, 1), 1, 1),
    "&#x0a;",
    subsequence($awords, 1),
    "&#x0a;",
    subsequence($twords, 1)
  }
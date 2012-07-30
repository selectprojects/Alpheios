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
  Calculate comments to add to alignment text for correlation with
  treebank data

  The output is a single <comment> element which should be added
  under the root <aligned-text> element before any <sentence> elements.
 :)

(:
  External parameters
    adocName        name of alignment document
    tdocName        name of treebank document
    tdocId          treebank document id
 :)
declare variable $e_adocName external;
declare variable $e_tdocName external;
declare variable $e_tdocId external;

(:
  Recursive function to generate alignment/treebank matches

  Parameters:
    $a_aids      alignment sentence ids
    $a_tids      treebank sentence ids
    $a_alens     lengths of alignment sentences
    $a_tlens     lengths of treebank sentences
    $a_matches   text match elements
    $a_maoff     alignment offset in current match element
    $a_mtoff     treebank offset in current match element
    $a_aoff      offset in current alignment sentence
    $a_toff      offset in current treebank sentence

  Return value:
    sequence of <match> elements with attributes:
      as = alignment sentence id
      aw = alignment starting word number
      ts = treebank sentence id
      tw = treebank starting word number
      len = number of words in match
 :)

declare function local:match(
  $a_aids as xs:string*,
  $a_tids as xs:string*,
  $a_alens as xs:integer*,
  $a_tlens as xs:integer*,
  $a_matches as element(match)*,
  $a_maoff as xs:integer?,
  $a_mtoff as xs:integer?,
  $a_aoff as xs:integer?,
  $a_toff as xs:integer?) as element(match)*
{
  if ((count($a_aids) eq 0) or (count($a_tids) eq 0)) then () else

  let $len := min(($a_alens[1] - $a_aoff, $a_tlens[1] - $a_toff))
  let $mtype := $a_matches[1]/@type
  let $malen := $a_matches[1]/@l1 - $a_maoff
  return
  (
    (: if texts match :)
    if ($mtype = "1-to-1")
    then
      element match
      {
        attribute as { $a_aids[1] },
        attribute aw { $a_aoff + 1 },
        attribute ts { $a_tids[1] },
        attribute tw { $a_toff + 1 },
        attribute len { min(($len, $malen)) }
      }
    else if ($mtype = "mismatch")
    then
      element match
      {
        attribute as { $a_aids[1] },
        attribute aw { $a_aoff + 1 },
        attribute ts { $a_tids[1] },
        attribute tw { $a_toff + 1 },
        attribute lena { min(($a_alens[1] - $a_aoff, $malen)) },
        attribute lent { min(($a_tlens[1] - $a_toff,
                              $a_matches[1]/@l2 - $a_mtoff)) }
      }
    else (),

    (: see how much we've advanced :)
    let $ainc :=
      if ($mtype = "1-to-1")
      then
        min(($len, $malen))
      else if ($mtype = "mismatch")
      then
        min(($a_alens[1] - $a_aoff, $malen))
      else if ($a_matches[1]/@l1)
      then
        $a_matches[1]/@l1
      else 0
    let $tinc :=
      if ($mtype = "1-to-1")
      then
        min(($len, $malen))
      else if ($mtype = "mismatch")
      then
        min(($a_tlens[1] - $a_toff, $a_matches[1]/@l2 - $a_mtoff))
      else if ($a_matches[1]/@l2)
      then
        $a_matches[1]/@l2
      else 0
    let $morema :=
      if ($a_matches[1]/@l1)
      then
        ($a_maoff + $ainc) < $a_matches[1]/@l1
      else false()
    let $moremt :=
      if ($a_matches[1]/@l2)
      then
        ($a_mtoff + $tinc) < $a_matches[1]/@l2
      else false()
    return
    
      (: element match { ($ainc, $tinc, $morema, $moremt) } :)
      local:match(
        if ($a_aoff + $ainc >= $a_alens[1])
        then
          subsequence($a_aids, 2)
        else $a_aids,
        if ($a_toff + $tinc >= $a_tlens[1])
        then
          subsequence($a_tids, 2)
        else $a_tids,
        if ($a_aoff + $ainc >= $a_alens[1])
        then
          subsequence($a_alens, 2)
        else $a_alens,
        if ($a_toff + $tinc >= $a_tlens[1])
        then
          subsequence($a_tlens, 2)
        else $a_tlens,
        if ($morema or $moremt)
        then
          $a_matches
        else
          subsequence($a_matches, 2),
        if ($morema or $moremt)
        then
          xs:integer($a_maoff + $ainc)
        else 0,
        if ($morema or $moremt)
        then
          xs:integer($a_mtoff + $tinc)
        else 0,
        if ($a_aoff + $ainc < $a_alens[1])
        then
          xs:integer($a_aoff + $ainc)
        else 0,
        if ($a_toff + $tinc < $a_tlens[1])
        then
          xs:integer($a_toff + $tinc)
        else 0)
    )
};

let $adoc := doc($e_adocName)
let $tdoc := doc($e_tdocName)
let $sen1 := 1
let $lnum := "L1"
let $acounts :=
  for $wdset at $i in subsequence($adoc//*:sentence, $sen1)/*:wds[@lnum=$lnum]
  return count($wdset/*:w)
let $aids :=
  for $wdset at $i in subsequence($adoc//*:sentence, $sen1)/*:wds[@lnum=$lnum]
  return string($wdset/../@id)
let $tcounts :=
  for $sent at $i in subsequence($tdoc//*:sentence, $sen1)
  return count($sent/*:word)
let $tids :=
  for $sent at $i in subsequence($tdoc//*:sentence, $sen1)
  return string($sent/@id)

let $awords :=
  for $word in subsequence($adoc//*:sentence, $sen1)/*:wds[@lnum=$lnum]/*:w
  return lower-case(normalize-space($word/*:text))
let $twords :=
  for $word in subsequence($tdoc//*:sentence, $sen1)/*:word
  return lower-case(normalize-space($word/@form))
let $matches :=
  almt:match($awords, $twords, true())

return
  element comment
  {
    attribute class { "tbref" },
    attribute docid { $e_tdocId },
    local:match($aids, $tids, $acounts, $tcounts, $matches, 0, 0, 0, 0)
  }

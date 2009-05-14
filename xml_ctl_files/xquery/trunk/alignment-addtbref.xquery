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
  Calculate comments to add to alignment text for correlation with
  treebank data

  The output is a single <comment> element which should be added
  under the root <aligned-text> element before any <sentence> elements.
 :)

(:
  External parameters
    collection      collection in which documents are to be found
    text            name of text
    lang            language of text
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
    $a_acount    remaining count in current alignment sentence
    $a_tcount    remaining count in current treebank sentence

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
  $a_acount as xs:integer?,
  $a_tcount as xs:integer?) as element()*
{
  if ((count($a_aids) eq 0) or (count($a_tids) eq 0))
  then ()
  else
    let $astart := ($a_alens[1] - $a_acount) + 1
    let $tstart := ($a_tlens[1] - $a_tcount) + 1
    let $len := min(($a_acount, $a_tcount))
    return
    (
      element match
      {
        attribute as { $a_aids[1] },
        attribute aw { $astart },
        attribute ts { $a_tids[1] },
        attribute tw { $tstart },
        attribute len { $len }
      },
    if ($a_acount > $a_tcount)
    then
      local:match(
        $a_aids,
        subsequence($a_tids, 2),
        $a_alens,
        subsequence($a_tlens, 2),
        $a_acount - $len,
        $a_tlens[2])
    else if ($a_acount < $a_tcount)
    then
      local:match(
        subsequence($a_aids, 2),
        $a_tids,
        subsequence($a_alens, 2),
        $a_tlens,
        $a_alens[2],
        $a_tcount - $len)
    else
      local:match(
        subsequence($a_aids, 2),
        subsequence($a_tids, 2),
        subsequence($a_alens, 2),
        subsequence($a_tlens, 2),
        $a_alens[2],
        $a_tlens[2])
    )
};

let $adoc := doc($e_adocName)
let $tdoc := doc($e_tdocName)
let $lnum := $adoc//language[@xml:lang="grc"]/@lnum
let $acounts :=
  for $wdset at $i in $adoc//wds[@lnum=$lnum]
  return count($wdset/w)
let $aids :=
  for $wdset at $i in $adoc//wds[@lnum=$lnum]
  return $wdset/../@id
let $tcounts :=
  for $sent at $i in $tdoc//sentence
  return count($sent/word)
let $tids :=
  for $sent at $i in $tdoc//sentence
  return $sent/@id

return
  element comment
  {
    attribute class { "tbref" },
    attribute docid { $e_tdocId },
    local:match($aids, $tids, $acounts, $tcounts, $acounts[1], $tcounts[1])
  }

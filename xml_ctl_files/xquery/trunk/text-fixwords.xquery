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
  Fix word elements in text
  
  Each <wd> in the text has attributes added from the related treebank and
  aligned text data.
 :)

(:
  External parameters:
    $e_basename        base of file names
    $e_lang            language of text
    $e_treebanked      whether treebank data exists for this text

  Static variables:
    $s_nontext         Regex matching non-textual characters
 :)
declare variable $e_basename external;
declare variable $e_lang external;
declare variable $e_treebanked external;

declare variable $s_nontext := "^[“”—&quot;‘’,.:;·'?!\[\]-]+$";

(:
  Process a set of nodes
  
  Parameters:
    $a_nodes           set of nodes to process
    $a_fixed-words     set of adjusted wd nodes

  Each <wd> in the original text has a unique id attribute.
  Each fixed <wd> is wrapped in a <wrap> element with the
  matching id.  The fixed <wd>'s do not have id attributes,
  since these are needed only for the purpose of efficiently
  matching original with fixed elements.
 :)
declare function local:process-nodes(
  $a_nodes as node()*,
  $a_fixed-words as element(wrap)*) as node()*
{
  (: for each node :)
  for $node in $a_nodes
  return
  typeswitch ($node)
    (: if wd, replace with corresponding fixed word :)
    case $word as element(wd)
    return
      $a_fixed-words[@id = $word/@id]/wd

    (:
      if element, copy and process all child nodes
      except TEI attributes
     :)
    case element()
    return
    element { local-name($node) }
    {
      local:process-nodes(
        $node/(node()|@*[not(local-name(.) = ("part", "TEIform"))]),
        $a_fixed-words)
    }

    (: otherwise, just copy it :)
    default
    return $node
};

(:
  Filenames are built from the base name by adding:
    $e_lang+".xml" for the original text
    ".align.xml" for the alignment data
    ".tb.xml for" the treebank data
 :)

let $treebanked := (number($e_treebanked) > 0)
(: get words from original text :)
let $text-doc := doc(concat($e_basename, ".", $e_lang, ".xml"))
let $text-words := $text-doc//wd

(: get words from aligned text, ignoring non-text :)
let $align-doc := doc(concat($e_basename, ".align.xml"))
let $align-lnum := $align-doc//language[@xml:lang = $e_lang]/@lnum
let $align-words :=
  for $word in $align-doc//wds[@lnum=$align-lnum]/w
  where not(matches($word/text, $s_nontext))
  return
    $word

(: get words from treebank, ignoring non-text :)
let $tb-name :=
  if ($treebanked)
  then
    doc(concat($e_basename, ".tb.xml"))
  else ()
let $tb-words :=
  if ($treebanked)
  then
    for $word in $tb-name//word
    where not(matches($word/@form, $s_nontext))
    return
      $word
  else ()

(: create fixed words to replace original :)
let $fixed-words :=
  for $word at $i in $text-words
  let $align-word := $align-words[$i]
  let $tb-word := $tb-words[$i]
  return
  (: wrapper to hold id :)
  element wrap
  {
    $word/@id,

    (: new wd element :)
    element wd
    {
      (: include alignment data :)
      $align-word/refs/@*,

      (: if treebank exists and sentence is valid :)
      if ($treebanked and exists($tb-word/../@id))
      then
        (: build treebank ref from sentence# and word# :)
        attribute tbref
        {
          concat($tb-word/../@id, "-", $tb-word/@id)
        }
      else (),

      (: content is original word :)
      $word/text()
    }
  }

return
  (: create copy of original text with fixed words :)
  local:process-nodes($text-doc/node(), $fixed-words)
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
  Mark words in text with <wd> elements
 :)

declare variable $e_docname external;

declare variable $s_nontext := " “”—&quot;‘’,.:;·?!\[\]-";
declare variable $s_match-text := concat("^([^", $s_nontext, "]+).*");
declare variable $s_match-nontext := concat("^([", $s_nontext, "]+).*");

(:
  Process set of nodes
 :)
declare function local:process-nodes(
  $a_nodes as node()*,
  $a_in-text as xs:boolean,
  $a_id as xs:string) as node()*
{
  (: for each node :)
  for $node at $i in $a_nodes
  return
  typeswitch ($node)
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
        ($a_in-text or (local-name($node) eq "body")) and
          (local-name($node) ne "note"),
        concat($a_id, "-", $i))
    }

    (: if text in body, process it else just copy it :)
    case $t as text()
    return
    if ($a_in-text)
    then
      local:process-text(normalize-space($t), concat($a_id, "-", $i), 1)
    else
      $node

    (: otherwise, just copy it :)
    default
    return $node
};

(:
  Process text string in body
 :)
declare function local:process-text(
  $a_text as xs:string,
  $a_id as xs:string,
  $a_i as xs:integer) as node()*
{
  (: if anything to process :)
  if (string-length($a_text) > 0)
  then
    (: see if it starts with text :)
    let $is-text := matches($a_text, $s_match-text)

    (: get initial text/non-text string :)
    let $t := replace($a_text,
                      if ($is-text) then $s_match-text else $s_match-nontext,
                      "$1")

    return
    (
      (: return wd element with text or non-text string :)
      if ($is-text)
      then
        element wd
        {
          (: assign unique id to word :)
          attribute id { concat($a_id, "-", $a_i) },
          $t
        }
        else
          text { $t },
      (: then recursively process rest of text :)
      local:process-text(substring-after($a_text, $t), $a_id, $a_i + 1)
    )
  else ()
};

let $doc := doc($e_docname)

return
  local:process-nodes($doc/node(), false(), "1")

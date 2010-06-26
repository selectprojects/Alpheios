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
import module namespace transform="http://exist-db.org/xquery/transform";

declare variable $e_docname external;
declare variable $e_lang external;
declare variable $e_encoding external;

(: sets of characters by language :)
(: non-text characters :)
declare variable $s_nontext :=
(
  element nontext
  {
    attribute lang { "grc" },
    " “”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\]{}\-"
  },
  element nontext
  {
    attribute lang { "ara" },
    " “”—&quot;‘’,.:;?!\[\]{}\-"
  },
  element nontext
  {
    attribute lang { "*" },
    " “”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\](){}\-"
  }
);
(: characters which signify word break and are part of word :)
declare variable $s_breaktext :=
(
  element breaktext
  {
    attribute lang { "grc" },
    "᾽"
  },
   element breaktext
  {
    attribute lang { "ara" },
    "᾽"
  },
  element breaktext
  {
    attribute lang { "*" },
    "᾽"
  }
);

(:
  Process set of nodes
 :)
declare function local:process-nodes(
  $a_nodes as node()*,
  $a_in-text as xs:boolean,
  $a_id as xs:string,
  $a_match-text as xs:string,
  $a_match-nontext as xs:string) as node()*
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
        not(local-name($node) = ("note", "head")),
        concat($a_id, "-", $i),
        $a_match-text,
        $a_match-nontext)
    }

    (: if text in body, process it else just copy it :)
    case $t as text()
    return
    if ($a_in-text)
    then
      local:process-text(normalize-space($t),
                         concat($a_id, "-", $i),
                         1,
                         $a_match-text,
                         $a_match-nontext)
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
  $a_i as xs:integer,
  $a_match-text as xs:string,
  $a_match-nontext as xs:string) as node()*
{
  (: if anything to process :)
  if (string-length($a_text) > 0)
  then
    (: see if it starts with text :)
    let $is-text := matches($a_text, $a_match-text)

    (: get initial text/non-text string :)
    let $t := replace($a_text,
                      if ($is-text) then $a_match-text else $a_match-nontext,
                      "$1")

    return
    (
      (: return wd element with text or non-text string :)      
      if ($is-text)
      then
        let $transformed := 
            if ($e_encoding = "beta") 
            then 
                let $xsl := doc('/db/xslt/alpheios-beta2unicode.xsl')
                let $params := <parameters><param name="e_in" value="{$t}"/></parameters>
                let $dummy := <dummy/>
                let $temp := transform:transform($dummy, $xsl, $params)
                return $temp
            else if ($e_encoding = "ara")
            then
                let $xsl := doc('/db/xslt/alpheios-buck2uni.xsl')
                let $params := 
                    <parameters><param name="e_in" value="{$t}"/><param name="e_depersify" value="1"/></parameters>
                let $dummy := <dummy/>
                let $temp := (:transform:transform($dummy, $xsl, $params):)$t
                return $temp
            else $t
        return element wd
            {
              (: assign unique id to word :)
              attribute id { concat($a_id, "-", $a_i) },
              if ($e_encoding = "beta") then attribute beta{$t} 
              else if ($e_encoding = "ara") then attribute ara{$t} 
              else (), 
              $transformed
            }
        else
          text { $t },
      (: then recursively process rest of text :)
      local:process-text(substring-after($a_text, $t),
                         $a_id,
                         $a_i + 1,
                         $a_match-text,
                         $a_match-nontext)
    )
  else ()
};

let $doc := doc($e_docname)
let $nontext :=
  if ($s_nontext[@lang eq $e_lang])
  then
    $s_nontext[@lang eq $e_lang]/text()
  else
    $s_nontext[@lang eq "*"]/text()
let $breaktext :=
  if ($s_breaktext[@lang eq $e_lang])
  then
    $s_breaktext[@lang eq $e_lang]/text()
  else
    $s_breaktext[@lang eq "*"]/text()
let $match-text :=
  concat("^([^", $nontext, $breaktext, "]+",
         if ($breaktext) then concat("[", $breaktext, "]?") else (),
         ").*")
let $match-nontext := concat("^([", $nontext, "]+).*")

return
  local:process-nodes($doc/node(), false(), "1", $match-text, $match-nontext)

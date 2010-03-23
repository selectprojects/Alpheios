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
              at "xmldb:exist://localhost:8080/exist/xmlrpc/db/xq/alignment-match.xquery";

import module namespace cts="http://alpheios.net/namespaces/cts"
              at "xmldb:exist://localhost:8080/exist/xmlrpc/db/xq/cts.xquery";


(:
  Fix word elements in text
  
  Each <wd> in the text has attributes added from the related treebank and
  aligned text data.
 :)

(:
  External parameters:
    $e_urn                target text file urn
    $e_source         input source file path
    $e_lang              language of text
    $e_alignEdition the edition id of the aligned translation

  Static variables:
    $s_nontext         Regex matching non-textual characters
 :)
declare variable $e_urn external;
declare variable $e_source external;
declare variable $e_lang external;
declare variable $e_alignEdition external;



declare variable $s_nontext := "^[“”—&quot;‘’,.:;&#x0387;&#x00B7;'?!\[\]()\-]+$";

(:
  Process a set of nodes
  
  Parameters:
    $a_nodes           set of nodes to process
    $a_fixedWords      set of adjusted wd nodes

  Return value:
    sequence of adjusted nodes

  Each <wd> in the original text has a unique id attribute.
  Each fixed <wd> is wrapped in a <wrap> element with the
  matching id.  The fixed <wd>'s do not have id attributes,
  since these are needed only for the purpose of efficiently
  matching original with fixed elements.
 :)
declare function local:process-nodes(
  $a_nodes as node()*,
  $a_fixedWords as element(wrap)*) as node()*
{
  (: for each node :)
  for $node in $a_nodes
  return
  typeswitch ($node)
    (: if wd, replace with corresponding fixed word :)
    case $word as element(wd)
    return
      $a_fixedWords[@id = $word/@id]/*:wd

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
        $a_fixedWords)
    }

    (: otherwise, just copy it :)
    default
    return $node
};

(:
  Fix a set of text words

  Parameters:
    $a_textWords      set of text words
    $a_dataWords      set of data words (either alignment or treebank)
    $a_matches        match info on sets of words
    $a_treebank       whether data is treebank or alignment

  Return value:
    sequence of text words with appropriate attributes added from data
 :)
declare function local:fix-words(
  $a_textWords as element(wrap)*,
  $a_dataWords as element(wd)*,
  $a_matches as element(match)*,
  $a_treebank as xs:boolean) as element(wrap)*
{
  (: nothing to do if no text words left :)
  if (count($a_textWords) eq 0) then () else

  (: if no matches left, copy text words :)
  if (count($a_matches) eq 0) then $a_textWords else

  (: create words for this match :)
  let $match := $a_matches[1]
  let $newWords :=
    (: if 1-to-1 match :)
    if ($match/@type eq "1-to-1")
    then
      for $i in (1 to $match/@l1)
      return
        local:fix-word($a_textWords[$i],
                       $a_dataWords[$i]/@n,
                       $a_dataWords[$i]/@nrefs,
                       $a_treebank)

    (: if mismatch :)
    else if ($match/@type eq "mismatch")
    then
      let $n :=
        string-join(
          for $j in (1 to $match/@l2)
          return $a_dataWords[$j]/@n,
          ' ')
      let $nrefs :=
        string-join(
          for $j in (1 to $match/@l2)
          return $a_dataWords[$j]/@nrefs,
          ' ')
      for $i in (1 to $a_matches[1]/@l1)
      return
        local:fix-word($a_textWords[$i], $n, $nrefs, $a_treebank)

    (: if skip :)
    else
      subsequence($a_textWords, 1, if ($match/@l1) then $match/@l1 else 0)

  return
  (
    $newWords,
    local:fix-words(
      subsequence($a_textWords, if ($match/@l1) then $match/@l1 + 1 else 1),
      subsequence($a_dataWords, if ($match/@l2) then $match/@l2 + 1 else 1),
      subsequence($a_matches, 2),
      $a_treebank)
  )
};

(:
  Fix a single text word

  Parameters:
    $a_textWord       text word to fix
    $a_dataWord       data word (either alignment or treebank)
    $a_treebank       whether data is treebank or alignment

  Return value:
    text word with appropriate attributes added from data
 :)
declare function local:fix-word(
  $a_textWord as element(wrap)?,
  $a_n as xs:string?,
  $a_nrefs as xs:string?,
  $a_treebank as xs:boolean) as element(wrap)?
{
  (: if no textword, nothing to do :)
  if (not($a_textWord)) then () else

  (: if no data, just copy textword :)
  if (not($a_n)) then $a_textWord else

  (: wrapper to hold id :)
  element wrap
  {
    (: preserve original word id :)
    $a_textWord/@id,

    (: new wd element :)
    element wd
    {
      (: preserve any existing attributes :)
      $a_textWord/wd/@*,

      (: if this is treebank data :)
      if ($a_treebank)
      then
        (: create tb ref attribute :)
        attribute tbrefs { $a_n }
      else
      (
        (: copy word id and alignment refs :)
        attribute n { $a_n },
        if (exists($a_nrefs)) then attribute nrefs {$a_nrefs } else ()
      ),

      (: content is original word :)
      $a_textWord/wd/text()
    }
  }
};

let $cts := cts:parseUrn($e_urn)
let $alignDoc := concat($cts/fileInfo/basePath, "alpheios-align-",$cts/fileInfo/alpheiosEditionId,".xml")
let $tbDoc := concat($cts/fileInfo/basePath, "alpheios-treebank-",$cts/fileInfo/alpheiosEditionId,".xml")

(: get words from original text :)
let $textDoc := doc($e_source)
return 
if (doc-available($alignDoc) or doc-available($tbDoc))
then
    let $textWords :=
        for $word in $textDoc//wd
        return
          element wrap
          {
            $word/@id,
            element wd { $word/text() }
          }

    (: get words from aligned text, ignoring non-text :)
    let $alignLnum := 
        if (doc-available($alignDoc)) 
        then doc($alignDoc)//*:language[@xml:lang = $e_lang]/@lnum 
        else ()
    let $alignWords :=
        if (doc-available($alignDoc)) 
        then
            for $word in doc($alignDoc)//*:wds[@lnum=$alignLnum]/*:w
            where not(matches($word/*:text, $s_nontext))
            return
            element wd
            {
                $word/@n,
                $word/*:refs/@nrefs,
                $word/*:text/text()
            }
       else ()
   
    (: get words from treebank, ignoring non-text :)
    let $tbWords :=
      if (doc-available($tbDoc))
      then
        for $word in doc($tbDoc)//word
        where not(matches($word/@form, $s_nontext))
        return
        element wd
        {
            (: if sentence is valid :)
            if (exists($word/../@id))
            then
            (: build name from sentence# and word# :)
                attribute n
                {
                  concat($word/../@id, "-", $word/@id)
                }
            else (),
              data($word/@form)
        }
      else ()

    (: create fixed words to replace original :)
    let $fix1 :=
      local:fix-words($textWords,
                      $alignWords,
                      almt:match(data($textWords/wd), data($alignWords), true()),
                      false())
    let $fix2 :=
      if (doc-available($tbDoc))
      then
        local:fix-words($fix1,
                        $tbWords,
                        almt:match(data($textWords/wd), data($tbWords), true()),
                        true())
      else $fix1

    return
        (: create copy of original text with fixed words :)
        local:process-nodes($textDoc/node(), $fix2)
        
else $textDoc

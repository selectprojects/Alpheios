(:
  Copyright 2009 Cantus Foundation
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
  Extract treebank sentence and convert it to SVG suitable for editing

  Output is returned as a tree in SVG format with nodes corresponding to words
  in the sentence and arcs corresponding to dependency relations between words.
  There is a synthetic root node, with all words not dependent on any other
  in the sentence as its immediate children.

  At each level, the immediate children of a node are those that correspond to
  words dependent on that node's word.

  Associated with each text node is a text label for the dependency relation
  between the node and its parent.

  Each text element corresponding to a word in the sentence has a class
  attribute whose value is the part of speech of the word as well as an
  attribute with the complete morphology in compact form.

  It is the responsibility of the caller to position the text and lines for
  display.
 :)

module namespace tbsed = "http://alpheios.net/namespaces/treebank-svg-edit";
import module namespace tbu="http://alpheios.net/namespaces/treebank-util"
              at "treebank-util.xquery";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace tbd = "http://alpheios.net/namespaces/treebank-desc";

(:
  Function to fix up words in a sentence

  Parameters:
    $a_words      words in sentence

  Return value:
    word set with extra words added for ellipses
 :)
declare function tbsed:fix-words(
  $a_words as element()*) as element()*
{
  for $word in $a_words
  return
    if (matches($word/@relation, "_ExD\d*_"))
    then
      let $rel1 := replace($word/@relation, "^(.*?)_ExD(\d*)_(.*)$", "$1")
      let $rel2 := replace($word/@relation, "^(.*?)_ExD(\d*)_(.*)$", "$3")
      let $num  := replace($word/@relation, "^(.*?)_ExD(\d*)_(.*)$", "$2")
      let $num  := if (string-length($num) eq 0) then "0" else $num
      return
      (
        (: point this word at synthetic node :)
        element word
        {
          $word/@id,
          $word/@hide,
          $word/@form,
          $word/@lemma,
          $word/@postag,
          attribute head { concat($word/@head, "-", $num) },
          attribute relation { $rel1 }
        },
        (: create synthetic node and fix it :)
        tbsed:fix-words(
          element word
          {
            attribute id { concat($word/@head, "-", $num) },
            attribute hide {},
            attribute form { concat("[", $num, "]") },
            attribute lemma {},
            attribute postag { "---------" },
            attribute head { $word/@head },
            attribute relation { $rel2 }
          }
        )
      )
    else
      $word
};

(:
  Function to process set of words

  Parameters:
    $a_tbd        treebank format description
    $a_sentence   sentence containing words
    $a_words      words to process
    $a_mapRelations whether to map relation names to more friendly form 

  Return value:
    SVG equivalent of words
 :)
declare function tbsed:word-set(
  $a_tbd as element(tbd:desc),
  $a_sentence as element(),
  $a_words as element()*,
  $a_mapRelations as xs:boolean) as element()*
{
  (: for each word :)
  for $word in $a_words
  (: get child words that depend on this :)
  let $children := $a_sentence/*:word[@head = $word/@id]
  return
  (: return group :)
  <g xmlns="http://www.w3.org/2000/svg">{
    attribute class { "tree-node" },
    attribute id { concat($a_sentence/@id, "-", $word/@id) },

    (: text element with form :)
    element text
    {
      attribute class { "node-label" },
      $word/@postag,
      $word/@lemma,
      $word/@relation,
      let $pos := tbu:postag-to-name($a_tbd, "pos", $word/@postag)
      return
      if (string-length($pos) > 0)
      then
        attribute pos { $pos }
      else (),
      text { $word/@form }
    },

    (: label for arc to node :)
    let $relation :=
      if (contains($word/@relation, "_") and $a_mapRelations)
      then
        substring-before($word/@relation, "_")
      else
        string($word/@relation)
    return
      if (string-length($relation) > 0)
      then
        element text
        {
          attribute class { "arc-label", "alpheios-ignore" },
          text
          {
            if ($a_mapRelations)
            then
              tbu:relation-to-display($a_tbd, $relation)
            else
              $relation
          }
        }
      else (),

    (: groups for children :)
    tbsed:word-set($a_tbd, $a_sentence, $children, $a_mapRelations)
  }</g>
};

(:
  Function to convert sentence to SVG

  Parameters:
    $a_tbd          treebank format description
    $a_sent         treebank sentence
    $a_mapRelations whether to map relation names to more friendly form 
    $a_attrs        attributes to add to <svg> element

  Return value:
    <svg> element containing SVG equivalent of sentence,
    else <svg><text>error message</text></svg>
 :)
declare function tbsed:get-svg(
  $a_tbd as element(tbd:desc),
  $a_sent as element()?,
  $a_mapRelations as xs:boolean,
  $a_attrs as attribute()*) as element()?
{
  (: get sentence and create synthetic root :)
  let $sentence :=
    if ($a_sent)
    then
      element sentence
      {
        $a_sent/@*,
        let $words := tbsed:fix-words($a_sent/*:word)
        return
        (: remove duplicate words :)
        for $word at $i in $words
        return
          if (every $w in $words[position() < $i] satisfies
              not(deep-equal($w, $word)))
          then
            $word
          else ()
      }
    else ()
  let $rootword :=
    element word
    {
      attribute id { "0" },
      attribute form { "#" }
    }

  return
  if ($sentence)
  then
  <svg xmlns="http://www.w3.org/2000/svg"
       xmlns:xlink="http://www.w3.org/1999/xlink"
  >{
    (: include additional attributes :)
    $a_attrs,

    (: tree structure :)
    element g
    {
      attribute class { "tree" },
      $sentence/@id,
      tbsed:word-set($a_tbd, $sentence, $rootword, $a_mapRelations)
    },
    
    (: text of sentence :)
    element g
    {
      attribute class { "text" },
      for $word in $sentence/*:word[not(@hide)]
      return
      (
        element text
        {
          attribute class { "text-word" },
          attribute tbref { concat($sentence/@id, "-", $word/@id) },
          (: form preceded by non-breaking space :)
          text { concat("&#x00A0;", $word/@form) }
        }
      )
    }
  }</svg>

  else ()
};
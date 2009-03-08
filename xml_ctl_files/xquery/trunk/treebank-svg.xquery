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
  Extract treebank sentence and convert it to SVG

  Output is returned as a tree in SVG format with nodes corresponding to words
  in the sentence and arcs corresponding to dependency relations between words.
  There is a synthetic root node, with all words not dependent on any other
  in the sentence as its immediate children.

  At each level, the immediate children of a node are those that correspond to
  words dependent on that node's word.

  Associated with each text node is a line to connect that node to its parent
  and a text label for that line containing the dependency relation between the
  two words.

  Each text element corresponding to a word in the sentence has a class
  attribute whose value is the part of speech of the word.

  It is the responsibility of the caller to position the text and lines for
  display.
 :)

module namespace tbs = "http://alpheios.net/namespaces/treebank-svg";
import module namespace tbu="http://alpheios.net/namespaces/treebank-util"
              at "treebank-util.xquery";

(:
  Function to process set of words

  Parameters:
    $a_sentence   sentence containing words
    $a_words      words to process

  Return value:
    SVG equivalent of words
 :)
declare function tbs:word-set(
  $a_sentence as element(),
  $a_words as element()*) as element()*
{
  (: for each word :)
  for $word in $a_words
  return
  (: return group :)
  element g
  {
    attribute class { "tree-node" },

    attribute id
    {
      concat($a_sentence/@id, "-", $word/@id)
    },

    (: box around text :)
    element rect
    {
      attribute fill { "none" },
      attribute stroke-width { "0" }
    },

    (: text element with form :)
    element text
    {
      attribute class { "node-label" },
      let $pos := tbu:postag-to-name("pos", $word/@postag)
      return
      if (string-length($pos) > 0)
      then
        attribute pos { $pos }
      else (),
      text { $word/@form }
    },

    (: label for arc to parent word :)
    element text
    {
      attribute class { "arc-label" },
      text
      {
        tbu:relation-to-display(
          if (contains($word/@relation, "_"))
          then
            substring-before($word/@relation, "_")
          else
            $word/@relation
        )
      }
    },

    (: arc to parent word :)
    element line{},

    (: process children (words that depend on this) :)
    tbs:word-set($a_sentence, $a_sentence/word[./@head = $word/@id])
  }
};

(:
  Function to convert sentence to SVG

  Parameters:
    $a_docname     name of treebank document
    $a_id          id of sentence
    $a_usespan     whether to use span as label for root node

  Return value:
    <svg> element containing SVG equivalent of sentence,
    else <svg><text> with error message
 :)
declare function tbs:get-svg(
  $a_docname as xs:string,
  $a_id as xs:string,
  $a_usespan as xs:boolean) as element()?
{
  let $doc := doc($a_docname)
  let $sentence := $doc//sentence[@id = $a_id]
  let $rootwords := $sentence/word[@head = "0"]

  return
  <svg xmlns="http://www.w3.org/2000/svg">
  {
    if ($sentence)
    then
    (
      element g
      {
        attribute class { "tree" },
        $sentence/@id,

        (: synthetic root :)
        element g
        {
          attribute class { "tree-node" },
          attribute id
          {
            concat($sentence/@id, "-0")
          },
          element rect
          {
            attribute fill { "none" },
            attribute stroke-width { "0" }
          },
          element text
          {
            attribute class { "node-label" },
            text
            {
              if ($a_usespan)
              then
                $sentence/@span
              else
                "#"
            }
          },
          tbs:word-set($sentence, $rootwords)
        }
      },
      element g
      {
        attribute class { "text" },
        for $word in $sentence/*:word
        return
        (
          element rect
          {
            attribute class { "text-word-bound" },
            attribute tbref { concat($sentence/@id, "-", $word/@id) },
            attribute fill { "none" },
            attribute stroke-width { "0" }
          },
          element text
          {
            attribute class { "text-word" },
            attribute tbref { concat($sentence/@id, "-", $word/@id) },
            (: form preceded by non-breaking space :)
            text { concat("&#x00A0;", $word/@form) }
          }
        )
      }
    )
    else
    element text
    {
      concat("Sentence number ", $a_id, " not found")
    }
  }
  </svg>
};
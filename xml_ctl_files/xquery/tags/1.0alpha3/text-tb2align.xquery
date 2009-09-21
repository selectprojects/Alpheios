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
  Create aligned text from treebank and translation
  
  The output has sentences for each sentence in the text, appropriate for
  use with the alignment editor, with no actual word alignment included.
 :)

(:
  External parameters:
    $e_basename        base of file names
    $e_l1              language of text/treebank
    $e_l2              language of translation
 :)
declare variable $e_basename external;
declare variable $e_l1 external;
declare variable $e_l2 external;

let $l1name := concat($e_basename, ".tb.xml")
let $l2name := concat($e_basename, ".", $e_l2, ".xml")
let $l1doc := doc($l1name)
let $l2doc := doc($l2name)
let $error :=
  if (count($l1doc//sentence) != count($l2doc//sentence))
  then
    error(QName("http://alpheios.net/error", "BadCount"))
  else ()
return
element aligned-text
{
  element language
  {
    attribute lnum { "L1" },
    attribute xml:lang { $e_l1 }
  },
  element language
  {
    attribute lnum { "L2" },
    attribute xml:lang { $e_l2 }
  },

  for $sent at $i in $l1doc//sentence
  return
  element sentence
  {
    $sent/@id,
    $sent/@document_id,

    (: L1 words from treebank :)
    (: if last word is not punctuation, add a period :)
    let $l1words :=
    (
      $sent/word,
      if (not(matches($sent/word[last()], "\p{P}")))
      then
        element word { attribute form { "." } }
      else ()
    )
    return
    element wds
    {
      attribute lnum { "L1" },
      for $word at $j in $l1words
      return
      element w
      {
        attribute n { concat($sent/@id, '-', $j) },
        element text { data($word/@form) }
      }
    },

    (: L2 words from translation :)
    (: put spaces around punctuation, then split on spaces to get words :)
    let $l2words := tokenize(
                      normalize-space(
                        replace($l2doc//sentence[$i],
                                "([.,;:!?])",
                                " $1 ")),
                      ' ')
    return
    element wds
    {
      attribute lnum { "L2" },
      for $word at $j in $l2words
      return
      element w
      {
        attribute n { concat($sent/@id, '-', $j) },
        element text { $word }
      }
    }
  }
}

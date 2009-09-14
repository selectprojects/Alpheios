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
  Transform aligned text to xml format

  Document is assumed to be of the form
  <data>
  text lines
  </data>

  Each set of 3 non-empty text lines in the file has:
    1 information on the sentence in the form
      # Sentence pair <$id> (1-1 alignment="<$align>")
    2 L1 words with indices in square brackets, e.g. "tell[1]"
    3 L2 words with alignment references to L1 words, e.g. "a)/ndra ({ 9 })"
      meaning the L2 word "a)/ndra" corresponds to the 9th L1 word 
 :)

(:
  External parameters:
    docname    name of input document
    L1         code for first language (typically en=English)
    L2         code for second language (e.g. la=latin or grc=ancient Greek)
 :)
declare variable $e_docname external;
declare variable $e_L1 external;
declare variable $e_L2 external;

declare variable $s_allpunct := "^[“”—&quot;‘’,.:;'? -]+$";

(: break document up into lines :)
let $doc := doc($e_docname)
let $lines := tokenize($doc/data, "&#x000A;")
let $first-lines := $lines[substring(., 1, 1) = '#']

return
element aligned-text
{
  (: for each set of 3 lines :)
  for $first at $sn in $first-lines
  let $i := index-of($lines, $first)
  let $line := $lines[$i]
  return
    (: break up sentence information and get id and alignment :)
    let $sentence := tokenize($line, '[ "]+')
    let $id := $sentence[4]
    let $align := $sentence[7]

    let $l1-line := replace($lines[$i + 1], "\[([0-9]+)\]", " $1 ")

    (: build list of L2 words :)
    let $gwords :=
      (: break line on "{(" and ")}" :)
      let $words := tokenize($lines[$i + 2], "(\(\{|\}\))")
      let $jmax := (count($words) idiv 2) * 2
      for $word at $j in $words
      let $nrefs :=
        string-join(
          for $ref in tokenize(normalize-space($words[$j + 1]), ' ')
          return
            concat($sn, '-', $ref),
          ' ')
      (: only use words that are not all punctuation :)
      where ($j mod 2 eq 1) and
            ($j < $jmax) and
            not(matches($word, $s_allpunct))
      return
      element w
      {
        attribute n { concat($sn, '-', ($j + 1) idiv 2) },
        if (string-length($nrefs) > 0)
        then
          (: put spaces at either end so we can search easily :)
          attribute nrefs { concat(' ', $nrefs, ' ') }
        else (),
        normalize-space($word)
      }

    (: build list of L1 words :)
    let $ewords :=
      (: break line on space and square brackets :)
      let $words := tokenize($l1-line, "[ ]+")
      let $jmax := (count($words) idiv 2) * 2
      for $word at $j in $words
      let $wn := concat($sn, '-', normalize-space($words[$j + 1]))
      (: search with spaces on either side to ensure exact match :)
      let $nsearch := concat(' ', $wn, ' ')
      (: only use words that are not all punctuation :)
      where ($j mod 2 eq 1) and
            ($j < $jmax) and
            not(matches($word, $s_allpunct))
      return
      element w
      {
        attribute n { $wn },
        (: this word aligns with any L2 word that refers to it :)
        let $nrefs := $gwords[contains(./@nrefs, $nsearch)]/@n
        return
          if (count($nrefs) > 0)
          then
            attribute nrefs
            {
              (: build list of everything this word aligns with :)
              string-join($nrefs, ' ')
            }
          else (),
        normalize-space($word)
      }

    return
    element sentence
    {
      attribute n { $sn },
      attribute id { $id },
      attribute one-to-one { $align },

      (: put out L1 words :)
      element wds
      {
        attribute lang { $e_L1 },
        $ewords
      },

      (: put out L2 words :)
      element wds
      {
        attribute lang { $e_L2 },
        for $word in $gwords
        return
        element w
        {
          attribute n { $word/@n },
          if (exists($word/@nrefs))
          then
            attribute nrefs { normalize-space($word/@nrefs) }
          else (),
          $word/text()
        }
      }
    }
}
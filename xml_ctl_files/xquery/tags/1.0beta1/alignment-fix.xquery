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
  Insert sentence milestones (as found in alignment data)
  into original text
 :)

(: import module namespace util="http://exist-db.org/xquery/util"; :)

(:
  External parameters
    collection      collection in which documents are to be found
    text            name of text
    lang            language of text
 :)
declare variable $e_collection external;
declare variable $e_text external;
declare variable $e_lang external;

declare function local:calc(
  $a_divs as element()*,
  $a_sents as element()*,
  $a_i as xs:integer) as element()*
{
  if (count($a_divs) > 0)
  then
    (: get stripped lines for div :)
    let $divlines :=
      for $line in $a_divs[1]//l
      return
        normalize-space(replace($line, "[“”—&quot;‘’,.:;?-]", " "))
    (: calculate lengths for this div's lines :)
    let $divlens := local:calc-lengths($divlines)
    let $divfixes :=
      local:calc-div(string-join($divlines, " "),
                     $divlens,
                     $a_sents,
                     1,
                     1)
    return
    (
      element div
      {
        attribute n { $a_i },
        $divfixes
      },
      
      (: recursive call with remainder of divs and unprocessed sentences :)
      local:calc(subsequence($a_divs, 2),
                 subsequence($a_sents, count($divfixes) + 1),
                 $a_i + 1)
    )
  else ()
};

(:
  Calculate lengths for a set of text lines
 :)
declare function local:calc-lengths($a_lines as xs:string*) as xs:integer*
{
  if (count($a_lines) > 0)
  then
  (
    string-length($a_lines[1]) + 1,
    local:calc-lengths(subsequence($a_lines, 2))
  )
  else ()
};

declare function local:calc-div(
  $a_text as xs:string,
  $a_lens as xs:integer*,
  $a_sents as element()*,
  $a_iline as xs:integer,
  $a_isent as xs:integer) as element()*
{
  if (($a_isent <= count($a_sents)) and ($a_iline <= count($a_lens)))
  then
    let $sent := $a_sents[$a_isent]/text()
    let $sentoff :=
      if (contains($a_text, $sent))
      then
        string-length(substring-before($a_text, $sent))
      else
        string-length($a_text)
    let $line := local:calc-line($a_lens, $sentoff, $a_iline, 0)
    return
    (
      $line,
      local:calc-div(substring($a_text, $line/@l + 1),
                     $a_lens,
                     $a_sents,
                     $line/@n,
                     $a_isent + 1)
    )
  else ()
};

declare function local:calc-line(
  $a_lens as xs:integer*,
  $a_sentoff as xs:integer,
  $a_iline as xs:integer,
  $a_lsofar as xs:integer) as element()
{
  if ($a_iline <= count($a_lens))
  then
    let $len := $a_lens[$a_iline]
    return
    if ($a_sentoff < $len)
    then
      element l
      {
        attribute n { $a_iline },
        attribute l { $a_lsofar },
        attribute o { $a_sentoff }
      }
    else
      local:calc-line($a_lens,
                      $a_sentoff - $len,
                      $a_iline + 1,
                      $a_lsofar + $len)
  else
    element out
    {
      attribute n { $a_iline },
      attribute l { $a_lsofar },
      attribute o { 0 }
    }
};

(: text and treebank documents :)
let $alignment-doc := doc(concat($e_collection, "/alignment/", $e_text, ".align.xml"))
let $text-doc := doc(concat($e_collection, "/texts/", $e_text, ".xml"))
let $last-sentence := ($alignment-doc//sentence)[last()]

let $asents :=
  for $sentence in subsequence($alignment-doc//sentence, 1, 10)
  let $text :=
    string-join(
      for $word in $sentence/wds[@lang=$e_lang]/w
      where not(matches($word, "^[“”—&quot;‘’,.:;'?-]+$"))
      return
        $word,
      " ")
  where string-length($text) > 0
  return
  element s
  {
    attribute n { $sentence/@id },
    $text
  }

  let $results :=
      local:calc($text-doc//div1[1], $asents, 1)

return
  $results

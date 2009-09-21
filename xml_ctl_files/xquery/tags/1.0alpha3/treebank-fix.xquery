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
  Insert sentence milestones (as found in treebank data)
  into original text
  This is appropriate for line-oriented texts with card milestones.
 :)

(: import module namespace util="http://exist-db.org/xquery/util"; :)

(:
  External parameters
    collection      collection in which documents are to be found
    text            name of text
 :)
declare variable $e_collection external;
declare variable $e_text external;

(:
  Find lines in card

  Parameters:
    a_elements   elements to check
    a_card       card number to find

  Return value:
    line elements following requested card milestone
    if it exists, else empty
 :)
declare function local:find-card(
  $a_elements as element()*,
  $a_card as xs:integer) as element()*
{
  if (count($a_elements) > 0)
  then
    let $f := $a_elements[1]
    return
    if ((local-name($f) eq "milestone") and
        ($f[1]/@unit = "card") and
        ($f[1]/@n = $a_card))
    then
      subsequence($a_elements, 2)[local-name() eq "l"]
    else
      local:find-card(subsequence($a_elements, 2), $a_card)
  else ()
};

(:
  Find line containing string

  Parameters:
    a_lines      lines to check
    a_text       text to find
    a_count      which occurrence of text to find
    a_index      current index

  Return value:
    <val> element with attributes
      i = index of line in line sequence containing occurrence
          or 0 if not found
      n = occurrence number of text in that line or 0 if not found
 :)
declare function local:find-line(
  $a_lines as element()*,
  $a_text as xs:string,
  $a_count as xs:integer,
  $a_index as xs:integer) as element()
{
  if (count($a_lines) > 0)
  then
    let $first-char := substring($a_text, 1, 1)
    let $patterns :=
      (: if starts with quote or semicolon, count combinations of quotes and/or semicolon :)
      if ($first-char = ("“", "”", ";")) 
      then
        ("[^;“‘’”]", "“‘’”", "&quot;''&quot;")
      (: if starts with period or colon count instances of character :)
      else if ($first-char = (":", "."))
      then
        (concat("[^", $first-char, "]"))
      (: otherwise, count word occurrences :)
      else
        ("[ \t\r\n.,:;&quot;“‘’”\-]")
    let $found :=
      let $t1 := tokenize($a_lines[1], $patterns[1])
      let $t2 :=
        if (count($patterns) >= 3)
        then
          for $token in $t1
            return translate($token, $patterns[2], $patterns[3])
        else
          $t1
      let $text :=
        if (count($patterns) >= 3)
        then
          translate($a_text, $patterns[2], $patterns[3])
        else
          $a_text
      return
        count(index-of($t2, $text))
    return
      if ($found >= $a_count)
      then
        <val n="{ $a_count }" i="{ $a_index }">{ $patterns[1] }</val>
      else
        local:find-line(subsequence($a_lines, 2),
                        $a_text,
                        $a_count - $found,
                        $a_index + 1)
  else
    <val n="0" i="0"/>
};

(:
  Insert milestone in line

  Parameters:
    $a_line        line to find fix
    $a_text        text to insert milestone at
    $a_val         return value from find-line()
    $a_id          id of sentence
    $a_span        span of sentence
    $a_before      whether to put milestone before or after text

  Return value:
    line with milestone inserted
    number of characters preceding text in line
 :)
declare function local:insert-milestone(
  $a_line as element()?,
  $a_text as xs:string,
  $a_val as element(),
  $a_id as xs:string,
  $a_span as xs:string,
  $a_before as xs:boolean) as element()
{
  let $text-loc :=
    local:find-text(data($a_line), $a_text, $a_val) +
    (if ($a_before) then 0 else string-length($a_text))

  return
    element l
    {
      if (exists($a_line/@n)) then attribute n { $a_line/@n } else (),
      if (exists($a_line/milestone)) then $a_line/milestone else (),
      substring(data($a_line), 1, $text-loc),
      element milestone
      {
        attribute n { $a_id },
        attribute unit { "sentence" },
        if (string-length($a_span) > 0)
        then
          attribute span { $a_span }
        else ()
      },
      substring(data($a_line), $text-loc)
    }
};

(:
  Find text in line

  Parameters:
    $a_line        line to find text in
    $a_text        text to find
    $a_val         return value from find-line()

  Return value:
    number of characters preceding text in line

  For now, we just find n'th occurrence of string in line.
  We really should respect original tokenization and count
  word matches.
 :)
declare function local:find-text(
  $a_line as xs:string,
  $a_text as xs:string,
  $a_val as element()) as xs:integer
{
  local:find-text-r($a_line, $a_text, $a_val/@n)
};

(: recursive function to do work for find-text() :)
declare function local:find-text-r(
  $a_line as xs:string,
  $a_text as xs:string,
  $a_count as xs:integer) as xs:integer
{
  (: if we're still looking and the line contains the text :)
  if (($a_count > 0) and contains($a_line, $a_text))
  then
    (: offset is length before text plus offset in remainder of line :)
    string-length(substring-before($a_line, $a_text)) +
    local:find-text-r(substring-after($a_line, $a_text), $a_text, $a_count - 1)
  else
    0
};

(: text and treebank documents :)
let $treebank-doc := doc(concat($e_collection, "/treebank/", $e_text, ".tb.xml"))
let $text-doc := doc(concat($e_collection, "/texts/", $e_text, ".xml"))
let $last-sentence := ($treebank-doc//sentence)[last()]

(: for each sentence in treebank :)
for $sentence in $treebank-doc//sentence
  (: parse out book and card numbers, span start and end :)
  let $subdoc := data($sentence/@subdoc)
  let $span := data($sentence/@span)
  let $book := substring-before(substring-after($subdoc, "book="), ":")
  let $card := substring-after($subdoc, "card=")
  let $temp := substring-before($span, ":")
  let $span-start := tokenize($temp, "[0-9]")[1]
  let $span-start-count :=
    xs:integer(substring($temp, string-length($span-start) + 1)) + 1
  let $temp := substring-after($span, ":")
  let $span-end := tokenize($temp, "[0-9]")[1]
  let $span-end-count :=
    xs:integer(substring($temp, string-length($span-end) + 1)) + 1

  (: find lines following milestone :)
  let $lines :=
    local:find-card($text-doc//div1[@type="Book" and @n=$book]/*,
                    xs:integer($card))

  (: find line in card :)
  let $val1 := local:find-line($lines, $span-start, $span-start-count, 1)
  let $line1 := $lines[xs:integer($val1/@i)]
  let $val2 :=
    if (deep-equal($sentence, $last-sentence))
    then
      local:find-line($lines, $span-end, $span-end-count, 1)
    else ()
  let $line2 :=
    if (deep-equal($sentence, $last-sentence))
    then
      $lines[xs:integer($val2/@i)]
    else ()

  (: insert sentence milestone(s) in line :)
  let $temp :=
    local:insert-milestone($line1,
                           $span-start,
                           $val1,
                           $sentence/@id,
                           $sentence/@span,
                           true())
  let $newline1 :=
    if ($line1 = $line2)
    then
      local:insert-milestone($temp, $span-end, $val2, "0", "", false())
    else
      $temp

  (: insert final milestone if necessary :)
  let $newline2 :=
    if (exists($line2) and ($line1 != $line2))
    then
      local:insert-milestone($line2, $span-end, $val2, "0", "", false())
    else ()

return
(: insert milestone before line starting sentence :)
(
  update replace $line1 with $newline1,
  if ($newline2)
  then
    update replace $line2 with $newline2
  else ()
)

(: list fixed line(s) :)
(: ( $newline1, $newline2 ) :)

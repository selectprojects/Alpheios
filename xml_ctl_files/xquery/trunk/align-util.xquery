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
  Utilities for alignment data
 :)

module namespace alut="http://alpheios.net/namespaces/align-util";
declare namespace svg="http://www.w3.org/2000/svg";
declare namespace xlink="http://www.w3.org/1999/xlink";

(:
  Function to convert sentence in alignment XML to displayable SVG

  Parameters:
    $a_sent        alignment sentence
    $a_attrs       attributes to add to <svg> element

  Return value:
    SVG representation of sentence
 :)
declare function alut:xml-to-svg(
  $a_sent as element()?,
  $a_attrs as attribute()*) as element()?
{
  (: if no sentence, return nothing :)
  if ($a_sent)
  then

  <svg:svg version="1.1"
           baseProfile="full"
           xmlns="http://www.w3.org/2000/svg"
           xmlns:xlink="http://www.w3.org/1999/xlink"
           xmlns:ev="http://www.w3.org/2001/xml-events"
  >{
    (: include additional attributes :)
    $a_attrs,

    for $lang in ("L1", "L2")
    let $otherLang := if ($lang eq "L1") then "L2" else "L1"
    let $words := $a_sent/*:wds[@*:lnum eq $lang]/*:w
    let $otherWords := $a_sent/*:wds[@*:lnum eq $otherLang]/*:w
    return
    element g
    {
      attribute class { "sentence", $lang },
      attribute xml:lang { $a_sent/../*:language[@*:lnum = $lang]/@xml:lang },

      for $word in $words
      let $refs := tokenize($word/*:refs/@*:nrefs, ' ')
      return
      element g
      {
        attribute class { "word" },
        attribute id { concat($lang, ":", $word/@*:n) },
        if ($word/*:mark)
        then
          attribute xlink:title { $word/*:mark/text() }
        else (),

        (: highlighting rectangle :)
        element rect { attribute class { "headwd-bg" } }, 

        (: the word itself :)
        element text
        {
          attribute class
          {
            "headwd",
            (: if this is L2 word, don't show popup :)
            if ($lang eq "L2") then "alpheios-ignore" else (),
            (: if this has no aligned words, flag it :)
            if (count($refs) eq 0) then "free" else ()
          },
          $word/*:text/text()
        },

        (: aligned words :)
        element g
        {
          attribute class
          {
            "alignment",
            (: if this is L2 word, don't show popup :)
            if ($otherLang eq "L2") then "alpheios-ignore" else ()
          },
          for $n in $refs
          return
          element text
          {
            attribute idref { concat($otherLang, ":", $n) },
            $otherWords[@*:n eq $n]/*:text/text()
          }
        }
      }
    }
  }</svg:svg>

  else ()
};

(:
  Function to convert sentence in SVG to alignment XML

  Parameters:
    $a_sent        alignment sentence in SVG

  Return value:
    representation of sentence in alignment XML
 :)
declare function alut:svg-to-xml(
  $a_sent as element()?) as element()?
{
  if ($a_sent)
  then
  element sentence
  {
    for $lang in ("L1", "L2")
(: following has problems in eXist 1.2.5: :)
(:  let $svgSent := $a_sent/*:g[tokenize(@*:class, ' ') = $lang] :)
(: so instead do: :)
    let $svgSent :=
      for $g in $a_sent/*:g
      return if (tokenize($g/@*:class, ' ') = $lang) then $g else ()
    let $words := $svgSent/*:g/*:g
    return
    element wds
    {
      attribute lnum { $lang },

      for $word in $words
      return
      element w
      {
        (: id of this word :)
        attribute n { substring-after($word/@*:id, ':') },

        (: text of this word :)
        element text { $word/*:text/text() },

        (: copy mark, if any :)
        if ($word/@xlink:title)
        then
          element mark { data($word/@xlink:title) }
        else (),

        (: references to aligned words :)
        let $refs :=
          for $aligned-word in $word/*:g/*:text
          return
            substring-after($aligned-word/@*:idref, ':')
        return
          if (count($refs) > 0)
          then
            element refs
            {
              attribute nrefs { string-join($refs, ' ') }
            }
          else ()
      }
    }
  }

  else ()
};
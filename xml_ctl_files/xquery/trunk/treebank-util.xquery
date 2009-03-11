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
  Utilities related to treebank format
 :)

module namespace tbu = "http://alpheios.net/namespaces/treebank-util";

(:
  Table of morphology categories and values

  <category> = morphology category
    @id = name of category (pos [part of speech], person, number, tense,
          mood, voice, gender, case, degree)
    @n = position of category in treebank postag attribute
    <entry> = entry in category
      <short> = single-letter value in postag
      <long> = equivalent human-readable name
      <lex> = equivalent name in lexicon schema, if different from <long>
 :)
declare variable $tbu:s_tables :=
(
  (: part of speech :)
  <category id="pos" n="1"
            xmlns="http://alpheios.net/namespaces/treebank-util">
    <entry>
      <short>n</short>
      <long>noun</long>
    </entry>
    <entry>
      <short>v</short>
      <long>verb</long>
    </entry>
    <entry>
      <short>t</short>
      <long>participle</long>
    </entry>
    <entry>
      <short>a</short>
      <long>adjective</long>
    </entry>
    <entry>
      <short>d</short>
      <long>adverb</long>
    </entry>
    <entry>
      <short>c</short>
      <long>conjunction</long>
    </entry>
    <entry>
      <short>l</short>
      <long>article</long>
    </entry>
    <entry>
      <short>g</short>
      <long>particle</long>
      <lex>verb particle</lex>
    </entry>
    <entry>
      <short>r</short>
      <long>preposition</long>
    </entry>
    <entry>
      <short>p</short>
      <long>pronoun</long>
    </entry>
    <entry>
      <short>m</short>
      <long>numeral</long>
    </entry>
    <entry>
      <short>i</short>
      <long>interjection</long>
    </entry>
    <entry>
      <short>e</short>
      <long>exclamation</long>
    </entry>
    <entry>
      <short>x</short>
      <long>irregular</long>
    </entry>
    <entry>
      <short>u</short>
      <long>punctuation</long>
    </entry>
  </category>,

  (: person :)
  <category id="person" n="2"
            xmlns="http://alpheios.net/namespaces/treebank-util">
    <entry>
      <short>1</short>
      <long>first_person</long>
      <lex>1st</lex>
    </entry>
    <entry>
      <short>2</short>
      <long>second_person</long>
      <lex>2nd</lex>
    </entry>
    <entry>
      <short>3</short>
      <long>third_person</long>
      <lex>3rd</lex>
    </entry>
  </category>,

  (: number :)
  <category id="number" n="3"
            xmlns="http://alpheios.net/namespaces/treebank-util">
    <entry>
      <short>s</short>
      <long>singular</long>
    </entry>
    <entry>
      <short>p</short>
      <long>plural</long>
    </entry>
    <entry>
      <short>d</short>
      <long>dual</long>
    </entry>
  </category>,

  (: tense :)
  <category id="tense" n="4"
            xmlns="http://alpheios.net/namespaces/treebank-util">
    <entry>
      <short>p</short>
      <long>present</long>
    </entry>
    <entry>
      <short>i</short>
      <long>imperfect</long>
    </entry>
    <entry>
      <short>r</short>
      <long>perfect</long>
    </entry>
    <entry>
      <short>l</short>
      <long>pluperfect</long>
    </entry>
    <entry>
      <short>t</short>
      <long>future_perfect</long>
      <lex>future perfect</lex>
    </entry>
    <entry>
      <short>f</short>
      <long>future</long>
    </entry>
    <entry>
      <short>a</short>
      <long>aorist</long>
    </entry>
  </category>,

  (: mood :)
  <category id="mood" n="5"
            xmlns="http://alpheios.net/namespaces/treebank-util">
    <entry>
      <short>i</short>
      <long>indicative</long>
    </entry>
    <entry>
      <short>s</short>
      <long>subjunctive</long>
    </entry>
    <entry>
      <short>o</short>
      <long>optative</long>
    </entry>
    <entry>
      <short>n</short>
      <long>infinitive</long>
    </entry>
    <entry>
      <short>m</short>
      <long>imperative</long>
    </entry>
    <entry>
      <short>g</short>
      <long>gerundive</long>
    </entry>
    <entry>
      <short>p</short>
      <long>participial</long>
      <lex>participle</lex>
    </entry>
  </category>,

  (: voice :)
  <category id="voice" n="6"
            xmlns="http://alpheios.net/namespaces/treebank-util">
    <entry>
      <short>m</short>
      <long>middle</long>
    </entry>
    <entry>
      <short>a</short>
      <long>active</long>
    </entry>
    <entry>
      <short>p</short>
      <long>passive</long>
    </entry>
    <entry>
      <short>d</short>
      <long>deponent</long>
    </entry>
    <entry>
      <short>e</short>
      <long>medio_passive</long>
      <lex>mediopassive</lex>
    </entry>
  </category>,

  (: gender :)
  <category id="gender" n="7"
            xmlns="http://alpheios.net/namespaces/treebank-util">
    <entry>
      <short>m</short>
      <long>masculine</long>
    </entry>
    <entry>
      <short>f</short>
      <long>feminine</long>
    </entry>
    <entry>
      <short>n</short>
      <long>neuter</long>
    </entry>
  </category>,

  (: case :)
  <category id="case" n="8"
            xmlns="http://alpheios.net/namespaces/treebank-util">
    <entry>
      <short>n</short>
      <long>nominative</long>
    </entry>
    <entry>
      <short>g</short>
      <long>genitive</long>
    </entry>
    <entry>
      <short>d</short>
      <long>dative</long>
    </entry>
    <entry>
      <short>a</short>
      <long>accusative</long>
    </entry>
    <entry>
      <short>b</short>
      <long>ablative</long>
    </entry>
    <entry>
      <short>v</short>
      <long>vocative</long>
    </entry>
    <entry>
      <short>i</short>
      <long>instrumental</long>
    </entry>
    <entry>
      <short>l</short>
      <long>locative</long>
    </entry>
  </category>,

  (: degree :)
  <category id="degree" n="9"
            xmlns="http://alpheios.net/namespaces/treebank-util">
    <entry>
      <short>p</short>
      <long>positive</long>
    </entry>
    <entry>
      <short>c</short>
      <long>comparative</long>
    </entry>
    <entry>
      <short>s</short>
      <long>superlative</long>
    </entry>
  </category>
);

declare variable $tbu:s_relations :=
(
  <category id="rel" n="1"
            xmlns="http://alpheios.net/namespaces/treebank-util">
    <entry>
      <aldt>APOS</aldt>
      <disp>APPOS</disp>
    </entry>
    <entry>
      <aldt>ATR</aldt>
      <disp>ATTR</disp>
    </entry>
    <entry>
      <aldt>ATV</aldt>
      <disp>COMP</disp>
    </entry>
    <entry>
      <aldt>AtvV</aldt>
      <disp>COMP</disp>
    </entry>
    <entry>
      <aldt>AuxC</aldt>
      <disp>CONJ</disp>
    </entry>
    <entry>
      <aldt>AuxG</aldt>
      <disp>BRCKT</disp>
    </entry>
    <entry>
      <aldt>AuxK</aldt>
      <disp>TERM</disp>
    </entry>
    <entry>
      <aldt>AuxP</aldt>
      <disp>PREP</disp>
    </entry>
    <entry>
      <aldt>AuxR</aldt>
      <disp>RFLX</disp>
    </entry>
    <entry>
      <aldt>AuxV</aldt>
      <disp>AUXV</disp>
    </entry>
    <entry>
      <aldt>AuxX</aldt>
      <disp>COMMA</disp>
    </entry>
    <entry>
      <aldt>AuxY</aldt>
      <disp>SADV</disp>
    </entry>
    <entry>
      <aldt>AuxZ</aldt>
      <disp>EMPH</disp>
    </entry>
    <entry>
      <aldt>ExD</aldt>
      <disp>ELLIP</disp>
    </entry>
  </category>
);

(:
  Function to convert morphology postag to full name
  
  Parameters:
    $a_category      morphological category
    $a_tag           postag

  Return value:
    equivalent long name if found, else empty
 :)
declare function tbu:postag-to-name(
  $a_category as xs:string,
  $a_tag as xs:string?) as xs:string?
{
  if ($a_tag)
  then
    let $table := $tbu:s_tables[@id = $a_category]
    let $entry := $table/tbu:entry[tbu:short = substring($a_tag, $table/@n, 1)]
    return string($entry/tbu:long)
  else ()
};

(:
  Function to convert morphology postag to lexicon schema value
  
  Parameters:
    $a_category      morphological category
    $a_tag           postag

  Return value:
    equivalent name if found, else empty

  If a lexicon value is not present, the long name is used.
 :)
declare function tbu:postag-to-lexicon(
  $a_category as xs:string,
  $a_tag as xs:string?) as xs:string?
{
  if ($a_tag)
  then
    let $table := $tbu:s_tables[@id = $a_category]
    let $entry := $table/tbu:entry[tbu:short = substring($a_tag, $table/@n, 1)]
    return
      if (exists($entry/tbu:lex))
      then
        string($entry/tbu:lex)
      else
        string($entry/tbu:long)
  else ()
};

(:
  Function to convert morphology code to full name
  
  Parameters:
    $a_category      morphological category
    $a_code          short code

  Return value:
    equivalent long name if found, else empty
 :)
declare function tbu:code-to-name(
  $a_category as xs:string,
  $a_code as xs:string?) as xs:string?
{
  if ($a_code)
  then
    string($tbu:s_tables[@id = $a_category]
              /tbu:entry[tbu:short = $a_code]
              /tbu:long)
  else ()
};

(:
  Function to convert morphology full name to code
  
  Parameters:
    $a_category      morphological category
    $a_name          full name

  Return value:
    equivalent code if found, else empty
 :)
declare function tbu:name-to-code(
  $a_category as xs:string,
  $a_name as xs:string?) as xs:string?
{
  if ($a_name)
  then
    string($tbu:s_tables[@id = $a_category]
              /tbu:entry[tbu:long = $a_name]
              /tbu:short)
  else ()
};

(:
  Function to convert ALDT relation name to display form
  
  Parameters:
    $a_rel           relation

  Return value:
    empty if no input specified, else
    equivalent display name, or input value if no display form found
 :)
declare function tbu:relation-to-display(
  $a_rel as xs:string?) as xs:string
{
  if ($a_rel)
  then
    let $display :=
      string($tbu:s_relations/tbu:entry[tbu:aldt = $a_rel]/tbu:disp)
    return
    if (string-length($display) > 0) then $display else $a_rel
  else ()
};
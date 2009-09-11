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
  Functions to retrieve lexicon entries
 :)

module namespace lxget="http://alpheios.net/namespaces/lexi-get";
import module namespace transform="http://exist-db.org/xquery/transform";  
declare namespace alph="http://alpheios.net/namespaces/tei";

(:
  Function to retrieve a lexicon entry by id

  Parameters:
    $a_lexicon    lexicon to use
    $a_id         id to look up

  Return value:
    lexicon entry if found

  The lexicon may have either entryFree or entry elements.
 :)
declare function lxget:get-entry-by-id(
  $a_lexicon as node()*,
  $a_id as xs:string) as element()?
{
  $a_lexicon//(entryFree|entry)[@id = $a_id]
};

(:
  Function to retrieve a lexicon entry by id

  Parameters:
    $a_lexicon    lexicon to use
    $a_index      index file to use
    $a_lemma      id to look up
    $a_lang       language of lexicon

  Return value:
    lexicon entry if found

  The lexicon may have either entryFree or entry elements.
 :)
declare function lxget:get-entry-by-lemma(
  $a_lexicon as node()*,
  $a_index as node()?,
  $a_lemma as xs:string,
  $a_lang as xs:string) as element()?
{
  (: see if we can find it directly :)
  let $dict-entry := $a_lexicon//(entryFree|entry)[@key eq $a_lemma]
  return
    if (exists($dict-entry))
    then
      $dict-entry
    else
      (:
        transform lemma to unicode
        Note: In order to ensure precomposed unicode,
        we first convert to betacode (which will leave
        betacode input unchanged), then convert to unicode
       :)
      let $uni-lemma :=
        if ($a_lang eq "grc")
        then
          let $beta-lemma :=
            transform:transform(
              <dummy/>,
              doc("/db/xslt/alpheios-uni2betacode.xsl"),
              <parameters>
                <param name="input" value="{ $a_lemma }"/>
              </parameters>)
          return
            transform:transform(
              <dummy/>,
              doc("/db/xslt/alpheios-beta2unicode.xsl"),
              <parameters>
                <param name="input" value="{ $beta-lemma }"/>
              </parameters>)
        else
          $a_lemma
      (: see if unicode lemma can be found directly :)
      let $dict-entry :=
        if ($uni-lemma ne $a_lemma)
        then
          $a_lexicon//(entryFree|entry)[@key eq $uni-lemma]
        else ()
      return
        if (exists($dict-entry))
        then
          $dict-entry
        else
          (:
            find entry in index
            Note: Lemma attribute in index corresponds to
            entryFree/@key or entry/@key in lexicon.
            Key attribute in index is lemma with vowel length
            and diaeresis stripped and capitalization removed.
           :)
          let $index-entry :=
            if ($a_index)
            then
              $a_index//entry[@key eq $uni-lemma]
            else ()

          (: get dictionary entry :)
          return
            if ($index-entry)
            then
              $a_lexicon//(entryFree|entry)[@id eq string($index-entry/@id)]
            else ()
};

(:
  Function to retrieve a lexicon source info

  Parameters:
    $a_lexicon    lexicon to use

  Return value:
    info on source title and author(s)
 :)
declare function lxget:get-source(
  $a_lexicon as node()*) as element()
{
  element alph:source
  {
    text { "From " },
    element title { $a_lexicon//titleStmt/title[1] },

    let $authors := string-join($a_lexicon//titleStmt/author, ", ")
    return if ($authors) then concat(" (", $authors, ") ") else ()
  }
};
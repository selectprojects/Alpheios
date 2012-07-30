(:
  Copyright 2009-2010 Cantus Foundation
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
  Function to retrieve a lexicon entry by lemma

  Parameters:
    $a_lexicon    lexicon to use
    $a_index      index file to use
    $a_lemma      lemma to look up
    $a_lang       language of lexicon

  Return value:
    lexicon entries if found

  The lexicon may have either entryFree or entry elements.
 :)
declare function lxget:get-entry-by-lemma(
  $a_lexicon as node()*,
  $a_index as node()?,
  $a_lemma as xs:string,
  $a_lang as xs:string) as element()*
{
  (: see if we can find it directly :)
  let $dict-entries := $a_lexicon//(entryFree|entry)[@key eq $a_lemma]
  return
    if (exists($dict-entries))
    then
      $dict-entries
    else
      (: transform lemma to unicode :)
      let $uni-lemma :=
        if ($a_lang eq "grc")
        then
          (:
            Note: In order to ensure precomposed Greek unicode,
            we first convert to betacode (which will leave
            betacode input unchanged), then convert to unicode
           :)
          let $beta-lemma :=
            transform:transform(
              <dummy/>,
              doc("/db/xslt/alpheios-uni2betacode.xsl"),
              <parameters>
                <param name="e_in" value="{ $a_lemma }"/>
              </parameters>)
          return
            transform:transform(
              <dummy/>,
              doc("/db/xslt/alpheios-beta2unicode.xsl"),
              <parameters>
                <param name="e_in" value="{ $beta-lemma }"/>
              </parameters>)
        else if ($a_lang eq "ara")
        then
          (:
            We first convert to Buckwalter (which will leave
            Buckwalter input unchanged), then convert to unicode
           :)
          let $buck-lemma :=
            transform:transform(
              <dummy/>,
              doc("/db/xslt/alpheios-uni2buck.xsl"),
              <parameters>
                <param name="e_in" value="{ $a_lemma }"/>
              </parameters>)
          return
            transform:transform(
              <dummy/>,
              doc("/db/xslt/alpheios-buck2uni.xsl"),
              <parameters>
                <param name="e_in" value="{ $buck-lemma }"/>
              </parameters>)
        else
          $a_lemma
      (: see if unicode lemma can be found directly :)
      let $dict-entries :=
        if ($uni-lemma ne $a_lemma)
        then
          $a_lexicon//(entryFree|entry)[@key eq $uni-lemma]
        else ()
      return
        if (exists($dict-entries))
        then
          $dict-entries
        else
        	  (:
	            find entries in index
	            Note: Lemma attribute in index corresponds to
	            entryFree/@key or entry/@key in lexicon.
	            Key attribute in index is normalized lemma, likely with
	            diacritics removed and other transformations performed.
	            There may be multiple entries matching the key if
	            the transformations map multiple lemmas into one key.
	           :)
	          let $index-ids :=
	            if ($a_index)
	            then
	              distinct-values($a_index//entry[@key eq $uni-lemma]/@id)
	            else ()
	
	          (: get dictionary entries :)
	          return
	          	if (exists($index-ids)) then
	            	$a_lexicon//(entryFree|entry)[@id = $index-ids]
	          	else 
					(: one last try with original lemma and a sense appended :)
					(: this hack to try to get lookups which don't know about the :)
					(: special flag in the Alpheios local index to work - e.g. see ἔρρω :)
	        		if (not(matches($a_lemma,"^.*\d+$")))
	        		then 
	        			$a_lexicon//(entryFree|entry)[@key eq concat($a_lemma,'1')]
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

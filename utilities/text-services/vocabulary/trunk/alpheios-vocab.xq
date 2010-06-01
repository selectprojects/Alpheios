(:
  Copyright 2010 Cantus Foundation
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

declare namespace vocab = "http://alpheios.net/namespaces/vocab-freq";
declare namespace tbd = "http://alpheios.net/namespaces/treebank-desc";

(:
  Query to retrieve a frequency-ranked vocabulary list for a given treebank document

  Form of request is:
    alpheios-vocab.xq?doc=<cts urn for the document>&start=<starting index>&count=<number of lemmas to display>&format=<format>&pofs=<pofs>
  where
    doc is the cts urn for the document     
    pofs is a part of speech to limit the search to
    excludepofs is a flag to indicate the pofs listed in the pofs parameter are to be excluded rather than included 
    format is the treebank format for the document (defaults to 'aldt' if not supplied)
    start is the starting index # for paging (defaults to 1 if not supplied)
    count is the number of terms to display (defaults to 10 if not supplied)
  Output Format
      TEI compliant text/xml, each lemma represented by an <entry> element, containing one <form @type='lemma'> child element 
      and one or more <form @type='inflection'> elements
      HTML transformation is up to the client, the alph-vocab.xsl stylesheet is specified as a processing instruction   
 :)

(:
  Recursive function to group the forms of a lemma by number of occurrences of that form in the text 
  Parameters:
      $a_grpText the lemma text
      $a_set the set of forms counted so far for this lemma
      $a_remaining to set of instances of this lemma remaining to be grouped, sorted by form
  Return Value:
      A set of <form/> elements with the count specified in @count and the form text as the text of the element
:)
declare function vocab:group_lemmas(
                                                         $a_grpText as xs:string*, 
                                                         $a_set as element()*, 
                                                         $a_remaining as element()*) as element()*
{
    if ($a_remaining)
        then
            let $group:= vocab:count_forms($a_remaining[1],xs:integer(1),())
            let $new_set := ($a_set, $group[1])
            let $next := $group[2]           
            return             
            if ($next and $next/@lemma = $a_grpText)
                then
                    (: there are still forms remaining to be counted so recurse to count the next form :)
                    vocab:group_lemmas($a_grpText,$new_set,$next)
                else
                    (: no more forms remaining, so return the set of  grouped forms for the lemma :)
                    $new_set  
        else 
            $a_set
};

(:
  Recursive function to count the number of times a form occurs for a given lemma in a text
  Parameters:
      $a_elem the lemma element currently being counted 
      $a_count the number of times a form has occurred so far for the lemma
   Return Value:
      A <form/> element with the count specified in @count and the form text as the text of the element
:)
declare function vocab:count_forms($a_elem as element()*,$a_count as xs:integer,$a_urns as item()*) as element()*
{
    let $next := $a_elem/following-sibling::*:lemma[1]
    let $urns := ($a_urns,$a_elem/*:urn)
    return
     if (not($next) or
         $next/@lemma != $a_elem/@lemma or
         $next/@form != $a_elem/@form                  
       )
        then (
                 (: no more instances of this combination of lemma and form so return the form with the accumulated count :)
                 element form {
                     attribute count {
                         if ($a_elem/@count)
                         then $a_elem/@count
                         else $a_count 
                     },
                     $a_elem/@form,
                     $urns                     
                 },
                 $next
         )           
        else vocab:count_forms($next,$a_count+1,$urns)   
    
};

import module namespace request="http://exist-db.org/xquery/request";
import module namespace tan="http://alpheios.net/namespaces/text-analysis"
              at "textanalysis-utils.xquery";
    declare option exist:serialize "method=xml media-type=text/xml";

let $e_doc := request:get-parameter("urn", ())
let $e_start := xs:int(request:get-parameter("start", xs:int("1")))
let $e_count := xs:int(request:get-parameter("count", xs:int("10")))
let $e_pofs := distinct-values(request:get-parameter("pofs",()))
let $e_excludePofs := xs:boolean(request:get-parameter("excludepofs","false"))

let $results  := tan:getWords($e_doc,$e_excludePofs,$e_pofs)
let $all_words := $results/*:words
let $note := 
    if ($results/@truncated > 0) 
    then concat("Results truncated: only the first ",$results/@count," of ", 
        if ($results/@treebank) then "" else  "possible ", $results/@total, " lemmas analyzed")
    else ""
(: sort the lemma elements by frequency of the lemma, with the individual forms for each lemma
    grouped and sorted by frequency as well 
:)
let $words_counted := 
for $l in  (
    for $j in $all_words/*:lemma[following-sibling::*:lemma[1]/@lemma != @lemma]
           let $lemmas := $all_words/*:lemma[@lemma = $j/@lemma]
           let $forms := vocab:group_lemmas($j/@lemma,(),$lemmas)
            return element lemma {
                $j/@lang,
                 attribute count {sum($forms/@count)},
                 $j/@lemma,
                 $forms,
                 $lemmas/*:urn
             })
    order by xs:int($l/@count) descending
    return $l

(: return the sorted lemmas as  a TEI compliant document :)
return (
processing-instruction xml-stylesheet {
 attribute xml {
	'type="text/xsl" href="../xslt/alpheios-vocab.xsl"'
}
},
<TEI xmlns="http://www.tei-c.org/ns/1.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://www.tei-c.org/ns/1.0 http://www.tei-c.org/release/xml/tei/custom/schema/xsd/tei_dictionaries.xsd">
        <teiHeader>
            <fileDesc>
                <titleStmt><title></title></titleStmt>
                <publicationStmt><date></date></publicationStmt>
                <sourceDesc><p>Alpheios</p></sourceDesc>
                <notesStmt>
                     <note>{$note}</note>
                </notesStmt> 
            </fileDesc>
         </teiHeader> 
         <text pofs="{$e_pofs}" xml:lang="{$words_counted[1]/@lang}">
         <body>         
  { 
    let $total := count($words_counted)
    let $start_less_count := $e_start - $e_count
    let $start_for_last := $total -$e_count+1
    let $start_for_next := $e_start+$e_count
    let $uri := concat(request:get-url(),'?')
    let $qs := replace(request:get-query-string(),'&amp;start=\d+','')
    let $first :=
      if ($e_start > 1)
          then
                element ptr {
                   attribute type { 'paging:first' },
                   attribute target { concat($uri, $qs,"&amp;start=1")}
               }                             
            else ()
       let $prev :=
           if ($start_less_count > $e_count)
           then
               element ptr {
                   attribute type { 'paging:prev' },
                   attribute target { concat($uri,$qs,"&amp;start=",$start_less_count)}
               }               
          else ()       
       let $last := 
           if (($start_for_next) <= $total)
           then
                element ptr {
                   attribute type { 'paging:last' },
                   attribute target { concat($uri,$qs,"&amp;start=",$start_for_last)}
               }                              
           else ()
       let $next := 
           if ($start_for_next < $start_for_last)
           then                
               element ptr {
                   attribute type { 'paging:next' },
                   attribute target { concat($uri,$qs,"&amp;start=",$start_for_next)}
               }               

           else ()
     return ($first,$prev,$next,$last)
  }
  {  
  for $k in ($words_counted[position() >= $e_start and position() < ($e_start+$e_count)])       
        return( 
        <entry lang="{xs:string($k/@lang)}">
           <form type="lemma" lang="{xs:string($k/@lang)}" count="{$k/@count}">{xs:string($k/@lemma)}</form>
           { for $j in $k/*:form 
              order by xs:int($j/@count) descending
             return 
                 <form type="inflection"  lang="{xs:string($k/@lang)}" count="{$j/@count}">{xs:string($j/@form)}
                     { for $u in $k/*:urn 
                       return element ptr {attribute target { concat("alpheios-text.xq?urn=", $u/text()) },$u/text()}
                     }
                 </form> 
            }
        </entry>
        )
      
    }         
         </body>
      </text>
 </TEI>

 )
 
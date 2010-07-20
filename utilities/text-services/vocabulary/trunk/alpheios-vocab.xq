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
import module namespace transform="http://exist-db.org/xquery/transform";

(:
  Query to retrieve a frequency-ranked vocabulary list for a given treebank document

  Form of request is:
    alpheios-vocab.xq?doc=<cts urn for the document>&start=<starting index>&count=<number of lemmas to display>&format=<format>&pofs=<pofs>
  where
    doc is the cts urn for the document     
    pofs is a part of speech to limit the search to
    excludepofs is a flag to indicate the pofs listed in the pofs parameter are to be excluded rather than included    
    format is the output format for the results ('html' or 'xml'; defaults to 'html' if not supplied)
    start is the starting index # for paging (defaults to 1 if not supplied)
    count is the number of terms to display (defaults to 10 if not supplied)
  Output Format
      TEI compliant text/xml, each lemma represented by an <entry> element, containing one <form @type='lemma'> child element 
      and one or more <form @type='inflection'> elements
      HTML transformation is up to the client, the alph-vocab.xsl stylesheet is specified as a processing instruction   
 :)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace tan="http://alpheios.net/namespaces/text-analysis"
              at "textanalysis-utils.xquery";
declare option exist:serialize "method=xml media-type=text/xml";


let $e_doc := request:get-parameter("urn", ())
let $e_start := xs:int(request:get-parameter("start", xs:int("1")))
let $e_count := xs:int(request:get-parameter("count", xs:int("10")))
let $e_pofs := distinct-values(request:get-parameter("pofs",()))
let $e_excludePofs := xs:boolean(request:get-parameter("excludepofs","false"))
let $e_format := request:get-parameter("format", "html")
 

let $pofs_set := if ($e_pofs = "") then () else $e_pofs
let $results  := tan:getWords($e_doc,$e_excludePofs,$pofs_set)
let $all_words := $results/*:words
let $note := 
    if ($results/@truncated > 0) 
    then concat("Results truncated: only the first ",$results/@count," of ", 
        if ($results/@treebank) then "" else  "possible ", $results/@total, " lemmas analyzed")
    else ""
(: sort the lemma elements by frequency of the lemma, with the individual forms for each lemma
    grouped and sorted by frequency as well 
:)
let $xslGroup := doc('/db/xslt/alpheios-vocab-group.xsl')
let $grouped := transform:transform($results, $xslGroup, ())/lemma
let $sorted := for $l in $grouped order by xs:int($l/@count) descending return $l
let $xsl := doc('/db/xslt/alpheios-vocab.xsl')
let $pi := 
    if ($e_format = 'xml' or $e_format = "") 
    then 
         ()    
     (: default to html :)
    else 
        processing-instruction xml-stylesheet {
             attribute xml { 'type="text/xsl" href="../xslt/alpheios-vocab.xsl"'}
        }
 
 let $total := count($sorted)
 let $display_count := if ($e_count >0) then $e_count else $total
 
let $xml :=
($pi,
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
         <text pofs="{$pofs_set}" xml:lang="{$sorted[1]/@lang}" treebank="{$results/@treebank}">
         <body>         
  { 
   
    let $start_less_count := $e_start - $display_count 
    let $start_for_last := $total -$display_count+1
    let $start_for_next := $e_start+$display_count
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
           if ($start_less_count > $display_count)
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
  for $k in ($sorted[position() >= $e_start and position() < ($e_start+$display_count)])  
        return( 
        <entry lang="{xs:string($k/@lang)}">
           <form type="lemma" lang="{xs:string($k/@lang)}" count="{$k/@count}">{xs:string($k/@lemma)}</form>
           { for $j in $k/*:form 
              order by xs:int($j/@count) descending
             return 
                 <form type="inflection"  lang="{xs:string($k/@lang)}" count="{$j/@count}">{xs:string($j/@form)}
                     { for $u in $j/*:urn 
                       return element ptr {attribute target { concat(replace(request:get-url(),'alpheios-vocab.xq','alpheios-text.xq?'),"urn=", $u/text()) },$u/text()}
                     }
                 </form> 
            }
        </entry>
        )
      
    }         
         </body>
      </text>
 </TEI>)

return $xml
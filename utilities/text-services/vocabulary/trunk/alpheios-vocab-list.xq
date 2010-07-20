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


(:
  Query to retrieve stored vocabulary for a specified textgroup or edition

  Form of request is:
    alpheios-vocab-list.xq?urn=<cts urn>&start=<starting index>&count=<number of lemmas to display>&pofs=<pofs>&format=<xml|html>
  where
    urn is the cts urn for the document     
    pofs is the part of speech to limit the search to (Optional)  
    start is the starting index # for paging (defaults to 1 if not supplied)
    count is the number of terms to display (defaults to 10 if not supplied)
    format is the output format (either XML or HTML)
  Output Format
      If format=xml TEI compliant text/xml, each lemma represented by an <entry> element, containing one <form @type='lemma'> child element 
      and one or more <form @type='inflection'> elements
      If format=html paginated HTML transformed per the alpheios-vocab-list.xsl stylesheet         
 :)

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace  util="http://exist-db.org/xquery/util";
import module namespace transform="http://exist-db.org/xquery/transform";
import module namespace request="http://exist-db.org/xquery/request";              
import module namespace cts="http://alpheios.net/namespaces/cts"
              at "cts.xquery";              
declare option exist:serialize "method=xml media-type=text/xml";

let $e_urn := request:get-parameter("urn", ())
let $e_start := xs:int(request:get-parameter("start", 1))
let $e_count := xs:int(request:get-parameter("count", 10))
let $e_pofs := request:get-parameter("pofs",())
let $e_format := request:get-parameter("format",xs:string('xml'))

let $pi := 
    if ($e_format = 'html') 
    then 
        processing-instruction xml-stylesheet {
             attribute xml { 'type="text/xsl" href="../xslt/alpheios-vocab-list.xsl"'}
        }      
    else ()
let $uri := concat(request:get-url(),'?')
let $reply := cts:getPassagePlus("alpheios-cts-inventory",$e_urn)
let $entries := $reply/TEI/text/body//tei:entry
let $total := count($entries)
let $start_less_count := $e_start - $e_count
let $start_for_last := $total -$e_count+1
let $start_for_next := $e_start+$e_count
let $qs := replace(request:get-query-string(),'&amp;start=\d+','')
let $first :=
      if ($e_start > 1)
      then
                element tei:ptr {
                   attribute type { 'paging:first' },
                   attribute target { concat($uri, $qs,"&amp;start=1")}
               }                             
       else ()
       let $prev :=
           if ($start_less_count > $e_count)
           then
               element tei:ptr {
                   attribute type { 'paging:prev' },
                   attribute target { concat($uri,$qs,"&amp;start=",$start_less_count)}
               }               
          else ()       
       let $last := 
           if (($start_for_next) <= $total)
           then
                element tei:ptr {
                   attribute type { 'paging:last' },
                   attribute target { concat($uri,$qs,"&amp;start=",$start_for_last)}
               }                              
           else ()
       let $next := 
           if ($start_for_next < $start_for_last)
           then                
               element tei:ptr {
                   attribute type { 'paging:next' },
                   attribute target { concat($uri,$qs,"&amp;start=",$start_for_next)}
               }               

           else ()
let $prevnext := ($first,$prev,$next,$last)
                         
let $xml := (
    $pi,
     <TEI xmlns="http://www.tei-c.org/ns/1.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://www.tei-c.org/ns/1.0 http://www.tei-c.org/release/xml/tei/custom/schema/xsd/tei_dictionaries.xsd">
        <teiHeader>
            <fileDesc>
                <titleStmt><title></title></titleStmt>
                <publicationStmt><date></date></publicationStmt>
                <sourceDesc><p>Vocabulary For {$e_urn}</p></sourceDesc>
            </fileDesc>
            <encodingDesc>
                <appInfo>
                    <application ident="alpheios-vocabulary-word-url">
                        <ptr target="{concat(replace($uri,"alpheios-vocab-list.xq","alpheios-vocab-get.xq"),'urn=',$e_urn,'&amp;entryId=WORD')}"/> 
                    </application>
                </appInfo>
            </encodingDesc>
         </teiHeader> 
         <text pofs="{$e_pofs}" xml:lang="{$entries[1]/@xml:lang}">
         <body>
             { $prevnext }
             { for $e in ($entries[position() >= $e_start and position() < ($e_start+$e_count)]) return $e }             
         </body>
         </text>
       </TEI>
 )
return $xml
    


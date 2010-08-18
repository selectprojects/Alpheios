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

declare namespace infl = "http://alpheios.net/namespaces/inflections";
(:
  Query to retrieve a frequency-ranked inflection list for a given treebank document
  Form of request is:
    alpheios-infl-freq.xq?urn=<cts urn for the document>&pofs=<pofs>&sort=<inflection|ending>
  where
    urn is the cts urn of the document
    pofs is the part of speech to which to limit the analysis
    sort is the sort key, either 'ending' or 'inflection'
    
  Output Format
      text/xml document in the "http://alpheios.net/namespaces/forms" namespace
      mostly adheres to the alpheios inflection schema -- schema updates pending
      root element is <ending/>, containing a list of grouped 
          <infl-ending-set/> (sort by inflection) or 
          <ending-set/> (sort by ending)             
      HTML transformation is up to the client, the alpheios-infl-freq.xsl stylesheet is specified as a processing instruction          
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace tan="http://alpheios.net/namespaces/text-analysis"
              at "textanalysis-utils.xquery";
declare option exist:serialize "method=xml media-type=text/xml";

let $e_urn := request:get-parameter("urn", ())
let $e_pofs := request:get-parameter('pofs',())
let $e_sort := request:get-parameter('sort',())

let $results := tan:getInflections($e_urn,$e_pofs)
let $xsl := doc('/db/xslt/alpheios-infl-group.xsl')
let $params := 
    <parameters>    
        <param name="e_sort" value="{$e_sort}"/>
        <param name="e_pofs" value="{$e_pofs}"/>
      </parameters>
let $instances := for $e in $results//*:instance[descendant::forms:pofs/text() = $e_pofs] return $e      
let $grouped := transform:transform(<forms>{$instances}</forms>, $xsl, $params)

return(
    processing-instruction xml-stylesheet {
     attribute xml {'type="text/xsl" href="../xslt/alpheios-infl-freq.xsl"'}
    },
  <endings lang="{xs:string(//inflections/@xml:lang)}" docid="{$e_urn}" pofs="{$e_pofs}" count="{$results/@count}"
      total="{$results/@total}" truncated="{$results/@truncated}" treebank="{$results/@treebank}">
      <order-table>
           <order-item attname="pofs" order="1">noun</order-item>
           <order-item attname="pofs" order="2">verb</order-item>
           <order-item attname="pofs" order="3">adjective</order-item>  
       </order-table>      
  {   $grouped   }
</endings>)
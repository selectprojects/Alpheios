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
  Query to retrieve and display an excerpt of an Alpheios enhanced text, referenced by a specific word
    Form of request is:
    alpheios-get-ref.xq?urn=<cts urn>
  where
    urn is the CTS urn for the referenced word
    
  Output Format  XHTML (Alpheios Enhanced Text display)  
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace transform="http://exist-db.org/xquery/transform";
import module namespace cts="http://alpheios.net/namespaces/cts" 
            at "cts.xquery";
import module namespace tan="http://alpheios.net/namespaces/text-analysis"
            at "textanalysis-utils.xquery";

declare option exist:serialize "method=xhtml media-type=text/html";

let $e_urn :=  request:get-parameter("urn",())
let $e_level := xs:int(request:get-parameter("level","1"))
let $urns := cts:expandValidReffs("alpheios-cts-inventory",$e_urn,$e_level)
let $doc := cts:getDoc($e_urn)
let $header :=  element { QName("http://www.tei-c.org/ns/1.0","teiHeader")} { $doc//*:teiHeader/* }
let $toc :=
     <TEI>
        {$header}
         <text>
         <front>
             <div type="contents">                 
                    { $urns }                
            </div>
        </front>
        </text>
    </TEI>
let $xml := tan:change-element-ns-deep($toc,"http://www.tei-c.org/ns/1.0","tei") 
let $xsl := doc('/db/xslt/alpheios-enhanced-toc.xsl')
let $html := transform:transform($xml, $xsl, ())                                             
return $html
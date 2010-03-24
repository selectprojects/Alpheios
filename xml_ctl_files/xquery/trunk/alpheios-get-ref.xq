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
let $reply := cts:getPassagePlus("alpheios-cts-inventory",$e_urn)
let $prevUrn := xs:string($reply/prevnext/prev)
let $nextUrn := xs:string($reply/prevnext/next)
let $nodes := $reply/TEI/*
let $wd_ref := count($nodes) =xs:int(1) and $nodes[1]/name() = 'wd'
let $wd_id := if ($wd_ref)  then xs:string($nodes[1]/@id) else ""
let $parent := if ($wd_ref) then cts:getPassagePlus("alpheios-cts-inventory",replace($e_urn,":[^:]+$",""))/TEI/* else ()
let $passage := if ($parent) then $parent else $nodes                          
let $docinfo := tan:findDocs(cts:parseUrn($e_urn))
(: TODO check availability of treebank files and fixup doc urn :)
let $treebankDUrl := concat('version=1.0;http://repos.alpheios.net:8080/exist/rest/db/app/treebank-editsentence.xhtml?doc=',$e_urn,'&amp;id=SENTENCE&amp;w=WORD&amp;app=viewer')
let $treebankMUrl := concat('http://repos.alpheios.net:8080/exist/rest/xq/treebank-getmorph.xq?f=',$e_urn,'&amp;w=WORD')
(: TODO drop subref off urn but leave top most passage :)
let $vocabUrl := if ($docinfo/morph) then concat("http://dev.alpheios.net:8800/exist/rest/xq/alpheios-vocab.xq?&amp;start=1&amp;count=10&amp;pofs=POFS&amp;doc=",$e_urn) else ""
let $xsl := doc('/db/xslt/alpheios-enhanced.xsl')
let $params := 
    <parameters>     
        <param name="alpheiosPedagogicalText" value="true"/>
        <param name="alpheiosSiteBaseUrl" value="http://alpheios.net/alpheios-texts"/>
        <param name="alpheiosVocabUrl" value="{$vocabUrl}"/>
        <param name="cssFile" value ="http://alpheios.net/alpheios-texts/css/alpheios-text.css"/>
        <param name="highlightWord" value="{ $wd_id }"/>
     </parameters>
let $uri := concat(request:get-url(),'?')
 let $xml :=
    element TEI.2 {
        $passage/..//TEI.2/@*,
        $passage/..//TEI.2/teiHeader,
        element text {
            $reply/TEI/@xml:lang,            
            element body {
                if ($prevUrn) then 
                    element ptr {
                       attribute type { 'paging:prev' },
                       attribute target { concat($uri,"&amp;urn=",$prevUrn)}
                   }               
                else (),
                if ($nextUrn) then 
                    element ptr {
                       attribute type { 'paging:next' },
                       attribute target { concat($uri,"&amp;urn=",$nextUrn)}
                   }               
                else (),
                $passage
            }
         }
    }
    let $html := transform:transform($xml, $xsl, $params)
    return $html
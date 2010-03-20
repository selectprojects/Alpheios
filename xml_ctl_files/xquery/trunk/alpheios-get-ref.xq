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
let $node := cts:getPassage("alpheios-cts-inventory",$e_urn)
let $passage := if ($node[1]/name() = 'wd') then (<p>...</p>,  $node[1]/ancestor::*[1], <p>...</p>) else $node[1]                           
let $wd_id := if ($node[1]/name() = 'wd')  then xs:string($node[1]/@n) else ""
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
let $xmllang := $node[1]/ancestor::*[@xml:lang][1]/@xml:lang
let $lang := $node[1]/ancestor::*[@lang][1]/@lang
 let $xml :=
    element TEI.2 {
        $passage/..//TEI.2/@*,
        $passage/..//TEI.2/teiHeader,
        element text {
            if ($xmllang) then attribute xml:lang { $xmllang} else (),
            if ($lang) then attribute lang { $lang } else (),
            element body {                
                $passage
            }
         }
    }
    let $html := transform:transform($xml, $xsl, $params)
    return $html
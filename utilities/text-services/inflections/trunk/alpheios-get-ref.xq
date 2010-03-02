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
declare namespace morph = "http://alpheios.net/namespaces/morphology";

(:
  Query to retrieve and display an excerpt of an Alpheios enhanced text
    Form of request is:
    alpheios-get-ref.xq?doc=<docname>&lang=<document language>&w=<id of referenced word>
  where
    doc is the stem of document file name (without path or extensions)
    lang is the language code for the document
    w is the referenced word
    
  Output Format  XHTML (Alpheios Enhanced Text display)  
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace transform="http://exist-db.org/xquery/transform";
declare option exist:serialize "method=xhtml media-type=text/html";

let $e_doc := request:get-parameter("doc", ())
let $e_lang := request:get-parameter("lang",())
let $e_word :=  xs:integer(request:get-parameter("w",()))
let $docname := concat("/db/repository/alpheios_enhanced/" , $e_doc , ".", $e_lang, ".xml")
let $doc := doc($docname) 
let $wd := $doc//*:wd[position() eq $e_word]
let $wd_id := xs:string($wd/@n) 
let $sentence := $wd/ancestor::*[1]
let $treebankDUrl := concat('version=1.0;http://repos.alpheios.net:8080/exist/rest/db/app/treebank-editsentence.xhtml?doc=',$e_doc,'&amp;id=SENTENCE&amp;w=WORD&amp;app=viewer')
let $treebankMUrl := concat('http://repos.alpheios.net:8080/exist/rest/xq/treebank-getmorph.xq?f=',$e_doc,'&amp;w=WORD')
let $doclang :=  
    if ($doc/TEI.2/text/@*:lang)
    then xs:string($doc/TEI.2/text/@*:lang)
    else $e_lang
let $xsl := doc('/db/xslt/alpheios-enhanced.xsl')
let $params := 
    <parameters>     
        <param name="alpheiosPedagogicalText" value="true"/>
        <param name="alpheiosSiteBaseUrl" value="http://alpheios.net/alpheios-texts"/>
        <param name="alpheiosTreebankDiagramUrl"  value="{ $treebankDUrl }"/>
        <param name="alpheiosTreebankUrl"  value="{ $treebankMUrl }"/>
        <param name="cssFile" value ="http://alpheios.net/alpheios-texts/css/alpheios-text.css"/>
        <param name="highlightWord" value="{ $wd_id }"/>
        <param name="doclang" value="{$doclang}"/>
     </parameters>
 let $xml :=
    element TEI.2 {
        $doc/TEI.2/@*,
        $doc/TEI.2/teiHeader,
        element text {
            $doc/TEI.2/text/@*,
            element body {
                <p>...</p>,                
                $sentence,
                <p>...</p>
            }
         }
    }
    let $html := transform:transform($xml, $xsl, $params)
    return $html    

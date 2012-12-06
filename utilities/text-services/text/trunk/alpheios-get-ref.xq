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
import module namespace util="http://exist-db.org/xquery/util";
import module namespace transform="http://exist-db.org/xquery/transform";
import module namespace cts="http://alpheios.net/namespaces/cts" 
            at "cts.xquery";
import module namespace tan="http://alpheios.net/namespaces/text-analysis"
              at "textanalysis-utils.xquery";
declare option exist:serialize "method=xhtml media-type=text/html";

let $e_urn :=  request:get-parameter("urn",())
let $e_inv := request:get-parameter("inv","alpheios-cts-inventory")
let $e_repos :=  request:get-parameter("repos","repos1.alpheios.net")
let $e_format :=  request:get-parameter("format","html")
let $e_audioFormat := request:get-parameter("af","mp3")
let $reply := cts:getPassagePlus($e_inv,$e_urn,true())
let $under_copyright := cts:isUnderCopyright($e_inv,$e_urn)
let $prevUrn := xs:string($reply/prevnext/prev)
let $nextUrn := xs:string($reply/prevnext/next)
let $nodes := $reply/TEI/text/body 
let $docid := $reply/TEI/@id 
let $wd_id := if ($reply/subref/*[local-name(.) = 'wd']/@n) then ($reply/subref/*[local-name(.) = 'wd']/@n) else if ($reply/subref/*[local-name(.) = 'wd']/@id) then $reply/subref/*[local-name(.) = 'wd']/@id else "" 
let $passage := $nodes
let $parsed := cts:parseUrn($e_urn)
let $docinfo := tan:findDocs($parsed)
let $config := doc('/db/xq/config/services.xml')
let $audio_path := concat('/audio/',
    replace(
        replace(
            concat(substring-after($parsed/workUrn,'urn:cts:'),':',$parsed/passage),
            ':','/'
        ),
        '\[\]',''
    ),'.',$e_audioFormat)
let $audio_available := util:binary-doc-available($audio_path)
let $vocabsvc := $config/services/vocabulary/service[1]
let $rights := if ($under_copyright) then cts:getRights($e_inv,$e_urn) else ""
(: TODO fixup doc urn  for treebank?:)
let $treebankDUrl := 
    if ($docinfo/treebank)
    then concat('version=1.0;http://', $e_repos, '/exist/rest/db/app/treebank-editsentence.xhtml?doc=',$docid,'&amp;id=SENTENCE&amp;w=WORD&amp;app=viewer')
    else ""     
let $treebankMUrl :=
    if ($docinfo/treebank)
    then concat('http://', $e_repos, '/exist/rest/xq/treebank-getmorph.xq?f=',$docid,'&amp;w=WORD')
    else ""
(: TODO performance improvements needed for vocab to reference entire book ... or else limit it to a range :) 
let $vocabUrl := if ($vocabsvc and $docinfo/treebank) then replace($vocabsvc,'URN',encode-for-uri($parsed/workUrn)) else ""
let $xsl := doc('/db/xslt/alpheios-enhanced.xsl')
let $params := 
    <parameters>     
        <param name="alpheiosPedagogicalText" value="true"/>
        <param name="alpheiosSiteBaseUrl" value="http://alpheios.net/alpheios-texts"/>
        <param name="alpheiosTreebankUrl" value="{$treebankMUrl}"/>
         <param name="alpheiosTreebankDiagramUrl" value="{$treebankDUrl}"/>
        <param name="alpheiosVocabUrl" value="{$vocabUrl}"/>
        <param name="cssFile" value ="http://alpheios.net/alpheios-texts/css/alpheios-text.css"/>
        <param name="highlightWord" value="{ xs:string($wd_id) }"/>
        <param name="rightsText" value="{$rights}"/>
     </parameters>
let $uri := concat(request:get-uri(),'?')
 let $text :=
    element TEI.2 {   
    	$reply//TEI/@id,     
         $reply//*:teiHeader,
         $reply//*:teiheader,
        element text {
            $reply//text/@xml:lang,            
            element body {
                if ($prevUrn) then 
                    element ptr {
                       attribute type { 'paging:prev' },
                       attribute target { concat($uri,"&amp;urn=",$prevUrn,"&amp;inv=",$e_inv)}
                   }               
                else (),
                if ($nextUrn) then 
                    element ptr {
                       attribute type { 'paging:next' },
                       attribute target { concat($uri,"&amp;urn=",$nextUrn,"&amp;inv=",$e_inv)}
                   }               
                else (),
                if ($audio_available) then
                    element link {
                        attribute type { 'audio' },
                        attribute href { $audio_path }
                    }
                else (),   
                $passage
            }
         }
    }
    let $xml := tan:change-element-ns-deep($text,"http://www.tei-c.org/ns/1.0","tei") 
    let $html := transform:transform($xml, $xsl, $params)  
    (: DON'T ALLOW XML DOWNLOAD OF COPYRIGHT TEXTS :)
    return if ($e_format = 'xml' and not($under_copyright)) then $xml else $html
    

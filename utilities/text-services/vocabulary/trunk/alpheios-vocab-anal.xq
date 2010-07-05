(:
  Copyright 2010 The Alpheios Project, Ltd.
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
declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace util = "http://exist-db.org/xquery/util"; 
import module namespace request="http://exist-db.org/xquery/request";
import module namespace tan="http://alpheios.net/namespaces/text-analysis"
              at "textanalysis-utils.xquery";
import module namespace cts="http://alpheios.net/namespaces/cts"
              at "cts.xquery";              
import module namespace httpclient = "http://exist-db.org/xquery/httpclient";
declare namespace forms = "http://alpheios.net/namespaces/forms";

let $e_docUrn := request:get-parameter("docUrn", ())
let $e_doc := request:get-parameter("doc",())
let $e_vocabUrn := request:get-parameter("vocabUrn", ())
let $e_vocabDoc := request:get-parameter("vocabDoc", ())
let $e_pofs := distinct-values(request:get-parameter("pofs",()))
let $e_excludePofs := xs:boolean(request:get-parameter("excludepofs","false"))
let $e_format := request:get-parameter("format","html")

let $sourceWords  :=
    if ($e_docUrn) then
    tan:getWords($e_docUrn,$e_excludePofs,$e_pofs)
    (: returns ungrouped sequence of                          
       <lemma sense="{$sense}" lang="{$lang}" form="{$form}" count="{$count}" lemma="{$lemma}"/>       
    :)
    else if ($e_doc)
    (: TODO tokenize and parse supplied text :)
    then (:tan:tokenizeWords($e_doc):)()   
    else ()

let $all_words := $sourceWords//lemma

let $vocab_doc := 
    if ($e_vocabUrn)
    then 
        let $cts := cts:parseUrn($e_vocabUrn)        
        return
        (: stored vocabulary document? :)
        if (matches($e_vocabUrn,"alpheios-vocab"))
        then 
            (: if a specific edition was specified, return only the vocabulary file for that edition :)            
            if ($cts/fileInfo/alpheiosEditionId)        
            then 
                doc(concat($cts/fileInfo/basePath, "/alpheios-vocab-",$cts/fileInfo/alpheiosEditionId,".xml"))
            (: otherwise return the entire set of vocab files for the work :)
            else        
                collection($cts/fileInfo/basePath)
        else 
            (: stored alpheios-enabled text :)
            let $url := concat(replace(request:get-url(),'alpheios-vocab-anal.xq','alpheios-vocab.xq?'),"urn=",$e_vocabUrn,"&amp;format=xml&amp;count=-1&amp;excludepofs=",$e_excludePofs,"&amp;pofs=",
                string-join($e_pofs,"&amp;pofs="))
            return httpclient:get(xs:anyURI($url),false(),())//tei:TEI                                    
    else (: tei vocab list from Alpheios tools:) 
        util:parse($e_vocabDoc)

(: for now, only consider the lemmas .. TODO configurable to include forms and senses :)
let $vocab_entries := $vocab_doc//tei:entry[tei:form[@type="lemma"]]    
   
(: if treebanked text, then lemma count is precise; otherwise it's the total possible lemmas as identified by the morphology service :)
let $doc_lemma_count := count($all_words//lemma)
let $docType := if ($sourceWords/@treebank = "true") then "treebank" else if ($e_docUrn) then "morphology" else "user"
let $vocabType := 
    if (matches($e_vocabUrn,"alpheios-vocab")) then "vocablist" 
    else if ($e_vocabUrn) then 
        if ($vocab_doc//tei:text[@treebank = "true"]) then "treebank" else "morphology"
    else ("user")        

let $vocab_lemma_count := count($vocab_entries )

let $results := tan:matchLemmas($all_words//lemma, $vocab_entries)
let $pi := 
    if ($e_format = 'html') 
    then 
       processing-instruction xml-stylesheet {
             attribute xml { 'type="text/xsl" href="../xslt/alpheios-vocab-anal.xsl"'}
        }
    else ()        
return
($pi,
<results docType="{$docType}" vocabType="{$vocabType}" docUrn="{$e_docUrn}" vocabUrn="{$e_vocabUrn}">    
    <count type="docForms">{$doc_lemma_count}</count>
    <count type="vocabLemmas">{$vocab_lemma_count}</count> 
    <count type="formLemmaFound">{count($results)}</count>
    <formsFound>
        { for $r in $results
            return
                element match {
                    $r/@*,
                    for $u in $r/*:urn return element tei:ptr {attribute target { concat("alpheios-text.xq?urn=", $u/text()) },$u/text()}
               }
        }              
    </formsFound>
</results>)
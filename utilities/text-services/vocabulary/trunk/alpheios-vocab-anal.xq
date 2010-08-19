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
let $e_doc := request:get-parameter("doc","")
let $e_vocabUrn := request:get-parameter("vocabUrn", ())
let $e_vocabDoc := request:get-parameter("vocabDoc", ())
let $e_pofs := distinct-values(request:get-parameter("pofs",()))
let $e_excludePofs := xs:boolean(request:get-parameter("excludepofs","false"))
let $e_format := request:get-parameter("format","html")
let $e_details := request:get-parameter("details",())
let $e_reverse := xs:boolean(request:get-parameter("missed","false"))
let $e_lang := request:get-parameter("lang",xs:string('en'))
let $e_toDrop := string-join(request:get-parameter("toDrop",()),',')


(: tan:getWords returns ungrouped sequence of                          
    <lemma sense="{$sense}" lang="{$lang}" form="{$form}" count="{$count}" lemsma="{$lemma}"/>       
:)
let $sourceWords  :=
    if ($e_doc != "")
    then 
        tan:getWords(concat('alpheiosusertext:',$e_lang,':',$e_doc),$e_excludePofs,$e_pofs)
    else
        let $all := for $u in $e_docUrn return tan:getWords($u,$e_excludePofs,$e_pofs)
        return 
        element result {
            attribute treebank { if ($all[@treebank != 'false']) then true() else false() },
            <words> { $all//lemma } </words>                
        }                        
    
(: group the results of tan:getWords by form, lemma and sense to get a set of distinct form+lemma+sense :)
let $group_xsl := doc('/db/xslt/alpheios-vocab-group-forms.xsl')
let $grouped_words := transform:transform($sourceWords, $group_xsl, ())
let $all_words := $grouped_words//lemma

let $vocab_entries :=
    if (count($e_vocabUrn)>0)
    then
        for $v in $e_vocabUrn
            let $cts := cts:parseUrn($v)        
            return
            (: stored vocabulary document? :)
                if (matches($v,"alpheios-vocab"))
                then
                    cts:getPassagePlus("alpheios-cts-inventory",$v)//tei:entry                    
                else 
                    (: stored alpheios-enabled text :)
                    let $url := concat(replace(request:get-url(),'alpheios-vocab-anal.xq','alpheios-vocab.xq?'),"urn=",$v,"&amp;format=xml&amp;count=-1&amp;excludepofs=",$e_excludePofs,"&amp;pofs=",
                        string-join($e_pofs,"&amp;pofs="))
                    let $vocabDoc := httpclient:get(xs:anyURI($url),false(),())                         
                    return $vocabDoc//tei:entry                                    
    else (: tei vocab list from Alpheios tools:) 
        util:parse($e_vocabDoc)
    
(: for now, only consider the lemmas .. TODO configurable to include forms and senses :)
let $vocab_lemmas := $vocab_entries[tei:form[@type="lemma"]]    
   
(: if treebanked text, then lemma count is precise; otherwise it's the total possible lemmas as identified by the morphology service :)
let $doc_form_count := count($all_words//lemma)
let $doc_word_count := count(distinct-values($all_words//forms:urn))
let $docType := if ($sourceWords/@treebank = 'true') then "treebank" else if (count($e_docUrn) > 0) then "morphology" else "user"
let $vocabType := 
    if (matches($e_vocabUrn,"alpheios-vocab")) then "vocablist" 
    else if (count($e_vocabUrn)) then "morphology"
        (:if ($vocab_doc//tei:text[@treebank = "true"]) then "treebank" else "morphology":)
    else ("user")        

let $vocab_lemma_count := count($vocab_lemmas)

let $stripper := if ($e_lang = 'ara') then doc('/db/xslt/alpheios-ara-unistrip_v2.xsl') else ()  
let $results := tan:matchLemmas($e_reverse,$all_words//lemma, $vocab_lemmas,$stripper,$e_toDrop)
let $pi := 
    if ($e_format = 'html') 
    then 
       processing-instruction xml-stylesheet {
             attribute xml { 'type="text/xsl" href="../xslt/alpheios-vocab-anal.xsl"'}
        }
    else ()

return
($pi,
<results docType="{$docType}" vocabType="{$vocabType}">
    <docUrns>{                
                for $u in $e_docUrn return if ($u) then <urn label="{cts:getExpandedTitle('alpheios-cts-inventory',$u)}">{$u}</urn> else ()              
    } </docUrns>    
    <docText>{$e_doc}</docText>    
    <vocabUrns>
        {for $u in $e_vocabUrn return if ($u) then <urn label="{cts:getExpandedTitle('alpheios-cts-inventory',$u)}">{$u}</urn> else ()}
    </vocabUrns>
    <count type="docForms">{$doc_form_count}</count>
    <count type="vocabLemmas">{$vocab_lemma_count}</count>
    <count type="docTotalWords">{$doc_word_count}</count>
    <count type="formLemmaFound">{count($results)}</count>
    <vocab>{$vocab_lemmas}</vocab>
    { if ($e_details) then 
        <lemmas found="{not($e_reverse)}">
            { for $r in $results
                return
                    element match {
                        $r/@*,
                        for $u in $r/*:urn return element tei:ptr {attribute target { concat(replace(request:get-url(),'alpheios-vocab-anal.xq','alpheios-text.xq?'),"urn=", $u/text()) },$u/text()}
                   }
            }              
        </lemmas>
    else <lemmas found="{not($e_reverse)}"/>    
    }
</results>)
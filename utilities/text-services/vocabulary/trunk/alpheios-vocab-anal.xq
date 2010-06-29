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


let $e_docUrn := request:get-parameter("docUrn", ())
let $e_doc := request:get-parameter("doc",())
let $e_vocabUrn := request:get-parameter("vocabUrn", ())
let $e_vocabDoc := request:get-parameter("vocabDoc", ())
let $all_words  :=
    if ($e_docUrn) 
    then  tan:getWords($e_docUrn,false(),"noun")
    (: returns ungrouped sequence of                         
       <lemma sense="{$sense}" lang="{$lang}" form="{$form}" count="{$count}" lemma="{$lemma}"/>       
    :)
    else if ($e_doc)
    then (:tan:tokenizeWords($e_doc):)()   
    else (<lemma sense="1" form="باب" count="1" xml:lang="ar" lemma="باب"/>)
let $vocab_doc := 
    if ($e_vocabUrn)
    then 
        let $cts := cts:parseUrn($e_vocabUrn)        
        return
        (: if a specific edition was specified, return only the vocabulary file for that edition :)
        if ($cts/fileInfo/alpheiosEditionId)        
        then 
            doc(concat($cts/fileInfo/basePath, "/alpheios-vocab-",$cts/fileInfo/alpheiosEditionId,".xml"))
        (: otherwise return the entire set of vocab files for the work :)
        else        
            collection($cts/fileInfo/basePath)
    else 
        util:parse($e_vocabDoc)
        (: tei list :)
let $vocab_entries := $vocab_doc//tei:entry[tei:form[@type="lemma"]]    

(: if treebanked text, then lemma count is precise; otherwise it's the total possible lemmas as identified by the morphology service :)
let $doc_lemma_count := count($all_words//lemma)

let $vocab_lemma_count := count($vocab_entries/node() )

let $results := tan:matchLemmas($all_words//lemma, $vocab_entries)
let $vresults := tan:matchVocab($vocab_entries,$all_words//lemma)
return
<results>
    <count type="doc">{$doc_lemma_count}</count>
    <count type="vocab">{$vocab_lemma_count}</count> 
    <count type="lemmasFound">{count($results)}</count>
    <count type="vocabFound">{count($vresults)}</count>
    <vocabFound>
        {$vresults}
    </vocabFound>    
    <lemmasFound>
        { $results } 
    </lemmasFound>    
</results>
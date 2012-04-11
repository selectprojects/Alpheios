(:
  Copyright 2012 The Alpheios Project, Ltd.
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
  Query to search data in treebank

  Form of request is:
    .../tb-search.xq?urn=<urn>&param=value
    where param is one of:
    lemma
    form
    pos
    morph
    relation
  where
 :)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace cts="http://alpheios.net/namespaces/cts" 
            at "cts.xquery";
import module namespace tan  = "http://alpheios.net/namespaces/text-analysis"
            at "textanalysis-utils.xquery";
import module namespace tbu="http://alpheios.net/namespaces/treebank-util"
              at "treebank-util.xquery";              

            
declare option exist:serialize "method=xml media-type=text/xml";

let $e_urn := request:get-parameter("urn", ())
let $e_form := request:get-parameter("form", ())
let $e_lemma := request:get-parameter("lemma", ())
let $e_morph := request:get-parameter("morph", ())
let $e_pos := request:get-parameter("pos", ())
let $e_relation := request:get-parameter("relation", ())
let $max := xs:int(request:get-parameter("count", "100"))

let $results :=
    if ($e_urn)
    then
        (: if we have a urn then we limit the results to that subset :)
        let $cts := cts:parseUrn($e_urn)
        let $docinfo := tan:findDocs($cts)
        let $tbDoc := doc($docinfo/treebank)
        let $tbRefs := doc(tan:getTreebankRefs($cts,false())) 
        return 
        	if ($cts/passageParts/rangePart)
        	then
        	  element treebank {
	          	  $tbDoc/treebank/@*,          	             
	          	  $tbDoc/treebank/*[local-name(.) != 'sentence'],
	          	  for $ref in $tbRefs//ref          	                 
	          	     let $sentence-id :=
	                    if (contains($ref, "-")) then substring-before($ref, "-") else $ref
	                    let $word-id :=
	                        if (contains($ref, "-")) then substring-after($ref, "-") else ()
	                        let $sentence := $tbDoc//sentence[@id = $sentence-id]
	                        return
	                            if ($sentence)
	                            then
	                                <sentence> {
	                                    $sentence/@*,
	                                    if ($word-id)
	                                    then
	                                        $sentence/word[@id = $word-id]
	                                    else 
	                                        $sentence/*
	                                }</sentence>
	                              else
	                                ()
	                }
	        else $tbDoc/treebank
    else
        collection("/db/repository/treebank")

let $filtered := 
    if ($e_form)
    then
        $results//word[@form=$e_form]
    else if ($e_lemma) 
    then    
        $results//word[@lemma=$e_lemma]
    else if ($e_morph)
    then
        $results//word[@postag=$e_morph]
    else if ($e_pos)
    then 
    	for $w in $results//word
    	return if (tbu:get-format-query($w,'pos',$e_pos,'aldt','/db/xq/config')) then $w else ()
    else if ($e_relation)
    then    
        $results//word[@relation=$e_relation]
    else    
        ()
    
return
    <results> {
        attribute form { $e_form },
        attribute lemma { $e_lemma },
        attribute pos {$e_pos},
        attribute morph {$e_morph},
        attribute relation {$e_relation},
        for $item in ($filtered[position() < $max])
            let $tbdoc := root($item)/*:treebank
            let $sentence := $item/parent::*:sentence
            return element {name($tbdoc)} {
                $tbdoc/@*,
                $tbdoc/*[local-name(.) != 'sentence'],
                element {name($sentence)} {
                    $sentence/@*,
                    $item
                }
            }
      } </results>
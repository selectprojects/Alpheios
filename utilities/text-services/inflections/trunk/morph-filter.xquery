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
    Query to prepare morphology output for inflection frequency analysis by  
    filtering to a single inflection per form according to treebanked data
    
      Form of request is:
          morph-filter.xquery?doc=<docname>&lang=<language>&min=<minimum # of instances of an inflection required to include in the analysis>
       Where
            doc is the stem of document file name (without path or extensions)
            lang is the language code for the document
            min is the minimum # of instances of an inflection required to include it in the analysis   
:)
import module namespace tbm="http://alpheios.net/namespaces/treebank-morph" at "treebank-morph.xquery";
import module namespace request="http://exist-db.org/xquery/request";
declare default element namespace "http://alpheios.net/namespaces/forms";
declare option exist:serialize "method=xml media-type=text/xml";

(:
    Function to compare two sets of morphology data elements to see if they match 
:)
declare function morph:match_morph($a_infl1 as node()*, $a_infl2 as node()*, $a_index as xs:int) as xs:boolean*
{
    let $n := $a_infl1[position() = $a_index]
    let $next := $a_infl1[position() = $a_index+1]
    let $p := $a_infl2/*[local-name(.) = local-name($n)]
    return
        if ($n/*)
        then
          morph:match_morph($n/*,$a_infl2,xs:int('1'))          
        else
          if ($n/text() eq $p/text())
          then 
            if ($next)
            then
                morph:match_morph($a_infl1,$a_infl2,$a_index+1)
            else 
                true()
          else 
            false()

};

let $e_doc := request:get-parameter("doc", ())
let $e_lang := request:get-parameter("lang", ())
let $e_min := xs:int(request:get-parameter("min", xs:int(1)))

let $tei_doc := doc(concat("/db/repository/alpheios_enhanced/" , $e_doc , "." , $e_lang, ".xml"))
let $morph_all := doc(concat("/db/repository/morphology/", $e_doc, ".morph.all.xml"))
let $treebank := doc(concat("/db/repository/treebank/", $e_doc, ".tb.xml"))
return
<forms>
{
for $i in ($morph_all//*:inflection[*:words and  count(*:urn) >= $e_min])
    return element inflection {
        $i/@form,
         <instances> {
            for $u in $i/*:urn
                return  
                <instance>
                {$u, 
                let $num := xs:int(replace($u,".*:",""))
                let $aref := $tei_doc//*:wd[$num]                
                let $tbref := if ($aref/@tbrefs) then xs:string($aref/@tbrefs) else xs:string($aref/@tbref) 
                let $tbmorph := tbm:get-morphology($treebank,$tbref)
                let $tbinfl :=  for $infl in $i//*:infl where morph:match_morph($tbmorph//*:infl,$infl,xs:int('1')) return $infl
                (: TODO - if multiple infls match, need to figure out which is right :)                
                 return $tbinfl[1]
               }
               </instance>
         }</instances>
    }
}
</forms>

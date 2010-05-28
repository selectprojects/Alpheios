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

declare namespace infl = "http://alpheios.net/namespaces/inflections";
declare default element namespace  "http://alpheios.net/namespaces/forms";

(:
  Query to retrieve a frequency-ranked inflection list for a given treebank document
  Form of request is:
    alpheios-infl-freq.xq?urn=<cts urn for the document>&pofs=<pofs>&sort=<inflection|ending>
  where
    urn is the cts urn of the document
    pofs is the part of speech to which to limit the analysis
    sort is the sort key, either 'ending' or 'inflection'
    
  Output Format
      text/xml document in the "http://alpheios.net/namespaces/forms" namespace
      mostly adheres to the alpheios inflection schema -- schema updates pending
      root element is <ending/>, containing a list of grouped 
          <infl-ending-set/> (sort by inflection) or 
          <ending-set/> (sort by ending)             
      HTML transformation is up to the client, the alpheios-infl-freq.xsl stylesheet is specified as a processing instruction          
:)

(: function wich does a deep copy of an inflection instance element, replacing the urn elements
   with a ptr element with the url to retrieve and display the reference in the href attribute
:)
declare function infl:copy_inst($a_id,$a_elem as element()*) as element()*
{
    let $inst :=
        element instance {
        (for $u in ($a_elem/descendant::*:urn)            
            return element ptr {
                attribute href { concat("alpheios-text.xq?urn=", $u) },
                $u
            }
        ),
        $a_elem/descendant::*:infl 
    }
  return $inst
};

(: function which concatonates inflection element values to a string :)  
declare function infl:infl_as_string($a_elem as element()*)
{
          let $infl_char := concat(
              xs:string($a_elem/descendant::*:case),
              xs:string($a_elem/descendant::*:num),
              xs:string($a_elem/descendant::*:gend),
               xs:string($a_elem/descendant::*:voice),
               xs:string($a_elem/descendant::*:mood),
               xs:string($a_elem/descendant::*:tense),
               xs:string($a_elem/descendant::*:pers)
          )
          return $infl_char
};

(:
    Recursive function to group the inflection sets by number of occurrences within a next
    Parameters:
        $a_sort the sort key ('ending' or 'inflection')
        $a_grpText the text on which the sets will be grouped
        $a_set the set of inflection sets grouped so far
        $a_remaining the sequence of inflection sets remaining to be grouped, 
                               sorted by the key defined in $a_sort
    Return Value: the grouped set of elements (forms:infl-ending-set if grouped by inflection
                           or forms:infl-ending if grouped by ending )
:)
declare function infl:group_infls($a_sort as xs:string*,
                                                         $a_grpText as xs:string*, 
                                                         $a_set as element()*, 
                                                         $a_remaining as element()*) as element()*
{
    if ($a_remaining)
        then
            let $infl_count := infl:count_infls($a_sort,$a_remaining[1],xs:integer(1),())
            let $new_set := ($a_set, $infl_count[1])
            let $next := $infl_count[2]           
            return 
            if (($a_sort = 'ending' and 
                  (    (xs:string($next/descendant::*:suff/text()) = $a_grpText) or
                       (not($a_grpText) and not($next/descendant::*:suff/text())) 
                  ))
                  or 
                  ($a_sort != 'ending' and infl:infl_as_string($next) = $a_grpText)
               )
                then 
                    (: there are still inflection sets remaining to be counted, so recurse to count
                        the next set 
                     :)
                    infl:group_infls($a_sort,$a_grpText,$new_set,$next)
                else
                    (: no more sets remaining so return the accumlated grouped set :)
                    $new_set  
        else 
            $a_set
};

(:
  Recursive function to count the number of times an inflection set occurs in a text
  Parameters:
      $a_sort the sort key ('ending' or 'inflection')
      $a_elem the inflection set currently being counted 
      $a_count the number of times the inflection has occurred so far
      $a_refs accumulated set of pointers to the specific occurences of this inflection within the text
   Return Value:
      element with the count specified in @count; element is <forms:infl-ending/> if grouped by
      ending; <forms:infl-ending-set/> if grouped by inflection; pointers to occurences of this inflection
      are included in the <forms:refs/> child element
:)
declare function infl:count_infls($a_sort,$a_elem as element()*,$a_count as xs:integer, $a_refs as element()*) 
{
    let $next := $a_elem/following-sibling::*[1]
    let $refs := ($a_refs,$a_elem/descendant::*:ptr)
    return
    if (not($next) or
         ($next/descendant::*:suff/text() != $a_elem/descendant::*:suff/text()) or
          (infl:infl_as_string($next) != infl:infl_as_string($a_elem))                  
       )
        then (
            (if ($a_sort = 'ending')
            then            
             element infl-ending-set {
                     attribute count { $a_count },                    
                     (for $att in ('case','num','gend','voice','pers','tense','mood')
                         return 
                         if ($a_elem/descendant::*[local-name() = $att])
                         then attribute {$att} { xs:string($a_elem/descendant::*[local-name() = $att]/text()) }
                         else ()
                     ),
                     element refs {$refs }
                 }
                 else
                 element infl-ending {
                     attribute count { $a_count },
                     element refs {$refs },
                      if ($a_elem/descendant::*:suff/text())
                      then $a_elem/descendant::*:suff/text() 
                      else 
                      '-' 
                 }),
                 $next
         )           
        else infl:count_infls($a_sort,$next,$a_count+1,($refs))   
};

import module namespace request="http://exist-db.org/xquery/request";
import module namespace tan="http://alpheios.net/namespaces/text-analysis"
              at "textanalysis-utils.xquery";
declare option exist:serialize "method=xml media-type=text/xml";

let $e_urn := request:get-parameter("urn", ())
let $e_pofs := request:get-parameter('pofs',())
let $e_sort := request:get-parameter('sort',())

let $infl_all := tan:getInflections($e_urn,$e_pofs)

(: sort by ending :)
let $inst := 
<instances>
{
  if ($e_pofs = 'noun' or $e_pofs = 'adjective')            
         then
             if ($e_sort = 'ending')
             then 
                 for $e in $infl_all//*:instance[descendant::*:pofs/text() = $e_pofs]                                     
                 order by 
                      xs:string($e/descendant::*:suff),
                      xs:string($e/descendant::*:case),
                      xs:string($e/descendant::*:num),
                      xs:string($e/descendant::*:gend)    
                  return 
                      infl:($e_urn,$e)
             else            
                 for $e in $infl_all//*:instance[descendant::*:pofs/text() = $e_pofs]
                 order by                 
                      xs:string($e/descendant::*:case),
                      xs:string($e/descendant::*:num),
                      xs:string($e/descendant::*:gend),
                      xs:string($e/descendant::*:suff)
                  return 
                      infl:copy_inst($e_urn,$e)
         else
             if ($e_pofs = 'verb')
             then 
                 if ($e_sort = 'ending')
                then
                     for $e in $infl_all//*:instance[descendant::*:pofs/text() = $e_pofs]
                     order by 
                          xs:string($e/descendant::*:suff),
                          xs:string($e/descendant::*:voice),
                          xs:string($e/descendant::*:mood),
                          xs:string($e/descendant::*:tense),
                          xs:string($e/descendant::*:pers),
                          xs:string($e/descendant::*:num)
                      return infl:copy_inst($e_urn,$e)
                 else
                     for $e in $infl_all//*:instance[descendant::*:pofs/text() = $e_pofs]
                     order by                 
                          xs:string($e/descendant::*:voice),
                          xs:string($e/descendant::*:mood),
                          xs:string($e/descendant::*:tense),
                          xs:string($e/descendant::*:pers),
                          xs:string($e/descendant::*:num),
                           xs:string($e/descendant::*:suff)
                      return infl:copy_inst($e_urn,$e)
            else     
             ()
}             
</instances>

return(
    processing-instruction xml-stylesheet {
     attribute xml {'type="text/xsl" href="../xslt/alpheios-infl-freq.xsl"'}
    },
  <endings lang="{xs:string($infl_all/*:inflection[1]/@xml:lang)}" docid="{$e_urn}" pofs="{$e_pofs}">
       <order-table>
           <order-item attname="pofs" order="1">noun</order-item>
           <order-item attname="pofs" order="2">verb</order-item>
           <order-item attname="pofs" order="3">adjective</order-item>  
       </order-table>
  {                  
      for $i in $inst/*:instance[
          ($e_sort = 'ending' and 
                ((following-sibling::*:instance[1]/descendant::*:suff/text() != descendant::*:suff/text())
                 or (not(descendant::*:suff) and (following-sibling::*:instance[1]/descendant::*:suff or not(following-sibling::*:instance))))                            
          ) or 
          ($e_sort != 'ending' and infl:infl_as_string(following-sibling::*:instance[1]) != infl:infl_as_string(.))
          ]           
          let $infls : = 
              if ($e_sort = 'ending')
              then 
                  if ($i/descendant::*:suff) then $inst/*:instance[descendant::*:suff = $i/descendant::*:suff]
                  else $inst/*:instance[not(descendant::*:suff)]
              else
                  $inst/*:instance[infl:infl_as_string(.) = infl:infl_as_string($i)]
          let $group_text :=
              if ($e_sort = 'ending')                  
              then
                  xs:string($i/descendant::*:suff/text())
              else
                  infl:infl_as_string($i)
          let $grouped_infls := infl:group_infls($e_sort,$group_text,(),$infls)              
      return
          if ($e_sort = 'ending')
          then
          element ending-set {
             attribute count { 
                 count($infls)
             },
            element infl-ending {
               if ($i/descendant::*:suff) then $i/descendant::*:suff /text() else '-'
            },
             $grouped_infls
         }
         else
         element infl-ending-set {
             attribute count { 
                 count($infls)
             },
             (for $att in ('case','num','gend','voice','pers','tense','mood')
                 return 
                     if ($i/descendant::*[local-name() = $att])
                     then attribute {$att} { xs:string($i/descendant::*[local-name() = $att]/text()) }
                 else ()
             ),             
             $grouped_infls
         }
}
</endings>)
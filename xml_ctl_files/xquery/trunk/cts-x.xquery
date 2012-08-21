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
	This module implements the CTS-X API which provides a CRUD interface for working
	with CTS compatible texts.	
:)
module namespace cts-x = "http://alpheios.net/namespaces/cts-x";
import module namespace cts-utils="http://alpheios.net/namespaces/cts-utils" 
            at "cts-utils.xquery";
import module namespace cts="http://alpheios.net/namespaces/cts" 
            at "cts.xquery";
declare namespace ti = "http://chs.harvard.edu/xmlns/cts3/ti";
declare namespace  util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace dc="http://purl.org/dc/elements/1.1";


(:
    CTS-X CreateCitableText request, stores a new text inventory record and
    returns the path at which to put the new citable text
    Parameters:
    	$a_urn the urn of the citable text
    	$a_uuid a unique identifier for the text within the writeable collection
    	$a_inv the source text inventory in which the urn is catalogued
   	Return Value:
   		<create>[Path to store the new text]</create>   
:)
declare function cts-x:createCitableText($a_urn as xs:string, $a_uuid as xs:string, $a_inv as node()) as node() {
    let $collPath := cts-utils:getWriteableCollectionPath()
    let $cts := cts:parseUrn('junk',$a_urn)
    let $tg := $a_inv//ti:textgroup[@projid=$cts/textgroup and ti:work[@projid=$cts/work]]
    let $work := $tg/ti:work[@projid=$cts/work]
    let $edition := $work/ti:*[@projid=$cts/edition]
    let $newinv := 
        <ti:TextInventory>
            {$a_inv//collection,
             <ti:textgroup>
                {$tg/@*, 
                 $tg/node()[local-name() != 'work'],
                <ti:work>
                    {$work/@*,
                     $work/node()[local-name() != 'edition' and local-name() != 'translation'],
                    <ti:edition> 
                        {   $edition/@projid,
                            $edition/ti:label,
                            for $o in $edition/ti:online return
                             <ti:online>{
                                attribute docname { cts-utils:getWriteableTextPath($a_uuid) },
                                $o/@*[local-name() != 'docname'],
                                $o/node()
                             }
                             </ti:online>
                        }
                    </ti:edition>
                    }
                </ti:work>
                }
             </ti:textgroup>
             }
         </ti:TextInventory>
    let $do_store := 
        if (xmldb:collection-available(concat($collPath, '/', $a_uuid))) then true() else
            xmldb:create-collection($collPath, $a_uuid)
    let $inv_stored := xmldb:store(
    	cts-utils:getWriteableInventoryCollectionPath($a_uuid),
    	cts-utils:getWriteableInventoryFilename($a_uuid), 
    	$newinv)
    return if ($inv_stored) then <create>{cts-utils:getWriteableTextPath($a_uuid)}</create> else <error code="102"/>
};

(:
    CTS-X DeleteCitableText request, removes the specified text file and accompanying
    text inventory record.
    Parameters:
    	$a_urn the urn of the citable text
    	$a_uuid a unique identifier for the text within the writeable collection
    	$a_inv the source text inventory in which the urn is catalogued
   	Return Value:
   		<deleted/>   
:)
declare function cts-x:deleteCitableText($a_urn as xs:string, $a_uuid as xs:string, $a_inv as node()) as node() {
	(: NOT YET IMPLEMENTED:)
	<error code="101"/>
};


(:
    CTS-X UpdatePassage request, updates the supplied passage XML
    Parameters:
        $a_inv the inventory name
        $a_urn the passage urn
        $a_replaceWith the replacement node
    Return Value:
        <reply>[Updated Document]</reply>
:)
declare function cts-x:updatePassage($a_inv as xs:string,$a_urn as xs:string,$a_replaceWith as node())
{    
    let $cts := cts:parseUrn($a_inv,$a_urn)    
    return                   
        let $doc := doc($cts/fileInfo/fullPath)
        let $level := count($cts/passageParts/rangePart[1]/part)
        let $entry := cts:getCatalog($a_inv,$a_urn)
        let $tocName := ($entry//ti:online//ti:citation)[position() = $level]/@label
                
        let $cites := for $i in $entry//ti:online//ti:citation return $i        
        let $xpath := cts:replaceBindVariables(
            $cts/passageParts/rangePart[1]/part,
            $cts/passageParts/rangePart[2]/part,
            concat($cites[$level]/@scope, $cites[$level]/@xpath))
        let $passage_orig := util:eval(concat("$doc",$xpath))
        let $subref_orig := 
            if ($cts/subRef)
            then
                cts:findSubRef($passage_orig,$cts/subRef)
            else ()                
        let $passage := if ($passage_orig and (not($cts/subRef) or ($cts/subRef and $subref_orig) )) 
            then $passage_orig
        else            
            let $parent_match := concat("^",$cts/passageParts/rangePart[1]/part[2],"-")
            let $passage_alt  := $doc//div1[@n = $cts/passageParts/rangePart[1]/part[1]]//wd[matches(@tbrefs,$parent_match) or matches(@tbref,$parent_match)][1]/..
            return if ($passage_alt) then $passage_alt else $passage_orig
        (: try again to get the subref :)
        let $subref :=
            if ($subref_orig) then $subref_orig
            else if ($passage and $cts/subRef and not ($subref_orig))
            then cts:findSubRef($passage,$cts/subRef)
            else ()                             
        let $count := count($passage)
        (: For now, only support replacing a single passage at a time :) 
        return 
        	if ($count != 1)
        	then
        		<reply><error code="100">{
        			concat('Single Passage Not Found at ',string($xpath), '(',$count,')')
        		}</error></reply>
        	else       
        		let $name := xs:string(node-name($passage[1]))
        		let $thisPath := xs:string($cites[position() = last()]/@xpath)
        		let $docid := if ($doc/TEI.2/@id) then $doc/TEI.2/@id 
        			  else if ($doc/tei.2/@id) then $doc/tei.2/@id
        			  else if ($doc/TEI/@id) then $doc/TEI/@id
        			  else ""
        		let $replaceWith := util:eval(concat("$a_replaceWith",$xpath))
        		let $replaced := 
                	if ($replaceWith) 
                    then 
						update replace $passage[1] with $replaceWith
					else ()
        		return   
        			if ($replaceWith and deep-equal($passage[1],$replaceWith))
        			then
            			<reply>{doc($cts/fileInfo/fullPath)}</reply>
					else
						<reply><error code="103">{
							concat('Invalid Replacement At ',string($xpath)),
							<data>{$a_replaceWith}</data>,
							<old_psg>{$passage[1]}</old_psg>,
							<new_psg>{$replaceWith}</new_psg>,
							<new_node1>{$a_replaceWith/*[1]}</new_node1>
						}</error></reply>
};
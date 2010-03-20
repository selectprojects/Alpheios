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

(: Beginnings of the CTS Repository Interface Implementation :)

module namespace cts = "http://alpheios.net/namespaces/cts";
declare namespace ti = "http://chs.harvard.edu/xmlns/cts3/ti";
declare namespace  util="http://exist-db.org/xquery/util";

(: 
    function to parse a CTS Urn down to its individual parts
    Parameters: 
        $a_urn: the CTS URN (e.g. urn:cts:greekLit:tlg012.tlg002.alpheios-text-grc1)
    Return value:
        An element adhering to the following 
        <ctsUrn>
            <namespace></namespace>
            <textgroup></textgroup>            
            <work></work>
            <edition></edition>
            <passageParts>
                <part></part>
                <part><part>
            </passageParts>
            <subref position="">
            </subref>
            <fileInfo>
                <basePath></basePath>
                <alpheiosEditionId></alpheiosEditionId>
                <alpheiosDoctype></alpheiosDocType>
            </fileInfo>
        <ctsUrn>
:)
declare function cts:parseUrn($a_urn as xs:string)
{
    let $components := tokenize($a_urn,":")
    let $namespace := $components[3]
    let $workId := $components[4]
    let $workComponents := tokenize($workId,"\.")
    (: TODO do we need to handle the possibility of a work without a text group? :)
    let $textgroup := $workComponents[1]
    let $work := $workComponents[2]
    let $edition := 
        if (count($workComponents) > 2)
        then $workComponents[last()]
        else xs:string("")
    
    let $passage := $components[5]
    let $subref := $components[6]               
    return
        element ctsURN {
            element urn { $a_urn },
            (: urn without any passage specifics:)
            element workUrn { concat("urn:cts:",$namespace,':',$textgroup,".",$work,".",$edition) },            
            element namespace{ $namespace },
            (: TODO is it possible for components of the work id to be in different namespaces?? :)
            element textgroup {concat($namespace,':',$textgroup)},            
            element work {concat($namespace,':',$work)},
            element edition {concat($namespace,':',$edition)},
            element passageParts {
                for $p in tokenize($passage,"\.") 
                return element part { $p }
            },            
            (if ($subref)
            then 
                let $string := substring-before($subref,"[")
                let $pos := replace($subref,"^.*?\[(\d+)\]$","$1")
                return element subRef { attribute position { $pos }, $string } 
            else ()),            
            element fileInfo {                      
                if (starts-with($edition,'alpheios-'))
                then            
                    (: TODO look up the path in the TextInventory :)
                    let $parts := tokenize($edition,'-')                    
                    return
                    (
                        element basePath { 
                            concat("/db/repository/", $namespace, "/", string-join($workComponents[position() != last()] ,"/"))
                        },
                        element fullPath {
                            concat("/db/repository/", $namespace, "/", string-join($workComponents,"/"),".xml")
                        },
                        element alpheiosDocType { $parts[2] },
                        for $i in $parts[position() > 2] return element alpheiosEditionId {$i}
                    )                            
                else ( (: TODO lookup from TextInventory :) )                     
            }
        }
};

(: function to retrieve a subreference from a document
    Parameters:
        $a_urn: the CTS URN
    Return Value:
        the referenced element or the empty sequence if not found
:)
declare function cts:findSubRef($a_urn)
{               
    let $cts := cts:parseUrn($a_urn)
    let $doc := doc($cts/fileInfo/fullPath)
    return $doc//div1[@n = $cts/passageParts/part[1]]//l[@n=$cts/passageParts/part[2]]/wd[text() = $cts/subRef][$cts/subRef/@position]    
};

declare function cts:getPassage($a_inv,$a_urn)
{
    let $cts := cts:parseUrn($a_urn)
    return 
    if ($cts/subRef)
    then 
        cts:findSubRef($a_urn)         
    else
        let $doc := doc($cts/fileInfo/fullPath)
        let $level := count($cts/passageParts/part)
        let $entry := cts:getCatalog($a_inv,$a_urn)
        let $cites := for $i in $entry//ti:online//ti:citation return $i
        let $xpath := cts:replaceBindVariables($cts/passageParts/part,concat($cites[$level]/@scope, $cites[$level]/@xpath))
        return util:eval(concat("$doc",$xpath))        
};

declare function cts:replaceBindVariables($a_parts,$a_path)
{    
        if (count($a_parts) > xs:int(0))
        then             
            let $path := replace($a_path,"^(.*?)\?(.*)$",concat("$1",xs:string($a_parts[1]),"$2"))
            return cts:replaceBindVariables($a_parts[position() > 1],$path)
        else $a_path            
};

declare function cts:getCatalog($a_inv,$a_urn)
{
    let $inv := doc(concat("/db/repository/inventory/",$a_inv,".xml"))
    let $cts := cts:parseUrn($a_urn)
    return $inv//ti:textgroup[@projid=$cts/textgroup]/ti:work[@projid=$cts/work]/ti:*[@projid=$cts/edition]        
};

declare function cts:getCitationXpaths($a_inv,$a_urn)
{
   let $entry := cts:getCatalog($a_inv,$a_urn)
   let $levels :=
       for $i in $entry//ti:online//ti:citation
       return xs:string($i/@xpath)
    return $levels       
};       

declare function cts:getValidReff($a_inv,$a_urn,$a_level)
{        
    let $entry := cts:getCatalog($a_inv,$a_urn)
    let $level := if ($a_level) then $a_level else xs:int(1)
    return ()
};
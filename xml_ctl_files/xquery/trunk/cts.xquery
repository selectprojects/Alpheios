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

(: 
    function to parse a CTS Urn down to its individual parts
    Parameters: 
        $a_urn: the CTS URN (e.g. urn:cts:greekLit:tlg012.tlg002.alpheios-text-grc1)
    Return value:
        An element adhering to the following 
        <ctsUrn>
            <namespace></namespace>
            <work></work>            
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
    let $edition := 
        if (count($workComponents) > 1)
        then $workComponents[last()]
        else xs:string("")
    
    let $passage := $components[5]
    let $subref := $components[6]               
    return
        element ctsURN {
            element namespace{ $namespace },
            element work {$workId },                                   
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

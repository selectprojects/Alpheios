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
(: TODO LIST
            support ranges subreferences
            namespacing on cts responses 
            getPassage
            getValidReff
            typecheck the function parameters and return values
            make getNextPrev recursive so that it can point to first/last in next/previous book, etc.
:)

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
            <workUrn></workUrn>
            <textgroup></textgroup>            
            <work></work>
            <edition></edition>
            <passageParts>
                <rangePart>
                    <part></part>
                    <part><part>
                </rangePart>
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
                for $r in tokenize($passage,"-")                
                return 
                    element rangePart {
                        for $p in tokenize($r,"\.") 
                            return element part { $p }
                    }
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
        <reply>
            <TEI>
                [the referenced element] 
            </TEI>
          </reply>        
:)
declare function cts:findSubRef($a_urn as xs:string)
{               
    let $cts := cts:parseUrn($a_urn)
    let $doc := doc($cts/fileInfo/fullPath)
    let $ref :=   $doc//div1[@n = $cts/passageParts/rangePart[1]/part[1]]//l[
                            @n=$cts/passageParts/rangePart[1]/part[2]]/wd[text() = $cts/subRef][$cts/subRef/@position][1]
    let $lang := $ref/ancestor::*[@lang][1]/@lang
    let $xmllang := $ref/ancestor::*[@xml:lang][1]/@xml:lang
    return
        element reply {
            element TEI {
                attribute xml:lang { if ($xmllang) then $xmllang else $lang },
                $ref
            }   
        }            
};

(:
    get a passage from a text
    Parameters:
        $a_inv the inventory name
        $a_urn the passage urn
    Return Value:
        getPassage reply
:)
declare function cts:getPassage($a_inv as xs:string,$a_urn as xs:string)
{
    (: TODO :)
    ()
};

(:
    CTS getValidReff request
:)
declare function cts:getValidReff($a_inv,$a_urn,$a_level)
{   
    (:TO DO:)
    ()
};

(:
    find the next/previous urns
    Parameters:
        $a_dir direction ('p' for previous, 'n' for next)
        $a_node the node from which to start
        $a_path the xpath template for the referenced passage
        $a_count the number of nodes in the referenced passage
        $a_urn the work urn
        $a_passageParts the passageParts elementes from the parsed urn (see cts:parseUrn)
    Return Value:
        the urn of the the next or previous reference
        if the referenced passage was a range, the urn will be a range of no more than the number of nodes
        in the referenced range
:)
declare function cts:findNextPrev($a_dir as xs:string,
                                                    $a_node as node(),
                                                    $a_path as xs:string ,
                                                    $a_count as xs:int ,
                                                    $a_urn as xs:string,
                                                    $a_passageParts as node()*) as xs:string
{
    let $kind := xs:string(node-name($a_node))    
    let $name := replace($a_path,"^/(.*?)\[.*$","$1")
    let $pred := replace($a_path,"^.*?\[(.*?)\].*$","$1")
    (: remove the identifier bind variable from the path :)
    let $path := replace($pred,"^@[^=]+=.\?.$","")
    (: get the identifier bind variable :)
    let $id := replace($pred,"^.*?@([^=]+)=.\?.+$","$1")          
    let $next :=                   
        if ($path) 
        then
            (: apply additional non-id predicates in xpath :)
            (: TODO check the context of the util:eval($path) here :)
            if ($a_dir = xs:string('p'))
            then 
                $a_node/preceding-sibling::*[name() = $kind and util:eval($path)][1]
            else                 
                $a_node/following-sibling::*[name() = $kind and util:eval($path)][1]
        else
            if ($a_dir = xs:string('p'))
            then
                $a_node/preceding-sibling::*[name() = $kind]
            else                 
                $a_node/following-sibling::*[name() = $kind]
    return 
        if ($next) 
        then
            let $end := if (count($next) > $a_count) then $a_count else count($next)
            let $passagePrefix := string-join($a_passageParts[position() != last()],".") 
            let $rangeStart := concat($passagePrefix,".",xs:string($next[1]/@*[name() = $id]))
            let $rangeEnd := 
                if ($end > xs:int("1")) 
                then concat("-",$passagePrefix,".",xs:string($next[position() = $end]/@*[name() = $id]))
                else ""
            return concat($a_urn,":",$rangeStart,$rangeEnd)
        (:TODO recurse up the path to find the next node of this kind in the next parent node :)
        else ""               
};

(:
    CTS getPassagePlus request, returns the requested passage plus previous/next references
    Parameters:
        $a_inv the inventory name
        $a_urn the passage urn
    Return Value:
        <reply>
            <TEI>
               [ passage elements ]
            </TEI>
        </reply>
        <prevnext>
            <prev>[previous urn]</prev>
            <next>[next urn]</next>
        </prevnext>
:)
declare function cts:getPassagePlus($a_inv as xs:string,$a_urn as xs:string)
{
    let $cts := cts:parseUrn($a_urn)
    return 
    if ($cts/subRef)
    then 
        cts:findSubRef($a_urn)         
    else
        let $doc := doc($cts/fileInfo/fullPath)
        let $level := count($cts/passageParts/rangePart[1]/part)
        let $entry := cts:getCatalog($a_inv,$a_urn)
        let $cites := for $i in $entry//ti:online//ti:citation return $i        
        let $xpath := cts:replaceBindVariables($cts/passageParts/rangePart[1]/part,$cts/passageParts/rangePart[2]/part,concat($cites[$level]/@scope, $cites[$level]/@xpath))
        let $passage := util:eval(concat("$doc",$xpath))
        let $xmllang := $passage[1]/ancestor::*[@xml:lang][1]/@xml:lang
        let $lang := $passage[1]/ancestor::*[@lang][1]/@lang
        let $count := count($passage)
        let $name := xs:string(node-name($passage[1]))
        let $thisPath := xs:string($cites[position() = last()]/@xpath)
        return
            <reply>
                <TEI xml:lang="{if ($xmllang) then $xmllang else $lang}">
                    {$passage}
                </TEI>
                <prevnext>
                    <prev>{ cts:findNextPrev("p",$passage[1],$thisPath,$count,$cts/workUrn,$cts/passageParts/rangePart[1]/part) }</prev>                    
                    <next>{ cts:findNextPrev("n",$passage[position() = last()],$thisPath,$count,$cts/workUrn,$cts/passageParts/rangePart[position()=last()]/part) }</next>
                </prevnext>
            </reply>                    
};

(:
    replace bind variables in the template xpath from the TextInvetory with the requested values
    Parameters
        $a_startParts the passage parts identifiers of the start of the range
        $a_endParts the passage part identifiers of the end of the range
        $a_path the template xpath containing the bind variables 
    Return Value
        the path with the bind variables replaced
:)
declare function cts:replaceBindVariables($a_startParts,$a_endParts,$a_path) as xs:string
{    
        
        if (count($a_startParts) > xs:int(0))
        then
            if (count($a_endParts) > xs:int(0)) then
                let $startRange := concat(" >= ",$a_startParts[1])
                let $endRange := concat(" <= ", $a_endParts[1])
                let $path := replace($a_path,"^(.*?)(@[\w\d\._:\s])=[""']\?[""'](.*)$",concat("$1","$2",$startRange," and ", "$2", $endRange, "$3"))                
                return cts:replaceBindVariables($a_startParts[position() > 1],$a_endParts[position() >1],$path)
            else 
                let $path := replace($a_path,"^(.*?)\?(.*)$",concat("$1",xs:string($a_startParts[1]),"$2"))
                return cts:replaceBindVariables($a_startParts[position() > 1],(),$path)
        else $a_path            
};

(:
    get a catalog entry for an edition 
    Parameters:
        $a_inv the inventory 
        $a_urn the document/passage urn
    Return Value
        the catalog entry for the requested edition
:)
declare function cts:getCatalog($a_inv as xs:string,$a_urn as xs:string) as node()*
{
    let $inv := doc(concat("/db/repository/inventory/",$a_inv,".xml"))
    let $cts := cts:parseUrn($a_urn)
    return $inv//ti:textgroup[@projid=$cts/textgroup]/ti:work[@projid=$cts/work]/ti:*[@projid=$cts/edition]        
};

(:
    get the citation xpaths for a urn
    Parameters:
        $a_inv the inventory 
        $a_urn the document/passage urn
     Return Value
         a sequence of strings containing the citation xpaths
:)
declare function cts:getCitationXpaths($a_inv as xs:string,$a_urn as xs:string)
{
   let $entry := cts:getCatalog($a_inv,$a_urn)
   let $levels :=
       for $i in $entry//ti:online//ti:citation
       return xs:string($i/@xpath)
    return $levels       
};       


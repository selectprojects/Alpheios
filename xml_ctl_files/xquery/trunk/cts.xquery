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

declare variable $cts:tocChunking :=
( 
    <tocCunk type="Book" size="1"/>,
    <tocChunk type="Line" size="100"/>,
    <tocChunk type="Verse" size="100"/>,
    <tocChunk type="Page" size="1"/>
);

declare variable $cts:maxPassageNodes := 100;

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
                else 
                    if (not($edition))
                    then 
                        element basePath { 
                            concat("/db/repository/", $namespace, "/", string-join($workComponents,"/"))
                        }                      
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
                    $doc//teiHeader,
                    <text xml:lang="{if ($xmllang) then $xmllang else $lang}">
                        <body>
                                {$ref}
                        </body>
                    </text>                    
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
    CTS getCapabilities request
    Parameters:
        $a_inv the inventory         
    Return Value
        the catalog entry for the requested edition
:)
declare function cts:getCapabilities($a_inv)
{    
    let $inv := doc(concat("/db/repository/inventory/",$a_inv,".xml"))
    return 
        <reply>{$inv}</reply>
};

(:
    CTS getValidReff request (unspecified level)
    Parameters:
        $a_inv the inventory name
        $a_urn the passage urn        
    Returns 
        the list of valid urns
:)
declare function cts:getValidReff($a_inv,$a_urn)
{    
    let $cts := cts:parseUrn($a_urn)
    let $doc := doc($cts/fileInfo/fullPath)
    let $entry := cts:getCatalog($a_inv,$a_urn)
    let $parts := count($cts/passageParts/rangePart[1]/part)
    (: if one or more parts of the passage component are specified, the level is implicitly
       the next level after the one supplied, otherwise retrieve all levels 
    :)   
    let $level := 
        if ($parts) then $parts+1 else count($entry//ti:online//ti:citation)
    return cts:getValidReff($a_inv,$a_urn,$level)                
};

(:
    CTS getValidReff request (with level)
    Parameters:
        $a_inv the inventory name
        $a_urn the passage urn
        $a_level citation level
    Returns 
        the list of valid urns
:)
declare function cts:getValidReff($a_inv as xs:string,$a_urn as xs:string,$a_level as xs:int)
{    
        let $cts := cts:parseUrn($a_urn)
        let $doc := doc($cts/fileInfo/fullPath)
        let $entry := cts:getCatalog($a_inv,$a_urn)                
        let $cites := for $i in ($entry//ti:online//ti:citation)[position() <= $a_level] return $i
        let $startParts :=
            for $l in (xs:int("1") to $a_level)
            return 
                if ($cts/passageParts/rangePart[1]/part[$l]) 
                then $cts/passageParts/rangePart[1]/part[$l] else <part></part>
        let $endParts :=
            if ($cts/passageParts/rangePart[2]) then
                for $l in (xs:int("1") to $a_level)
                return 
                    if ($cts/passageParts/rangePart[2]/part[$l]) 
                    then $cts/passageParts/rangePart[2]/part[$l] else <part></part>
            else ()
        
        let $urns := cts:getUrns($startParts,$endParts,$cites,$doc,concat($cts/workUrn,":"))
        return 
        <reply>
            <reff>
                    { for $u in $urns return <urn>{$u}</urn> }
            </reff>
        </reply>
};    

(:
        Recursive function to expands the urns returned by getValidReff into a TEI-compliant list, 
        starting at the supplied level, with the node containing the supplied urn expanded to the level
        of the requested urn
        Parameters:
            $a_inv the inventory name
            $a_urn the requested urn
            $a_level the starting level
         Returns the hierarchy of references as a TEI-compliant <list/>
:)
declare function cts:expandValidReffs($a_inv as xs:string,$a_urn as xs:string,$a_level as xs:int)
{
    (: TODO address situation where lines are missing ? e.g. line 9.458 Iliad :)
    let $entry := cts:getCatalog($a_inv,$a_urn)    
    let $workUrn := if ($a_level = xs:int("1")) then cts:parseUrn($a_urn)/workUrn else $a_urn
    let $urns := cts:getValidReff($a_inv,$workUrn,$a_level)
    let $numLevels := count($entry//ti:online//ti:citation)
    let $numUrns := count($urns//urn) 
    let $tocName := ($entry//ti:online//ti:citation)[position() = $a_level]/@label
    let $chunkSize := xs:int($cts:tocChunking[@type=$tocName]/@size) 
    return
                <list> {
                for $i in (xs:int("1") to $numUrns)
                    return
                    if (($i + $chunkSize - 1) mod $chunkSize != xs:int("0")) 
                    then ()
                    else 
                        let $u := $urns//urn[$i] 
                        let $focus := $u eq $a_urn
                        let $last := 
                            if ($chunkSize > xs:int("1") )
                            then 
                                if ($urns//urn[($i + $chunkSize - 1)]) then $urns//urn[($i + $chunkSize - 1)] else $urns//urn[last()]
                            else()
                        let $parsed :=  cts:parseUrn($u)
                        let $endParsed := if ($last) then cts:parseUrn($last) else ()
                        let $startPart := $parsed/passageParts/rangePart[1]/part[last()]
                        let $endPart := if ($endParsed) then concat("-",$endParsed/passageParts/rangePart[1]/part[last()]) else ""
                        let $urn := 
                            if ($last) 
                            then 
                                concat(
                                    $parsed/workUrn,":",
                                    string-join($parsed/passageParts/rangePart[1]/part,"."),"-", 
                                    string-join($endParsed/passageParts/rangePart[1]/part,"."))
                            else
                                $u
                        let $href := 
                            if ($a_level = $numLevels) 
                            then
                                concat("alpheios-get-ref.xq?urn=",$urn)
                            else
                                 concat("alpheios-get-toc.xq?urn=",$urn,"&amp;level=",$a_level+1)                        
                        let $ptrType := if ($a_level = $numLevels) then 'text' else 'toc'                                
                        return                
                            <item>
                                {concat($tocName," ",$startPart,$endPart)}                                                         
                                <tei:ptr target="{$href}" xmlns:tei="http://www.tei-c.org/ns/1.0" rend="{$ptrType}"/>                          
                              {if (not($focus) and contains($a_urn,$u)) then cts:expandValidReffs($a_inv,$u,$a_level + 1)  else ()}
                            </item>
                }</list>                        
                                       
};

(:
    Recursive function to get the list of valid urns for a getValidReff request
    Parameters:   
        $a_startParts the parts of the starting passage range
        $a_endParts the parents of the ending passage range
        $a_cites the citation elements to retrieve
        $a_doc the target document
        $a_urn the base urn
    (: TODO does not support range requests properly :)        
:)
declare function cts:getUrns($a_startParts,$a_endParts,$a_cites,$a_doc,$a_urn)
{    
    let $cite := $a_cites[1]
    let $xpath := cts:replaceBindVariables(
        $a_startParts,
        $a_endParts,
        concat($cite/@scope, $cite/@xpath))                
    
    let $passage := util:eval(concat("$a_doc",$xpath))
    let $pred := replace($cite/@xpath,"^.*?\[(.*?)\].*$","$1")
    (: get the identifier bind variable :)    
    let $id := replace($pred,"^.*?@([^=]+)=.\?.+$","$1")              
    for $p in $passage
        let $id_value := xs:string($p/@*[name() = $id])
        let $urn := concat($a_urn,$id_value)        
        return        
            if(count($a_cites) > xs:int(1))
            then
                let $next_cites := $a_cites[position() > xs:int(1)]
                return cts:getUrns(
                    $a_startParts,$a_endParts,$next_cites,$a_doc,concat($urn,"."))
            else        
                $urn   
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
        let $tocName := ($entry//ti:online//ti:citation)[position() = $level]/@label
        let $chunkSize := xs:int($cts:tocChunking[@type=$tocName]/@size)
        
        
        let $cites := for $i in $entry//ti:online//ti:citation return $i        
        let $xpath := cts:replaceBindVariables(
            $cts/passageParts/rangePart[1]/part,
            $cts/passageParts/rangePart[2]/part,
            concat($cites[$level]/@scope, $cites[$level]/@xpath))
        let $passage := 
            (: return error if we can't determine the chunk size :)
           if (not($chunkSize)) then (<l rend="error">Invalid Request</l>)
           else util:eval(concat("$doc",$xpath))
        let $xmllang := $passage[1]/ancestor::*[@xml:lang][1]/@xml:lang
        let $lang := $passage[1]/ancestor::*[@lang][1]/@lang
        let $countAll := count($passage)
        (: enforce limit on # of nodes returned to avoid crashing the server or browser :)
        let $count := if ($countAll > $cts:maxPassageNodes) then $cts:maxPassageNodes else $countAll        
        let $name := xs:string(node-name($passage[1]))
        let $thisPath := xs:string($cites[position() = last()]/@xpath)
        return   
            <reply>
                <TEI>
                    {$doc//teiHeader},
                    <text xml:lang="{if ($xmllang) then $xmllang else $lang}">
                    <body>
                        {$passage[position() < $count+ 1]}
                     </body>
                  </text>
                </TEI>
                { if ($chunkSize) then
                    <prevnext>                     
                        <prev>{ cts:findNextPrev("p",$passage[1],$thisPath,$count,$cts/workUrn,$cts/passageParts/rangePart[1]/part) }</prev>                    
                        <next>{ cts:findNextPrev("n",$passage[position() = last()],$thisPath,$count,$cts/workUrn,$cts/passageParts/rangePart[position()=last()]/part) }</next>                                            
                    </prevnext>
                    else ()
                }
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
                let $startRange := if ($a_startParts[1]/text()) then concat(" >= ",$a_startParts[1]) else ""
                let $endRange := if ($a_endParts[1]/text()) then concat(" <= ", $a_endParts[1]) else ""
                let $path := replace($a_path,"^(.*?)(@[\w\d\._:\s])=[""']\?[""'](.*)$",concat("$1","$2",$startRange," and ", "$2", $endRange, "$3"))                
                return cts:replaceBindVariables($a_startParts[position() > 1],$a_endParts[position() >1],$path)
            else          
                let $path := 
                    if ($a_startParts[1]/text()) 
                    then 
                        replace($a_path,"^(.*?)\?(.*)$",concat("$1",xs:string($a_startParts[1]),"$2"))
                    else 
                        replace($a_path,"^(.*?)(@[\w\d\._:\s])=[""']\?[""'](.*)$",concat("$1","$2","$3"))
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

(:
    Get the document for the supplied urn
    Parameters
        $a_urn the urn
    Return Value
        the document
:)
declare function cts:getDoc($a_urn as xs:string)
{
    let $cts := cts:parseUrn($a_urn)
    return doc($cts/fileInfo/fullPath)
};

(:
    Get the title of the edition represented by the supplied urn
    Parameters
        $a_inv the text inventory
        $a_urn the urn
    Return Value
        the title
:)
declare function cts:getEditionTitle($a_inv as xs:string,$a_urn as xs:string)
{
    let $entry := cts:getCatalog($a_inv,$a_urn)
    return xs:string($entry//ti:edition/ti:label)
};

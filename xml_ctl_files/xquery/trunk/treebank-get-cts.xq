(:
  Copyright 2009 Cantus Foundation
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
  Query to retrieve data from treebank

  Form of request is:
    .../tb-get.xq?f=<file>&n=<id>
  where
    f is the base file name (without path or extensions)
    n is either sentence id or word id (<sentence#>-<word#>)
 :)

import module namespace cts="http://alpheios.net/namespaces/cts" 
            at "cts.xquery";
import module namespace tan  = "http://alpheios.net/namespaces/text-analysis"
            at "textanalysis-utils.xquery";

import module namespace request="http://exist-db.org/xquery/request";
declare copy-namespaces preserve, inherit;
declare option exist:serialize "method=xml media-type=text/xml encoding=UTF-8 omit-xml-declaration=yes";


declare function local:getPath($a_node as node(),$a_stop as xs:string, $a_build as xs:string*) as xs:string*
{
	if (name($a_node) = $a_stop)
	then $a_build
	else if ($a_node/@n)
	then 
		let $new_build := if ($a_build) then ($a_build,xs:string($a_node/@n)) else xs:string($a_node/@n)
		return local:getPath($a_node/parent::*,$a_stop,$new_build)
	else			
		local:getPath($a_node/parent::*,$a_stop,$a_build)
};

let $e_urn := request:get-parameter("urn", ())
let $cts := cts:parseUrn($e_urn)
let $as_feed := request:get-parameter("feed", ())
let $nodes := 
    if ($cts/passageParts/rangePart) then cts:getPassagePlus("alpheios-cts-inventory",$e_urn) else cts:getCitableText("alpheios-cts-inventory",$e_urn)
let $request_uri := request:get-url()
let $base_uri := substring-before($request_uri,"treebank-get-cts")
let $docinfo := tan:findDocs($cts)
let $tbDoc := $docinfo/treebank
return 
    if ($tbDoc) 
    then
        let $index_items :=
        	for $node in $nodes/TEI/text/body//*[wd]	
        		let $parents := reverse(local:getPath($node,'body',""))
        		let $docid := $nodes/TEI/@id		
        		let $urn := concat($cts/workNoEdUrn,':',string-join($parents,'.'))
        		let $refs :=
        		  (: if a subref was requested, return individual word refs otherwise just the sentences :)
        		  if ($cts/subRef) 
        		      then ($node/wd/@tbref,$node/wd/@tbrefs)
        		      else distinct-values( 
        		          for $r in ($node/wd/@tbref,$node/wd/@tbrefs) return substring-before($r,"-"))        		                         	
    	       for $ref in distinct-values(tokenize($refs,' ')) order by $ref return
    				<entry urn="{$urn}" tbdoc="{$docid}" tbref="{$ref}"/>								
        return 
            if ($as_feed) 
                then
          		    <feed xmlns="http://www.w3.org/2005/Atom">
            			<link href="{$base_uri}"/>
            			<title>{concat("Treebank Feed for ",$e_urn)}</title>
            			{
               			  for $entry in $index_items
               			   return 
               			    <entry xmlns="http://www.w3.org/2005/Atom">
               			        <id>{$entry/@urn}</id>
               			        <title>{$entry/@urn}</title>
               			        <link href="{concat($base_uri,'treebank-get.xq?f=',$entry/@tbdoc,"&amp;n=",$entry/@tbref)}"/>
               			    </entry>
               			    
               			    
          	  		     }
          		    </feed>		
          	else
          	     let $tb := doc($tbDoc)
          	     return
          	         element treebank {
          	             $tb/treebank/@*,          	             
          	             $tb/treebank/*[local-name(.) != 'sentence'],
          	             for $id in distinct-values($index_items/@tbref)          	                 
          	                 let $sentence-id :=
                                if (contains($id, "-")) then substring-before($id, "-") else $id
                             let $word-id :=
                                if (contains($id, "-")) then substring-after($id, "-") else ()
                                let $sentence := $tb//sentence[@id = $sentence-id]
                                return
                                if ($sentence)
                                then
                                  if ($word-id)
                                  then
                                    let $word := $sentence/word[@id = $word-id]
                                    return
                                    if ($word)
                                    then
                                      $word
                                    else
                                      element error
                                      {
                                        concat("Word number ", $id, " not found")
                                      }
                                  else
                                    $sentence           
                              else
                                element error
                                    {
                                      concat("Sentence number ", $sentence-id, " not found")
                                    }
          	         }          	               	     
    else
        <error>No Treebank Available for {$e_urn}</error>

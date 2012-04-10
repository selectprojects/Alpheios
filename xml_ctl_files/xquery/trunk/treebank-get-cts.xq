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
let $request_uri := request:get-url()
let $base_uri := substring-before($request_uri,"treebank-get-cts")
let $docinfo := tan:findDocs($cts)
let $tbDoc := $docinfo/treebank
let $tbRefs := tan:getTreebankRefs($cts,false()) 

return doc($tbRefs)     	               	     

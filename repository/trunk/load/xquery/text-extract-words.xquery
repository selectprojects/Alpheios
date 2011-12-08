(:
  Copyright 2008-2009 Cantus Foundation
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

import module namespace cts="http://alpheios.net/namespaces/cts" 
    at "xmldb:exist://localhost:8080/exist/xmlrpc/db/xq/cts.xquery";
import module namespace transform="http://exist-db.org/xquery/transform";
declare namespace  util="http://exist-db.org/xquery/util";


declare variable $e_inv external;
declare variable $e_urn external;
declare variable $e_source external;
declare variable $e_morphEncoding external;


let $passage_xpaths := cts:getCitationXpaths($e_inv,$e_urn)

let $textDoc := doc($e_source)
return element words {
	attribute source {$e_source},
	$passage_xpaths,	
    for $i in $textDoc//*:wd
    return      
      let $passage :=
            for $p in $passage_xpaths
                let $name := replace($p,"^/(.*?:)?(.*?)\[.*$","$2")
                let $pred := replace($p,"^.*?\[(.*?)\].*$","$1")
                let $path := replace($pred,"^@[^=]+=.\?.$","")
                let $id := replace($pred,"^.*?@([^=]+)=.\?.+$","$1")
                let $parent := if ($path) then $i/ancestor::*[local-name() = $name and util:eval($path)] else $i/ancestor::*[local-name() = $name]
                return 
                    if ($parent) then xs:string($parent/@*[name() = $id]) else $path
        let $word := $i/text()
        let $position := count($i/preceding-sibling::*:wd[text() = $word]) + 1
        let $clean := 
            if ($e_morphEncoding = "beta") 
            then 
                let $xsl := doc('/db/xslt/alpheios-uni2betacode.xsl')
                let $params := <parameters><param name="e_in" value="{$word}"/></parameters>
                let $dummy := <dummy/>
                let $temp := transform:transform($dummy, $xsl, $params)
                return $temp
            else if ($e_morphEncoding = "ara")
            then
                let $xsl := doc('/db/xslt/alpheios-uni2buck.xsl')
                let $params := <parameters><param name="e_in" value="{$word}"/></parameters>
                let $dummy := <dummy/>
                let $temp := transform:transform($dummy, $xsl, $params)
                return $temp
            else $word
        return concat(
            concat($e_urn,":",string-join($passage,"."),":",$word,"[",$position,"]"),",",$word,",",$clean)
}            


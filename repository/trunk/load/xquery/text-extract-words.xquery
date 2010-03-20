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
              at "file:///c://work/xml_ctl_files/xquery/trunk/cts.xquery";
declare namespace  util="http://exist-db.org/xquery/util";

declare variable $e_inv external;
declare variable $e_urn external;
declare variable $e_source external;



let $passage_xpaths := cts:getCitationXpaths($e_inv,$e_urn)

let $textDoc := doc($e_source)
return element words {
    for $i in $textDoc//wd
    return
      let $passage :=
            for $p in $passage_xpaths
                let $name := replace($p,"^/(.*?)\[.*$","$1")
                let $pred := replace($p,"^.*?\[(.*?)\].*$","$1")
                let $path := replace($pred,"^@[^=]+=.\?.$","")
                let $id := replace($pred,"^.*?@([^=]+)=.\?.+$","$1")
                let $parent := if ($path) then $i/ancestor::*[name() = $name and util:eval($path)] else $i/ancestor::*[name() = $name]
                return 
                    if ($parent) then xs:string($parent/@*[name() = $id]) else $path
        let $word := $i/text()
        let $position := count($i/preceding-sibling::wd[text() = $word]) + 1
        return concat(
            concat($e_urn,":",string-join($passage,"."),":",$word,"[",$position,"]"),",",$word,",",$i/@beta)
}            


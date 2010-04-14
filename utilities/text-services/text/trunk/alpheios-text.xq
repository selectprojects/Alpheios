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

(:
  Query to display an Alpheios enhanced text passage
    Form of request is:
    alpheios-text.xq?urn=<cts urn>
  where
    urn is the CTS urn for the requested passage
    
  Output Format  XHTML (Alpheios Enhanced Text display)  
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace transform="http://exist-db.org/xquery/transform";
import module namespace cts="http://alpheios.net/namespaces/cts" 
            at "cts.xquery";
import module namespace tan="http://alpheios.net/namespaces/text-analysis"
              at "textanalysis-utils.xquery";
declare option exist:serialize "method=xhtml media-type=text/html";

let $e_urn :=  request:get-parameter("urn",())
let $baseUrl := concat("http://",request:get-server-name(),":",request:get-server-port(),"/exist/rest/db/xq/")
let $title := cts:getEditionTitle("alpheios-cts-inventory",$e_urn)
return
<html>
    <title>{$title}</title>
    <frameset cols="25%,75%">
        <frame id="alpheios-toc-frame" src="{concat($baseUrl,"alpheios-get-toc.xq?urn=",$e_urn)}"/>
        <frame id="alpheios-text-frame" src="{concat($baseUrl,"alpheios-get-ref.xq?urn=",$e_urn)}"/>
    </frameset>        
</html>


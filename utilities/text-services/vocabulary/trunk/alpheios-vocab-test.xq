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


import module namespace cts="http://alpheios.net/namespaces/cts" 
            at "cts.xquery";
declare namespace ti = "http://chs.harvard.edu/xmlns/cts3/ti";

declare option exist:serialize "method=xml media-type=text/xml";

let $pi := 
        processing-instruction xml-stylesheet {
             attribute xml { 'type="text/xsl" href="../xslt/inv-to-vocab.xsl"'}
        }
return 
($pi,
cts:getCapabilities("alpheios-cts-inventory"))
(:
  Copyright 2010 The Alpheios Project, Ltd.
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

let $e_query := request:get-parameter("request",())
let $e_urn :=  request:get-parameter("urn",())
let $e_level := xs:int(request:get-parameter("level","1"))
let $inv := "alpheios-cts-inventory"

return
if ($e_query = 'GetValidReff')
then cts:getValidReff($inv,$e_urn,$e_level)
else if ($e_query = 'ExpandValidReffs')
then cts:expandValidReffs($inv,$e_urn,$e_level)
else if ($e_query = 'GetCapabilities')
then cts:getCapabilities($inv)
else if ($e_query = 'GetExpandedTitle')
then cts:getExpandedTitle($inv,$e_urn)
else if ($e_query = 'GetPassagePlus')
then cts:getPassagePlus($inv,$e_urn)
else if ($e_query = 'GetCitableText')
then cts:getCitableText($inv,$e_urn)
else(<reply></reply>)







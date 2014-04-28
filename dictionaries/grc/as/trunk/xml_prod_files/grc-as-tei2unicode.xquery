(:
  Copyright 2014 Alpheios Project, Ltd.
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

(: convert TEI version of Abbott-Smith to version with no namespace :)

declare namespace tei = "http://www.crosswire.org/2008/TEIOSIS/namespace";

declare variable $e_docname external;

declare function local:remove-namespace($nodes)
{
  for $node in $nodes
  return
    if ($node instance of element())
    then
      element { fn:local-name($node) }
      {
        $node/@*,
        local:remove-namespace($node/node())
      }
    else $node
};

let $doc := fn:doc($e_docname)/tei:TEI

let $newdoc :=
element abbott-smith
{
  $doc/tei:teiHeader,
  for $entry at $i in $doc//tei:entry
  let $keyParts := fn:tokenize($entry/@n, "\|")
  return
    element entry
    {
      attribute key { $keyParts[1] },
      attribute id { $i },
      $entry/@n,
      $entry/*
    }
}

return local:remove-namespace($newdoc)
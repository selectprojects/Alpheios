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
  Get lexicon info from AGME Spanish word list

  Form of request is:
    .../morph-esp-agme.xq?w=<wd>
  where
    w is the word to find

  Output is returned as XML in the lexicon format.
 :)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace magme="http://alpheios.net/namespaces/morph-esp-agme"
              at "morph-esp-agme.xquery";
declare option exist:serialize "method=xml media-type=text/xml";

let $form := request:get-parameter("w", ())[1]

return
  if (not($form))
  then
    element error { "Word not specified" }
  else
    magme:get-entry($form)
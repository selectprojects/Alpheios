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
  Convert SVG to XML alignment format and save
 :)

module namespace alsv="http://alpheios.net/namespaces/align-save";
import module namespace alut="http://alpheios.net/namespaces/align-util"
              at "align-util.xquery";

(:
  Function to save SVG in alignment document

  Parameters:
    $a_data        SVG data

  Return value:
    HTML page with status/error
 :)
declare function alsv:save-sentence(
  $a_data as element()?) as element()?
{
  if ($a_data)
  then
    let $docStem := $a_data/@alph-doc
    let $docName := concat("/db/repository/alignment/", $docStem, ".xml")
    let $sentId := $a_data/@alph-sentid
    let $doc := doc($docName)
    let $oldSent := subsequence($doc//sentence, $sentId, 1)
    return
    if ($oldSent)
    then
      let $newSent := alut:svg-to-xml($a_data)
      return
      if ($newSent)
      then
        let $empty := update value $oldSent with $newSent/*
        return
          <message>Sentence saved</message>
      else
        <error>Error converting sentence</error>
    else
      <error>Error retrieving sentence to update</error>
  else
    <error>No data found</error>
};

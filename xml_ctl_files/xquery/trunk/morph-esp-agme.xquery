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
  Get lexicon info from AGME Spanish word list and Spanish/English definitions
 :)

module namespace magme="http://alpheios.net/namespaces/morph-esp-agme";

(:
  Function to find distinct items (hopefully faster than distinct-values())

  Parameters:
    $a_todo         items left to check
    $a_found        distinct items already found

  Return value:
    $a_found plus any values from $a_todo not already in $a_found

  Called initially with distinct-items(items, ()) 
 :)
declare function local:distinct-items(
  $a_todo as item()*,
  $a_found as item()*) as item()*
{
  (: if nothing left to do, return what's been found :)
  if (count($a_todo) eq 0)
  then
    $a_found
  else
    (:
      otherwise, eliminate first item from todo list
      and add it to found list if not already there
     :)
    local:distinct-items(
      subsequence($a_todo, 2),
      ($a_found, if ($a_todo[1] = $a_found) then () else $a_todo[1]))
};

(:
  Function to get morphology for given form

  Parameters:
    $a_form        form to get

  Return value:
    element conforming to Alpheios lexicon schema if form is found
    else unknown element
 :)
declare function magme:get-entry($a_form as xs:string) as element()?
{
  let $langAttr := attribute xml:lang { "esp" }

  (:
    get all wordlist entries with specified form and
    definitions for all lemmas in those entries
   :)
  let $base := "/db/lexica/esp"
  let $formEntries := collection(concat($base, "/agme"))/wds/w[f eq $a_form]
  let $defs := doc(concat($base, "/defs/esp-eng.xml"))

  return
  if (count($formEntries) > 0)
  then
  element words
  {
    element word
    {
      element form
      {
        $langAttr,
        $a_form
      },
      (: for each distinct lemma/part-of-speech combination :)
      for $lemma in local:distinct-items($formEntries/l, ())
      let $lemmaEntries := $formEntries[l eq $lemma]
      let $meaning :=
        let $lemmaDefs := $defs/wds/w[l eq $lemma]
        return
          if ($lemmaDefs)
          then
            element mean
            {
              $lemmaDefs/d/text()
            }
          else ()
      for $pofs in local:distinct-items($lemmaEntries/m/@p, ())
      let $entries := $lemmaEntries[m/@p eq $pofs]
      return
      element entry
      {
        element dict
        {
          element hdwd
          {
            $langAttr,
            $lemma
          },
          ($entries/infl/pofs)[1]
        },
        $meaning,
        for $entry in $entries
        return
          $entry/infl
      }
    }
  }
  else
  element unknown
  {
    $a_form
  }
};
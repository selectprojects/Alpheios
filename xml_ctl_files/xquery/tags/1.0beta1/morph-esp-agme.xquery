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
  $a_todo as xdt:anyAtomicType*,
  $a_found as xdt:anyAtomicType*) as xdt:anyAtomicType*
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
    $a_form         form to get
    $a_morphology   form-to-morphology entries
    $a_meanings     lemma-to-meaning entries

  Return value:
    element conforming to Alpheios lexicon schema if form is found
    else unknown element
 :)
declare function magme:get-entry(
  $a_form as xs:string,
  $a_morphology as node()*,
  $a_meanings as node()*) as element()?
{
  let $langAttr := attribute xml:lang { "esp" }

  (:
    get all wordlist entries with specified form
   :)
  let $formEntries := $a_morphology/wds/w[f eq $a_form]
  let $altForm :=
    (: if nothing found with original form :)
    if (not($formEntries))
    then
      (: try lower case or, if already lower, initial capital :)
      if (lower-case($a_form) != $a_form)
      then
        lower-case($a_form)
      else
        concat(upper-case(substring($a_form, 1, 1)),
               substring($a_form, 2))
    else
      $a_form
  let $formEntries :=
    (: if alternate form needed, try it :)
    if ($altForm != $a_form)
    then
      $a_morphology/wds/w[f eq lower-case($a_form)]
    else
      $formEntries

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
      (: Note: $formEntries/l does not work reliably in eXist :)
      for $lemma in
            local:distinct-items(for $e in $formEntries return $e/l, ())
      let $lemmaEntries := $formEntries[l eq $lemma]
      let $meaning :=
        let $lemmaDefs := $a_meanings/wds/w[l eq $lemma]
        return
          if ($lemmaDefs)
          then
            element mean
            {
              $lemmaDefs/d/text()
            }
          else ()
      (: Note: $lemmaEntries/m/@p does not work reliably in eXist :)
      for $pofs in
            local:distinct-items(for $e in $lemmaEntries return $e/m/@p, ())
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
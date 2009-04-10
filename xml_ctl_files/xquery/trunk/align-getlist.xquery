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
  Create HTML page with list of initial parts of aligned sentences
 :)

module namespace alst="http://alpheios.net/namespaces/align-list";

(:
  Function to create an HTML page with a list of sentences
  from an aligned text document

  Parameters:
    $a_docName     name of aligned text document
    $a_queryBase   query to invoke when sentence is selected
    $a_maxWords    maximum number of words to use from sentence
    $a_maxSents    maximum number of sentences to use from document

  Return value:
    HTML page with a list of initial sentence fragments
 :)
declare function alst:get-list-page(
  $a_docName as xs:string,
  $a_queryBase as xs:string,
  $a_maxWords as xs:integer,
  $a_maxSents as xs:integer) as element()?
{
  let $doc := doc($a_docName)
  let $sents := subsequence($doc//*:sentence, 1, $a_maxSents)
  let $docId := substring-before($doc//sentence[1]/@document_id, ":")

  return
  <html xmlns="http://www.w3.org/1999/xhtml">{
  element head
  {
    element title
    {
      "Alpheios:Aligned Sentence List",
      $docId
    },

    (: metadata for language codes :)
    element meta
    {
      attribute name { "L1:lang" },
      attribute content { $sents[1]/*:wds[@lnum = "L1"]/@lang }
    },
    element meta
    {
      attribute name { "L2:lang" },
      attribute content { $sents[1]/*:wds[@lnum = "L2"]/@lang }
    },

    element link
    {
      attribute rel { "stylesheet" },
      attribute type { "text/css" },
      attribute href { "../css/alph-align-list.css" }
    }
  },

  element body
  {
    (: logo :)
    <div class="alpheios-ignore">
      <div id="alph-page-header">
        <img src="../image/alpheios.png"/>
      </div>
    </div>,

    element h2
    {
      concat("Sentence list for document ", $docId, " [file ", $a_docName, "]")
    },
    element ol
    {
      (: for each sentence :)
      for $sent at $i in $sents
      let $queryURL := concat($a_queryBase, $i)
      let $l1Words := $sent/*:wds[@lnum="L1"]/*:w
      let $l2Words := $sent/*:wds[@lnum="L2"]/*:w
      return
      (
        element li
        {
          attribute value { $i },
          element a
          {
            attribute href { $queryURL },
            element div
            {
              attribute class { "sentence" },
              element div {
                (: concatenated words from L1 :)
                string-join((for $j in 1 to $a_maxWords return $l1Words[$j],
                             if (count($l1Words) > $a_maxWords) then "..." else ""),
                            ' ')
              },
              element div {
                (: concatenated words from L2 :)
                string-join((for $j in 1 to $a_maxWords return $l2Words[$j],
                             if (count($l1Words) > $a_maxWords) then "..." else ""),
                            ' ')
              }
            }
          }
        }
      )
    }
  }
  }</html>
};
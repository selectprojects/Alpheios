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
  Create HTML pages for editing arbitrary text

  If called without any input text, a page for text entry is returned.
  When text is entered, this xquery is re-executed with the text as input,
  at which point a page containing an unstructured tree (all text words as
  immediate children of the root, all morphology and dependencies unspecified)
  is returned.
  
  Usage: treebank-entertext.xq?<parameters>
  Parameters:
    format      name of treebank format
    lang        language of text
    inputtext   input text to create tree for
 :)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace tbu="http://alpheios.net/namespaces/treebank-util"
              at "treebank-util.xquery";
declare namespace tbd = "http://alpheios.net/namespaces/treebank-desc";
declare option exist:serialize
        "method=xhtml media-type=application/xhtml+xml omit-xml-declaration=no indent=yes 
        doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Transitional//EN
        doctype-system=http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd";

let $input := request:get-parameter("inputtext", ())

return
(: if input supplied, then generate editing page :)
if ($input)
then
  let $format := request:get-parameter("format", "aldt")
  let $lang := request:get-parameter("lang", "grc")
  let $tbDesc := tbu:get-format-description($format, "/db/xq/config")
  return
  <html xmlns="http://www.w3.org/1999/xhtml"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink">
  <head>
    <title>Alpheios:Edit Tree</title>
    <link rel="stylesheet" type="text/css" href="../css/alph-treebank-edit.css"/>
    <meta name="L1:lang" content="{ $lang }" />
    <meta name="text-direction"
          content="{ if ($lang = ('ara')) then 'rtl' else 'ltr' }" />
    <meta id="alpheios-treebank-format"
          name="alpheios-treebank-format"
          content="{ $format }" />
    <meta id="alpheios-pedagogical-text"
          name="alpheios-pedagogical-text"
          content="true"/>
    <script language="javascript"
            type="text/javascript"
            src="../script/alph-treebank-edit.js"/>
    <script language="javascript"
            type="text/javascript"
            src="../script/alph-edit-utils.js"/>
    <script language="javascript"
            type="text/javascript"
            src="../script/jquery-1.2.6-alph.js"/>
  </head>
  <body>
    <div class="alpheios-ignore">
      <div id="alph-page-header">
        <img src="../image/alpheios.png"/>
      </div>
    </div>
    <div class="controls alpheios-ignore">
      <input id="save-button" type="hidden">Save sentence</input>
      <button id="undo-button"
              disabled="yes"
              onclick="ClickOnUndo(event)">&lt; Undo</button>
      <button id="redo-button"
              disabled="yes"
              onclick="ClickOnRedo(event)">Redo &gt;</button>
      <form>
        <label for="expansion-checkbox">Show expansion controls</label>
        <input id="expansion-checkbox"
               type="checkbox"
               onclick="ShowExpansionControls(event)"
               checked=""/>
      </form>
      {
      (: dependency relation menus :)
      element span { "Dependency Relation: " },
      for $type at $i in ("relation", "subrelation")
      return
        let $entries := tbu:get-entries($tbDesc, $type)
        return
        if (count($entries) > 0)
        then
          element select
          {
            attribute name { concat("arcrel", $i) },
            for $entry in $entries
            return
            element option
            {
              attribute value { $entry/tbd:tb },
              if ($entry/tbd:menu)
              then
                $entry/tbd:menu/text()
              else
                $entry/tbd:tb/text()
            }
          }
        else ()
      }
    </div>
    <br/>
    <svg:svg xmlns="http://www.w3.org/2000/svg"
             id="dependency-tree"
             onload="Init()">
      <text class="input-text" visibility="hidden"
        >{ $input }</text>
    </svg:svg>
  </body>
  </html>

(: if no input supplied, then generate entry page :)
else
  <html xmlns="http://www.w3.org/1999/xhtml"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink">
  <head>
    <link rel="stylesheet" type="text/css" href="../css/alph-treebank-list.css"/>
    <script language="javascript" type="text/javascript" src="../script/alph-treebank-list.js"/>
    <script language="javascript" type="text/javascript" src="../script/jquery-1.2.6-alph.js"/>
  </head>
  <body>
    <div class="alpheios-ignore">
      <div id="alph-page-header">
        <img src="../image/alpheios.png"/>
      </div>
    </div>
    <div id="input-form">
      <form name="inputform" action="treebank-entertext.xq">
        <fieldset>
          <legend>Input text:</legend>
          <textarea name="inputtext" rows="10" cols="80"
            >tantum in amore preces et bene facta valent</textarea>
        </fieldset>
        <fieldset id="format-buttons">
          <legend>Format:</legend>
          <input type="radio" id="format-aldt" name="format" checked="" value="aldt"/>
          <label for="format-aldt">Ancient Language Dependency Treebank</label>
          <input type="radio" id="format-catib" name="format" value="catib"/>
          <label for="format-catib">Columbia Arabic Treebank</label>
        </fieldset>
        <fieldset id="lang-buttons">
          <legend>Language:</legend>
          <input type="radio" id="lang-grc" name="lang" value="grc"/>
          <label for="lang-grc">Greek</label>
          <input type="radio" id="lang-la" name="lang" value="la" checked=""/>
          <label for="lang-la">Latin</label>
          <input type="radio" id="lang-ara" name="lang" value="ara"/>
          <label for="lang-ara">Arabic</label>
          <input type="radio" id="lang-en" name="lang" value="en"/>
          <label for="lang-en">English</label>
        </fieldset>
        <button type="submit">Edit</button>
      </form>
    </div>
  </body>
  </html>

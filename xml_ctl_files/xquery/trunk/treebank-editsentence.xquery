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
  Create HTML page for editing treebank sentence
 :)

module namespace tbed="http://alpheios.net/namespaces/treebank-edit";
import module namespace tbsed="http://alpheios.net/namespaces/treebank-svg-edit"
              at "treebank-svg-edit.xquery";
import module namespace tbu="http://alpheios.net/namespaces/treebank-util"
              at "treebank-util.xquery";
declare namespace tbd = "http://alpheios.net/namespaces/treebank-desc";

(:
  Function to create an HTML page for editing a sentence
  from a treebank document

  Parameters:
    $a_docName      name of treebank document
    $a_docStem      document stem
    $a_base         base path to current request
    $a_tb           treebank format
    $a_defaultTb    default treebank format
    $a_sentId       id of sentence to edit
    $a_mapRelations whether to map relation names to more friendly form 
    $a_URLs         URLs for actions (1=save, 2=list, 3=edit, 4=enter text)
    $a_editParam    sentence number parameter

  Return value:
    HTML page with SVG for editing sentence
 :)
declare function tbed:get-edit-page(
  $a_docName as xs:string,
  $a_docStem as xs:string,
  $a_base as xs:string,
  $a_tb as xs:string?,
  $a_defaultTb as xs:string,
  $a_sentId as xs:integer,
  $a_mapRelations as xs:boolean,
  $a_URLs as xs:string*,
  $a_editParam as xs:string) as element()?
{
  let $doc := doc($a_docName)
  let $maxSentId := count($doc//*:sentence)
  let $sent := ($doc//*:sentence)[$a_sentId]
  let $lang := $doc/*:treebank/@xml:lang

  (: get treebank format :)
  (: if not specified, try to get it from data :)
  (: if not found there, use default :)
  let $tb :=
    if (not($a_tb))
    then
      $doc/*:treebank/@format
    else
      $a_tb
  let $tb := if ($tb) then $tb else $a_defaultTb

  (: get treebank format description :)
  let $tb := if ($a_tb) then $a_tb else tbu:get-format-name($doc, $a_defaultTb)
  let $tbDesc := tbu:get-format-description($tb, "/db/xq/config")

  return
  <html xmlns="http://www.w3.org/1999/xhtml"
        xmlns:svg="http://www.w3.org/2000/svg"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        xml:lang="{if ($lang='grc') then 'greek' else $lang}"
  >{

  element head
  {
    element title
    {
      "Alpheios:Edit Treebank Sentence",
      data($sent/@*:document_id)
    },

    (: metadata :)
    element meta
    {
      attribute name { "L1:lang" },
      attribute content { $lang }
    },
    element meta
    {
      attribute name { "text-direction" },
      attribute content
      {
        if ($lang = ("ara")) then "rtl" else "ltr"
      }
    },
    element meta
    {
      attribute id { "alpheios-treebank-format" },
      attribute name { "alpheios-treebank-format" },
      attribute content { $tb }
    },
    element meta
    {
      attribute id { "alpheios-pedagogical-text" },
      attribute name { "alpheios-pedagogical-text" },
      attribute content { "true" }
    },

    element link
    {
      attribute rel { "stylesheet" },
      attribute type { "text/css" },
      attribute href { "../css/alph-treebank-edit.css" }
    },

    element script
    {
      attribute language { "javascript" },
      attribute type { "text/javascript" },
      attribute src { "../script/alph-treebank-edit.js" }
    },
    element script
    {
      attribute language { "javascript" },
      attribute type { "text/javascript" },
      attribute src { "../script/alph-edit-utils.js" }
    },
    element script
    {
      attribute language { "javascript" },
      attribute type { "text/javascript" },
      attribute src { "../script/jquery-1.2.6-alph.js" }
    }
  },

  element body
  {
(:    attribute onkeypress { "Keypress(event)" }, :)

    (: logo :)
    <div class="alpheios-ignore">
      <div id="alph-page-header">
        <img src="../image/alpheios.png"/>
      </div>
    </div>,

    (: controls :)
    element div
    {
      attribute class { "controls alpheios-ignore" },

      (: sentence navigation :)
      if ($maxSentId > 1)
      then
      let $sentId :=
        if ($a_sentId <= 0 or $a_sentId > $maxSentId) then 1 else $a_sentId
      return
      (
        element form
        {
          attribute onsubmit { "return FormSubmit(this)" },
          attribute action { $a_URLs[3] },
          attribute name { "sent-navigation-goto" },

          <input type="hidden" name="doc" value="{ $a_docStem }"/>,
          <input type="hidden"
                 name="maxSentId"
                 disabled="yes"
                 value="{ $maxSentId }"/>,

          element label { "Go to sentence number" },
          element input
          {
            attribute type { "text" },
            attribute name { $a_editParam },
            attribute size { "5" }
          }
        },

        element form
        {
          attribute onsubmit { "return FormSubmit(this)" },
          attribute action { $a_URLs[3] },
          attribute name { "sent-navigation-buttons" },

          <input type="hidden" name="doc" value="{ $a_docStem }"/>,
          <input type="hidden"
                 name="maxSentId"
                 disabled="yes"
                 value="{ $maxSentId }"/>,

          element button
          {
            attribute type { "submit" },
            attribute name { $a_editParam },
            attribute value { 1 },
            if ($sentId <= 1)
            then
              attribute disabled { "yes" }
            else (),
            "1&#xA0;&#x25C2;&#x25C2;"
          },
          element button
          {
            attribute type { "submit" },
            attribute name { $a_editParam },
            attribute accesskey { "<" },
            attribute value { $sentId - 1 },
            if ($sentId <= 1)
            then
            (
              attribute disabled { "yes" },
              "1&#xA0;&#x25C2;"
            )
            else
              concat($sentId - 1, "&#xA0;&#x25C2;")
          },
          
          element label { $sentId },

          element button
          {
            attribute type { "submit" },
            attribute name { $a_editParam },
            attribute accesskey { ">" },
            attribute value { $sentId + 1 },
            if ($sentId >= $maxSentId)
            then
            (
              attribute disabled { "yes" },
              concat("&#x25B8;&#xA0;", $maxSentId)
            )
            else
              concat("&#x25B8;&#xA0;", $sentId + 1)
          },
          element button
          {
            attribute type { "submit" },
            attribute name { $a_editParam },
            attribute value { $maxSentId },
            if ($sentId >= $maxSentId)
            then
              attribute disabled { "yes" }
            else (),
            concat("&#x25B8;&#x25B8;&#xA0;", $maxSentId)
          }
        },

        element form
        {
          attribute onsubmit { "return FormSubmit(this)" },
          attribute action { $a_URLs[2] },
          attribute name { "sent-navigation-list" },

          <input type="hidden" name="doc" value="{ $a_docStem }"/>,

          element button
          {
            attribute type { "submit" },
            "Go to list of sentences"
          }
        },

        element form
        {
          attribute action { $a_URLs[4] },
          element button
          {
            attribute type { "submit" },
            "Enter text"
          }
        },

        <br/>
      )
      else (),

      <button id="save-button"
              onclick="ClickOnSave(event)">Save sentence</button>,
      <button id="undo-button"
              disabled="yes"
              onclick="ClickOnUndo(event)">&lt; Undo</button>,
      <button id="redo-button"
              disabled="yes"
              onclick="ClickOnRedo(event)">Redo &gt;</button>,

      element form
      {
        element label
        {
          attribute for { "expansion-checkbox" },
          "Show expansion controls"
        },
        element input
        {
          attribute id { "expansion-checkbox" },
          attribute type { "checkbox" },
          attribute onclick { "ShowExpansionControls(event)" },
          attribute checked {}
        }
      },

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
    },

    <br/>,

    (: svg of sentence :)
    tbsed:get-svg(
      $tbDesc,
      $sent,
      $a_mapRelations,
      (
        attribute id { "dependency-tree" },
        attribute alph-doc { $a_docStem },
        attribute alph-sentid { $a_sentId },
        attribute alph-saveurl { $a_URLs[1] },
        attribute onload { "Init(evt)" }
      ))
  }

  }</html>
};
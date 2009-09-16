<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
  xmlns:exsl="http://exslt.org/common"
  xmlns:xlink="http://www.w3.org/1999/xlink">

  <!--
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
  -->
  <!--
    This stylesheet groups the data on 3 attributes for the rows,
    and groups on 1 variable attribute plus the type for the columns.

    Parameters: per alph-infl-params.xsl
  -->
  <xsl:import href="alph-infl-params.xsl"/>
  <xsl:import href="alph-infl-ending.xsl"/>
  <xsl:import href="alph-infl-match.xsl"/>
  <xsl:import href="alph-infl-extras.xsl"/>


  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:key name="s_footnotes" match="footnote" use="@id"/>

  <!-- debug -->
  <xsl:param name="e_testEndings">
    <!--
    <div class="alph-entry">
      <div lemma-lex="aut" lemma-lang="grc" lemma-id="n30657" lemma-key="ἐγώ" class="alph-dict">
        <span class="alph-hdwd">ἐγώ: </span>
        <div class="alph-morph">
          <span context="pronoun" class="alph-pofs">pronoun</span>
        </div>
      </div>
      <div class="alph-mean">I, me</div>
      <div context="ἐγώ" class="alph-infl-set">
        <span class="alph-term">ἐγώ<span class="alph-suff"></span></span>
        <span>(<span context="pron1" class="alph-nopad alph-stemtype">s=pron1</span>,
          <span context="indeclform" class="alph-nopad alph-morphflags">m=indeclform</span>)
        </span>
        <div class="alph-infl">Singular:
          <span alph-pofs="pronoun" alph-gend="masculine" alph-num="singular" context="nominative-singular-masculine-pronoun" class="alph-case">nominative (m)</span>
          <span alph-pofs="pronoun" alph-gend="feminine" alph-num="singular" context="nominative-singular-feminine-pronoun" class="alph-case">nominative (f)</span>
          <span alph-pofs="pronoun" alph-gend="masculine" alph-num="singular" context="vocative-singular-masculine-pronoun" class="alph-case">vocative (m)</span>
          <span alph-pofs="pronoun" alph-gend="feminine" alph-num="singular" context="vocative-singular-feminine-pronoun" class="alph-case">vocative (f)</span>
        </div>
      </div>
    </div>
    -->
  </xsl:param>
  <!--xsl:param name='e_selectedEndings' select="exsl:node-set($e_testEndings)"/-->

  <xsl:template match="/infl-data">
    <xsl:variable name="tableNotes">
      <xsl:if test="@footnote">
        <div id="table-notes">
          <xsl:call-template name="add-footnote">
            <xsl:with-param name="a_item" select="."/>
          </xsl:call-template>
        </div>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$e_fragment">
        <xsl:copy-of select="$tableNotes"/>
        <xsl:call-template name="infltable">
          <xsl:with-param name="a_endings" select="//infl-ending-set"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <html>
          <head>
            <link rel="stylesheet" type="text/css" href="chrome://alpheios/skin/alph-infl.css"/>
            <link rel="stylesheet" type="text/css" href="chrome://alpheios/skin/alph-infl-{$e_matchPofs}.css"/>
          </head>
          <body>
            <xsl:copy-of select="$tableNotes"/>
            <xsl:call-template name="infltable">
              <xsl:with-param name="a_endings" select="//infl-ending-set"/>
            </xsl:call-template>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="infltable">
    <xsl:param name="a_endings" />
    <table id="alph-infl-table"> <!-- start table -->
      <!-- add the caption -->
      <caption>
        <xsl:call-template name="form-caption">
          <xsl:with-param name="a_selectedEndings" select="$e_selectedEndings"/>
          <xsl:with-param name="a_form" select="$e_form"/>
          <xsl:with-param name="a_hasData" select="count($a_endings) &gt; 0"/>
        </xsl:call-template>
      </caption>
      <!-- write the colgroup elements -->
      <xsl:call-template name="colgroups">
        <xsl:with-param name="a_headerrow1" select="//order-item[@attname=$e_group4]"/>
        <xsl:with-param name="a_headerrow2" select="//order-item[@attname='type']"/>
      </xsl:call-template>
      <!-- write the column header rows -->
      <xsl:call-template name="headers">
        <xsl:with-param name="a_headerrow1" select="//order-item[@attname=$e_group4]"/>
      </xsl:call-template>
      <!-- debugging
      <pre class="debug">
        group1: <xsl:value-of select="$e_group1"/>
        group2: <xsl:value-of select="$e_group2"/>
        group4: <xsl:value-of select="$e_group4"/>
        <xsl:copy-of select="$e_selectedEndings"/>
      </pre>
      -->

      <!-- gather first level row grouping:
        all attribute values for group1 attribute -->
      <xsl:variable name="firstgroup" select="$a_endings/@*[local-name(.)=$e_group1]"/>
      <!-- iterate though the items in the first group -->
      <xsl:for-each select="$firstgroup">
        <!-- lookup sort order for this attribute from order-table in the inflection data -->
        <xsl:sort
          select="/infl-data/order-table/order-item[@attname=$e_group1
          and text()=current()]/@order"
          data-type="number"/>
        <!-- if this is the first instance of this attribute value proceed to
          2nd level grouping -->
        <xsl:if test="generate-id(.) = generate-id($firstgroup[.=current()])">
          <xsl:variable name="lastgroup1" select="."/>
          <!-- gather second level row grouping:
            all group2 attribute values
            from all elements whose group1 attribute matches the current group1 value
          -->
          <xsl:variable name="secondgroup"
            select="$a_endings/@*[local-name(.)=$e_group1
            and .=$lastgroup1]/../@*[local-name(.)=$e_group2]"/>
          <!-- first instance of group1 row so add header row -->
          <!-- TODO colspan should not be hardcoded -->
          <tr id="header-{$lastgroup1}" class="group1row">
            <th class="header-text always-visible" colspan="2">
              <xsl:value-of select="$lastgroup1"/>
              <xsl:call-template name="add-footnote">
                <xsl:with-param name="a_item"
                  select="/infl-data/order-table/order-item[@attname=$e_group1
                  and text()=$lastgroup1]" />
              </xsl:call-template>
            </th>
            <xsl:call-template name="headerrow">
              <xsl:with-param name="a_headerrow1" select="//order-item[@attname=$e_group4]"/>
            </xsl:call-template>
          </tr>
          <!-- if none in 2nd group, just add the items in the first group -->
          <xsl:if test="count($secondgroup) = 0">
            <tr class="data-row">
              <th class="emptyheader" colspan="2">&#160;</th>
              <xsl:for-each select="$a_endings/@*[local-name(.)=$e_group1 and .=$lastgroup1]/..">
                <xsl:variable name="selected">
                  <xsl:call-template name="check-infl-sets">
                    <xsl:with-param name="a_selectedEndings" select="$e_selectedEndings"/>
                    <xsl:with-param name="a_currentData" select="." />
                    <xsl:with-param name="a_matchPofs" select="$e_matchPofs"/>
                    <xsl:with-param name="a_matchForm">
                      <xsl:if test="$e_matchForm"><xsl:value-of select="$e_form"/></xsl:if>
                    </xsl:with-param>
                    <xsl:with-param name="a_normalizeGreek" select="$e_normalizeGreek"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="textForMatch">
                  <xsl:call-template name="text-for-match">
                    <xsl:with-param name="a_selectedEndings" select="$e_selectedEndings"/>
                    <xsl:with-param name="a_matchForm">
                      <xsl:if test="$e_matchForm"><xsl:value-of select="$e_form"/></xsl:if>
                    </xsl:with-param>
                    <xsl:with-param name="a_normalizeGreek" select="$e_normalizeGreek"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="ending-cell">
                  <xsl:with-param name="a_inflEndings" select="infl-endings"/>
                  <xsl:with-param name="a_selected" select="$selected"/>
                  <xsl:with-param name="a_selectedEndings"
                                  select="$e_selectedEndings"/>
                  <xsl:with-param name="a_textForMatch"
                                  select="$textForMatch"/>
                  <xsl:with-param name="a_translitEndingTableMatch"
                                  select="$e_translitEndingTableMatch"/>
                  <xsl:with-param name="a_dedupeBy" select="$e_dedupeBy"/>
                  <xsl:with-param name="a_showOnlyMatches"
                                  select="$e_showOnlyMatches"/>
                  <xsl:with-param name="a_matchForm" select="$e_matchForm"/>
                  <xsl:with-param name="a_normalizeGreek"
                                  select="$e_normalizeGreek"/>
                </xsl:call-template>
              </xsl:for-each>
            </tr>
          </xsl:if>

          <!-- iterate through the items in the second group -->
          <xsl:for-each select="$secondgroup">
            <xsl:sort select="/infl-data/order-table/order-item[@attname=$e_group2
              and text()=current()]/@order" data-type="number"/>
              <!-- start a new row to hold the data if this is the first instance of
                this attribute value -->
              <xsl:if test="generate-id(.) = generate-id($secondgroup[.=current()])">
                <xsl:variable name="lastgroup2" select="."/>
                <xsl:variable name="rowId" select="concat($lastgroup1,$lastgroup2)"/>
                <tr class="data-row" id="{$rowId}"> <!-- start new row -->
                  <th class="emptyheader">&#160;</th>
                  <!-- gather the actual ending data in this grouping:
                    all elements whose
                    - group1 attribute matches the current group1 value and
                    - group2 attribute matches the current group2 value
                  -->
                  <xsl:variable name="data"
                    select="$a_endings/@*[local-name(.)=$e_group1
                    and .=$lastgroup1]/../@*[local-name(.)=$e_group2
                    and . = $lastgroup2]/.."/>
                  <xsl:call-template name="rowgroup">
                    <xsl:with-param name="a_data" select="$data"/>
                    <xsl:with-param name="a_groupheader" select="$lastgroup2"/>
                    <xsl:with-param name="a_colgroup" select="$lastgroup1"/>
                  </xsl:call-template>
                </tr>
              </xsl:if>
          </xsl:for-each>
        </xsl:if>
      </xsl:for-each>
    </table> <!-- end infl table -->
  </xsl:template>

  <!-- template to write a group of rows of infl-ending data to the table -->
  <xsl:template name="rowgroup">
    <xsl:param name="a_data"/>
    <xsl:param name="a_groupheader"/>
    <xsl:param name="a_colgroup"/>
    <xsl:variable name="group4Vals" select="//order-item[@attname=$e_group4]"/>
    <!--td class="ending-group"--> <!-- start new cell -->
    <!---
      for each group4
      if the set doesn't have a match on group4 then print an empty cell
    -->
    <xsl:for-each select="$group4Vals">
      <xsl:sort
        select="@order"/>
      <xsl:variable name="lastgroup4" select="."/>
      <xsl:if test="position()=1">
        <!-- add the row header cell if it's the first cell in
          the row -->
        <th class="rowgroupheader header-text">
          <xsl:value-of select="$a_groupheader"/>
          <xsl:call-template name="add-footnote">
            <xsl:with-param name="a_item" select="/infl-data/order-table/order-item[@attname=$a_groupheader]"/>
          </xsl:call-template>
        </th>
      </xsl:if>
      <xsl:variable name="celldata"
          select="$a_data/@*[local-name(.)=$e_group4
          and .=$lastgroup4]/.."/>
      <xsl:choose>
        <xsl:when test="count($celldata) = 0">
          <td class="{$lastgroup4}"><span class="emptycell">&#160;</span></td>
          <td class="{$lastgroup4}"><span class="emptycell">&#160;</span></td>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="selected">
            <xsl:call-template name="check-infl-sets">
              <xsl:with-param name="a_currentData" select="$celldata" />
              <xsl:with-param name="a_selectedEndings" select="$e_selectedEndings"/>
              <xsl:with-param name="a_matchPofs" select="$e_matchPofs"/>
              <xsl:with-param name="a_matchForm">
                <xsl:if test="$e_matchForm"><xsl:value-of select="$e_form"/></xsl:if>
              </xsl:with-param>
              <xsl:with-param name="a_normalizeGreek" select="$e_normalizeGreek"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="textForMatch">
            <xsl:call-template name="text-for-match">
              <xsl:with-param name="a_selectedEndings" select="$e_selectedEndings"/>
              <xsl:with-param name="a_matchForm">
                <xsl:if test="$e_matchForm"><xsl:value-of select="$e_form"/></xsl:if>
              </xsl:with-param>
              <xsl:with-param name="a_normalizeGreek" select="$e_normalizeGreek"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:call-template name="ending-cell">
            <xsl:with-param name="a_inflEndings" select="$celldata"/>
            <xsl:with-param name="a_selected" select="$selected"/>
            <xsl:with-param name="a_selectedEndings"
                            select="$e_selectedEndings"/>
            <xsl:with-param name="a_textForMatch" select="$textForMatch"/>
            <xsl:with-param name="a_translitEndingTableMatch"
                            select="$e_translitEndingTableMatch"/>
            <xsl:with-param name="a_dedupeBy" select="$e_dedupeBy"/>
            <xsl:with-param name="a_showOnlyMatches"
                            select="$e_showOnlyMatches"/>
            <xsl:with-param name="a_matchForm" select="$e_matchForm"/>
            <xsl:with-param name="a_normalizeGreek" select="$e_normalizeGreek"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- template to produce header rows for the table columns -->
  <xsl:template name="headers">
    <xsl:param name="a_headerrow1"/>
    <xsl:param name="a_headerrow2"/>
    <xsl:param name="a_headerrow3"/>
    <tr id="headerrow1" class='expand-ctl'>
      <th colspan="2" class="always-visible">
        <span class="header-text"><xsl:value-of select="$e_group4"/></span>
        <xsl:call-template name="stem-header">
          <xsl:with-param name="a_header" select="$e_group4"/>
        </xsl:call-template>
      </th>
      <xsl:for-each select="$a_headerrow1">
        <xsl:sort select="@order" data-type="number"/>
        <xsl:variable name="colspan"
          select="'2'"/>
          <th colspan="{$colspan}">
            <span class="header-text"><xsl:value-of select="."/></span>
            <xsl:apply-templates select="."/>
          </th>
      </xsl:for-each>
    </tr>
  </xsl:template>

  <!-- template to produce colgroups for the table columns -->
  <xsl:template name="colgroups">
    <xsl:param name="a_headerrow1"/>
    <xsl:param name="a_headerrow2"/>
    <xsl:variable name="row2count" select="count($a_headerrow2)"/>
    <colgroup class="leftheader">
      <col realIndex="0"/>
      <col realIndex="1"/>
    </colgroup>
    <xsl:for-each select="$a_headerrow1">
      <xsl:variable name="row1pos" select="position()-1"/>
      <colgroup class="header1">
        <xsl:for-each select="$a_headerrow2">
          <xsl:variable name="row2pos" select="position()-1"/>
          <xsl:variable name="index"
              select="($row1pos *  $row2count) +
              position() + 1"/>
            <col class="header2col" realIndex="{$index}"
              row1pos="{$row1pos}"
              row2pos="{$row2pos}"/>
        </xsl:for-each>
      </colgroup>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="headerrow">
    <xsl:param name="a_headerrow1"/>
    <xsl:param name="a_headerrow2"/>
    <xsl:param name="a_headerrow3"/>
    <xsl:for-each select="$a_headerrow1">
      <td class="emptycell">&#160;</td>
      <td class="emptycell">&#160;</td>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

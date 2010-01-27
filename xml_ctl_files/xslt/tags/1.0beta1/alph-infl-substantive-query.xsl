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
    Stylesheet for transformation of substantive (noun and adjective)
    inflection data to HTML

    Parameters: per alph-infl-params.xsl

    Stylesheet-specific params:
        $decl: declension to filter displayed endings
  -->
  <xsl:import href="alph-infl-params.xsl"/>
  <xsl:import href="alph-query-ending.xsl"/>
  <xsl:import href="alph-infl-match.xsl"/>
  <xsl:import href="alph-infl-extras.xsl"/>

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:key name="s_footnotes" match="footnote" use="@id"/>

  <xsl:param name="decl"/>

  <xsl:template match="/infl-data">
    <xsl:variable name="tableNotes">
      <!--xsl:if test="@footnote">
        <div id="table-notes">
          <xsl:call-template name="add-footnote">
            <xsl:with-param name="a_item" select="."/>
          </xsl:call-template>
        </div>
      </xsl:if-->
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$e_fragment">
        <xsl:copy-of select="$tableNotes"/>
        <xsl:call-template name="infltable">
          <xsl:with-param name="a_endings" select="//infl-ending-set[contains($decl,@decl) or contains(@decl,$decl)]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <html>
          <head>
          </head>
          <body>
            <xsl:copy-of select="$tableNotes"/>
            <xsl:call-template name="infltable">
              <xsl:with-param name="a_endings" select="//infl-ending-set[contains($decl,@decl) or contains(@decl,$decl)]"/>
            </xsl:call-template>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="infltable">
    <xsl:param name="a_endings" />
    <table id="alph-infl-table"> <!-- start table -->
      <caption>
        <xsl:for-each select="$e_selectedEndings//*[@class='alph-term']">
          <xsl:if test="position() &gt; 1">
            ,
          </xsl:if>
          <div class="alph-infl-term"><xsl:copy-of select="current()"/></div>
        </xsl:for-each>
      </caption>
      <!-- write the colgroup elements -->
      <xsl:call-template name="colgroups">
        <xsl:with-param name="a_headerrow1" select="//order-item[@attname=$e_group4]"/>
        <xsl:with-param name="a_headerrow2" select="//order-item[@attname=$e_group5]"/>
      </xsl:call-template>
      <!-- write the column header rows -->
      <xsl:call-template name="headers">
        <xsl:with-param name="a_headerrow1" select="//order-item[@attname=$e_group4]"/>
        <xsl:with-param name="a_headerrow2" select="//order-item[@attname=$e_group5]"/>
      </xsl:call-template>
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
        <xsl:if test="generate-id(.) = generate-id($firstgroup[.=current()])">
          <xsl:variable name="lastgroup1" select="."/>
          <tr class="data-row" context="{$lastgroup1}"> <!-- start new row -->
            <th class="emptyheader">&#160;</th>
            <!-- gather the actual ending data in this grouping:
               all elements whose
               - group1 attribute matches the current group1 value and
            -->
            <xsl:variable name="data"
              select="$a_endings/@*[local-name(.)=$e_group1
                    and .=$lastgroup1]/.."/>
            <xsl:call-template name="rowgroup">
              <xsl:with-param name="a_data" select="$data"/>
              <xsl:with-param name="a_groupheader" select="$lastgroup1"/>
            </xsl:call-template>
          </tr>
        </xsl:if>
      </xsl:for-each>
    </table> <!-- end infl table -->
  </xsl:template>

  <!-- template to write a group of rows of infl-ending data to the table -->
  <xsl:template name="rowgroup">
    <xsl:param name="a_data"/>
    <xsl:param name="a_groupheader"/>
    <xsl:variable name="group4Vals" select="//order-item[@attname=$e_group4]"/>
    <xsl:variable name="group5Vals" select="//order-item[@attname=$e_group5]"/>

    <xsl:for-each select="$group4Vals">
      <xsl:sort
      select="@order"/>
      <xsl:variable name="lastgroup4" select="."/>
      <xsl:if test="position()=1">
        <!-- add the row header cell if it's the first cell in
        the row -->
        <xsl:element name="th">
          <xsl:attribute name="class">rowgroupheader header-text</xsl:attribute>
          <xsl:attribute name="context"><xsl:value-of select="$e_group1"/></xsl:attribute>
          <xsl:attribute name="{concat('alph-',$e_group1)}">
            <xsl:value-of select="
              concat('|',translate($a_groupheader,' ','|'),'|')"/>
          </xsl:attribute>
          <xsl:value-of select="$a_groupheader"/>
          <!--xsl:call-template name="add-footnote">
            <xsl:with-param name="a_item" select="/infl-data/order-table/order-item[@attname=$a_groupheader]"/>
          </xsl:call-template-->
        </xsl:element>
      </xsl:if>
      <xsl:for-each select="$group5Vals">
        <xsl:sort select="@order"/>
        <xsl:variable name="lastgroup5" select="."/>
        <xsl:variable name="celldata"
          select="$a_data/@*[local-name(.)=$e_group4
          and .=$lastgroup4]/../@*[local-name(.)=$e_group5
          and . = $lastgroup5]/.."/>
        <xsl:variable name="selected">
          <xsl:call-template name="check-infl-sets">
            <xsl:with-param name="a_currentData" select="$celldata" />
            <xsl:with-param name="a_selectedEndings" select="$e_selectedEndings"/>
            <xsl:with-param name="a_matchPofs" select="$e_matchPofs"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="ending-cell">
          <xsl:with-param name="a_inflEndings" select="$celldata"/>
          <xsl:with-param name="a_selected" select="$selected"/>
          <xsl:with-param name="a_selectedEndings" select="$e_selectedEndings"/>
          <xsl:with-param name="a_translitEndingTableMatch"
                          select="$e_translitEndingTableMatch"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- template to produce header rows for the table columns -->
  <xsl:template name="headers">
    <xsl:param name="a_headerrow1"/>
    <xsl:param name="a_headerrow2"/>
    <xsl:param name="a_headerrow3"/>
    <xsl:variable name="row2count" select="count($a_headerrow2)"/>
    <tr id="headerrow1">
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
        <xsl:element name="th">
          <xsl:attribute name="colspan">
            <xsl:value-of select="$row2count"/>
          </xsl:attribute>
          <xsl:attribute name="context">
            <xsl:value-of select="$e_group4"/>
          </xsl:attribute>
          <xsl:attribute name="{concat('alph-',$e_group4)}">
            <xsl:value-of select="
              concat('|',translate(.,' ','|'),'|')"/>
          </xsl:attribute>
          <span class="header-text"><xsl:value-of select="."/></span>
          <!--xsl:apply-templates select="."/-->
        </xsl:element>
      </xsl:for-each>
    </tr>
    <tr id="headerrow2" class='expand-ctl'>
      <th colspan="2" class="always-visible">
        <span class="header-text"><xsl:value-of select="$e_group5"/></span>
        <xsl:call-template name="stem-header">
          <xsl:with-param name="a_header" select="$e_group5"/>
        </xsl:call-template>
      </th>
      <xsl:for-each select="$a_headerrow1">
        <xsl:sort select="@order" data-type="number"/>
        <xsl:variable name="lastgroup4" select="."/>
        <xsl:for-each select="$a_headerrow2">
          <xsl:sort select="@order" data-type="number"/>
          <xsl:element name="th">
            <xsl:attribute name="colspan">
              <xsl:value-of select="1"/>
            </xsl:attribute>
            <xsl:attribute name="context">
              <xsl:value-of select="$e_group5"/>
            </xsl:attribute>
            <xsl:attribute name="{concat('alph-',$e_group5)}">
              <xsl:value-of select="
                concat('|',translate(.,' ','|'),'|')"/>
            </xsl:attribute>
            <xsl:attribute name="{concat('alph-',$e_group4)}">
              <xsl:value-of select="
                concat('|',translate($lastgroup4,' ','|'),'|')"/>
            </xsl:attribute>

            <span class="header-text"><xsl:value-of select="."/></span>
            <!--xsl:apply-templates select="."/-->
          </xsl:element>
        </xsl:for-each>
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
      <td colspan="2">&#160;</td>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

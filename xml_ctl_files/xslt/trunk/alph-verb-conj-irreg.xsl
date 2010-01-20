<?xml version="1.0" encoding="UTF-8"?>

<!--
  Stylesheet for transformation of irregular verb conjugation data to HTML
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
  xmlns:exsl="http://exslt.org/common">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:key name="s_footnotes" match="footnote" use="@id"/>

  <!-- row groupings -->
  <!-- default order is Tense, Number, Person -->
  <xsl:param name="e_group1" select="'tense'"/>
  <xsl:param name="e_group2" select="'num'"/>
  <xsl:param name="e_group3" select="'pers'"/>

  <!-- hdwd (required) -->
  <xsl:param name="e_hdwd"/>

  <!-- the following is optional, used to select specific verb-ending(s) -->
  <xsl:param name="e_selectedEndings" select="/.." />

  <!-- skip the enclosing html and body tags -->
  <xsl:param name="e_fragment" />

  <!--xsl:variable name="s_testEndings">
    <div id="alph-text">
      <div class="alph-word">
        <div class="alph-entry">
          <div class="alph-dict">
            <span class="alph-hdwd">sum, esse, fui, futurus: </span>
            <span context="verb" class="alph-pofs">verb</span>
            <span class="alph-attrlist">(very frequent)</span>
          </div>
          <div class="alph-mean">be; exist; (also used to form verb perfect passive tenses) with NOM PERF PPL</div>
          <div class="alph-infl-set">
            <span class="alph-term">s•<span class="alph-suff">umus</span></span>
            <div class="alph-infl">
              <span context="1st" class="alph-pers">1st person</span>
              <span context="plural" class="alph-num">plural;</span>
              <span class="alph-tense">present</span>
              <span context="indicative" class="alph-mood">indicative;</span>
              <span class="alph-voice">active</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    </xsl:variable-->
  <!--xsl:param name='e_selectedEndings' select="exsl:node-set($s_testEndings)"/-->

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$e_fragment">
        <xsl:call-template name="verbtable">
          <xsl:with-param name="a_endings" select="//conjugation[hdwd-set/hdwd/text() = string($e_hdwd)]/infl-form-set"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <html>
          <head>
            <link rel="stylesheet" type="text/css" href="alph-infl.css"/>
          </head>
          <body>
            <xsl:call-template name="verbtable">
              <xsl:with-param name="a_endings" select="//conjugation[hdwd-set/hdwd/text() = string($e_hdwd)]/infl-form-set"/>
            </xsl:call-template>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="verbtable">
    <xsl:param name="a_endings" />
    <xsl:variable name="includeVoice">
      <!-- the gerundive participle is identified as future passive participle and
         if it's the only instance of voice in the conjugation we don't want to pull it
         out into a separate column -->
      <xsl:value-of select="count($a_endings[@voice]) &gt; 1"/>
    </xsl:variable>
    <xsl:variable name="dataCols">
      <xsl:choose>
        <xsl:when test="$includeVoice = 'true'">4</xsl:when>
        <xsl:otherwise>2</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <table id="alph-infl-table"> <!-- start verb table -->
      <caption class="hdwd">
        <xsl:value-of select="$e_hdwd"/>
        <xsl:call-template name="add-footnote">
          <xsl:with-param name="a_item" select="//conjugation/hdwd-set/hdwd[text() = string($e_hdwd)]"/>
        </xsl:call-template>
      </caption>

      <!-- add the column groups -->
      <xsl:call-template name="colgroups">
        <xsl:with-param name="a_includeVoice" select="$includeVoice"/>
      </xsl:call-template>

      <!-- gather first level row grouping:
      all attribute values for group1 attribute -->
      <!-- first show indicative/subjunctive moods -->
      <xsl:call-template name="rowgroupings">
        <xsl:with-param name="a_rowgroupdata" select="$a_endings[@mood='indicative' or @mood='subjunctive']"/>
        <xsl:with-param name="a_headerdata"
          select="//order-item[@attname='mood' and (text()='indicative' or text()='subjunctive')]"/>
        <xsl:with-param name="a_dataCols" select="$dataCols"/>
        <xsl:with-param name="a_includeVoice" select="$includeVoice"/>
      </xsl:call-template>
      <!-- Imperative -->
      <xsl:call-template name="rowgroupings">
        <xsl:with-param name="a_rowgroupdata" select="$a_endings[@mood='imperative']"/>
        <xsl:with-param name="a_headerdata"
          select="//order-item[@attname='mood' and text()='imperative']"/>
        <xsl:with-param name="a_dataCols" select="$dataCols"/>
        <xsl:with-param name="a_includeVoice" select="$includeVoice"/>
      </xsl:call-template>

      <!--Infinitive -->
      <xsl:call-template name="rowgroupings">
        <xsl:with-param name="a_rowgroupdata" select="$a_endings[@mood='infinitive']"/>
        <xsl:with-param name="a_headerdata"
          select="//order-item[@attname='mood' and text()='infinitive']"/>
        <xsl:with-param name="a_dataCols" select="$dataCols"/>
        <xsl:with-param name="a_includeVoice" select="$includeVoice"/>
      </xsl:call-template>


      <!-- Participle -->
      <xsl:call-template name="rowgroupings">
        <xsl:with-param name="a_rowgroupdata" select="$a_endings[@mood='participle']"/>
        <xsl:with-param name="a_headerdata"
          select="//order-item[@attname='mood' and text()='participle']"/>
        <xsl:with-param name="a_dataCols" select="$dataCols"/>
        <xsl:with-param name="a_includeVoice" select="$includeVoice"/>
      </xsl:call-template>

      <!-- Gerundive -->
      <xsl:call-template name="rowgroupings">
        <xsl:with-param name="a_rowgroupdata" select="$a_endings[@mood='gerundive']"/>
        <xsl:with-param name="a_headerdata"
          select="//order-item[@attname='mood' and text()='gerundive']"/>
        <xsl:with-param name="a_dataCols" select="$dataCols"/>
        <xsl:with-param name="a_includeVoice" select="$includeVoice"/>
      </xsl:call-template>

      <!-- Supine -->
      <xsl:call-template name="rowgroupings">
        <xsl:with-param name="a_rowgroupdata" select="$a_endings[@mood='supine']"/>
        <xsl:with-param name="a_headerdata"
          select="//order-item[@attname='mood' and text()='supine']"/>
        <xsl:with-param name="a_dataCols" select="$dataCols"/>
        <xsl:with-param name="a_includeVoice" select="$includeVoice"/>
      </xsl:call-template>

    </table>
  </xsl:template>

  <xsl:template name="rowgroupings">
    <xsl:param name="a_rowgroupdata"/>
    <xsl:param name="a_headerdata"/>
    <xsl:param name="a_dataCols"/>
    <xsl:param name="a_includeVoice"/>
    <xsl:if test="count($a_rowgroupdata) > 0">
      <!-- write the column header rows -->
      <xsl:call-template name="headers">
        <xsl:with-param name="a_headerrow1" select="$a_headerdata"/>
        <xsl:with-param name="a_colspan" select="$a_dataCols div count($a_headerdata)"/>
        <xsl:with-param name="a_includeVoice" select="$a_includeVoice"/>
      </xsl:call-template>
    </xsl:if>
    <!-- group1 order is overridden to case when it's available -->
    <xsl:variable name="group1Variable">
      <xsl:choose>
        <xsl:when test="$a_rowgroupdata[@case]">
          <xsl:value-of select="'case'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$e_group1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="firstgroup" select="$a_rowgroupdata/@*[local-name(.)=$group1Variable]"/>
    <!-- iterate though the items in the first group -->
    <xsl:for-each select="$firstgroup">
      <!-- lookup sort order for this attribute from order-table in the conjugation data -->
      <xsl:sort
        select="/infl-data/order-table/order-item[@attname=$group1Variable
        and text()=current()]/@order"
        data-type="number"/>
      <!-- if this is the first instance of this attribute value proceed to
        2nd level grouping -->
      <xsl:if test="generate-id(.) = generate-id($firstgroup[.=current()])">
        <xsl:variable name="lastgroup1" select="."/>
        <!-- first instance of group1 row so add header row -->
        <!-- TODO colspan should not be hardcoded -->
        <tr id="{$lastgroup1}" class="group1row">
          <th class="header-text always-visible" colspan="2">
            <xsl:value-of select="$lastgroup1"/>
            <xsl:call-template name="add-footnote">
              <xsl:with-param name="a_item"
                select="/infl-data/order-table/order-item[@attname=$group1Variable
                and text()=$lastgroup1]" />
            </xsl:call-template>
          </th>
          <xsl:call-template name="emptyheader">
            <xsl:with-param name="a_counter" select="$a_dataCols + 1"/>
          </xsl:call-template>
        </tr>
        <!-- gather second level row grouping:
          all group2 attribute values
          from all elements whose group1 attribute matches the current group1 value
        -->
        <xsl:variable name="secondgroup"
          select="$a_rowgroupdata/@*[local-name(.)=$group1Variable
          and .=$lastgroup1]/../@*[local-name(.)=$e_group2]"/>

        <xsl:if test="count($secondgroup) = 0">
          <tr class="data-row">
            <th class="emptyheader" colspan="2">&#160;</th>
            <xsl:variable name="data" select="$a_rowgroupdata/@*[local-name(.)=$group1Variable and .=$lastgroup1]/.."/>
            <xsl:for-each select="$data">
              <xsl:variable name="selected">
                <xsl:call-template name="check-infl-sets">
                  <xsl:with-param name="a_currentData" select="." />
                </xsl:call-template>
              </xsl:variable>
              <xsl:call-template name="ending-cell">
                <xsl:with-param name="a_verbEndings" select="infl-form"/>
                <xsl:with-param name="a_colspan" select="$a_dataCols div count($data)"/>
                <xsl:with-param name="a_selected" select="$selected"/>
              </xsl:call-template>
            </xsl:for-each>
          </tr>
        </xsl:if>

        <!-- iterate through the items in the second group -->
        <xsl:for-each select="$secondgroup">
          <xsl:sort select="/infl-data/order-table/order-item[@attname=$e_group2
            and text()=current()]/@order" data-type="number"/>
          <!-- if this the first instance of this attribute value proceed
            to 3rd level grouping -->
          <xsl:if test="generate-id(.) = generate-id($secondgroup[.=current()])">
            <xsl:variable name="lastgroup2" select="."/>
            <!-- gather third level row grouping:
              all group3 attribute values from:
              all elements whose group1 attribute matches the current group1 value
              and whose group2 attribute matches the current group2 values
            -->
            <xsl:variable name="thirdgroup"
              select="$a_rowgroupdata/@*[local-name(.)=$group1Variable
              and .=$lastgroup1]/../@*[local-name(.)=$e_group2
              and . = $lastgroup2]/../@*[local-name(.)=$e_group3]"/>

            <xsl:if test="count($thirdgroup) = 0">
              <!-- if none in 3rd group, just add the items in the 2nd group -->
              <xsl:variable name="data" select="$a_rowgroupdata/@*[local-name(.)=$group1Variable
                and .=$lastgroup1]/../@*[local-name(.)=$e_group2
                and . = $lastgroup2]/.."/>
              <xsl:for-each select="$data">
                <th class="group2header header-text">
                  <xsl:value-of select="$lastgroup2"/>
                  <xsl:call-template name="add-footnote">
                    <xsl:with-param name="a_item"
                      select="/infl-data/order-table/order-item[@attname=$e_group2
                      and text()=$lastgroup2]"/>
                  </xsl:call-template>
                </th>
                <xsl:variable name="selected">
                  <xsl:call-template name="check-infl-sets">
                    <xsl:with-param name="a_currentData" select="." />
                  </xsl:call-template>
                </xsl:variable>
                <xsl:call-template name="ending-cell">
                  <xsl:with-param name="a_verbEndings" select="infl-form"/>
                  <xsl:with-param name="a_colspan" select="$a_dataCols div count($data)"/>
                  <xsl:with-param name="a_selected" select="$selected"/>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:if>

            <!-- iterate through the items in the third group -->
            <xsl:for-each select="$thirdgroup">
              <xsl:sort select="/infl-data/order-table/order-item[@attname=$e_group3 and text()=current()]/@order"
                data-type="number"/>
              <!-- start a new row to hold the data if this is the first instance of
                this attribute value -->
              <xsl:if test="generate-id(.) = generate-id($thirdgroup[.=current()])">
                <xsl:variable name="lastgroup3" select="."/>
                <xsl:variable name="rowId" select="concat($lastgroup1,$lastgroup2,$lastgroup3)"/>
                <tr class="data-row" id="{$rowId}"> <!-- start new row -->
                  <xsl:choose>
                    <xsl:when test="position()=1">
                      <!-- add row header on left if it's the first row in
                        this grouping -->
                      <th class="group2header header-text">
                        <xsl:value-of select="$lastgroup2"/>
                        <xsl:call-template name="add-footnote">
                          <xsl:with-param name="a_item"
                            select="/infl-data/order-table/order-item[@attname=$e_group2
                            and text()=$lastgroup2]"/>
                        </xsl:call-template>
                      </th>
                    </xsl:when>
                    <xsl:otherwise>
                      <th class="emptyheader">&#160;</th>
                    </xsl:otherwise>
                  </xsl:choose>
                  <!-- gather the actual verb-ending data in this grouping:
                    all elements whose
                    - group1 attribute matches the current group1 value and
                    - group2 attribute matches the current group2 value
                    - group3 attribute matches the current group3 value
                  -->
                  <xsl:variable name="data"
                    select="$a_rowgroupdata/@*[local-name(.)=$group1Variable
                    and .=$lastgroup1]/../@*[local-name(.)=$e_group2
                    and . = $lastgroup2]/../@*[local-name(.)=$e_group3
                    and .= $lastgroup3]/.."/>
                  <xsl:call-template name="rowgroup">
                    <xsl:with-param name="a_data" select="$data"/>
                    <xsl:with-param name="a_groupheader" select="$lastgroup3"/>
                    <xsl:with-param name="a_colspan" select="$a_dataCols div count($data)"/>
                  </xsl:call-template>
                </tr>
              </xsl:if>
            </xsl:for-each>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <!-- template to write a group of rows of verb-ending data to the table -->
  <xsl:template name="rowgroup">
    <xsl:param name="a_data"/>
    <xsl:param name="a_groupheader"/>
    <xsl:param name="a_colspan"/>
    <xsl:for-each select="$a_data">
      <xsl:sort
        select="/infl-data/order-table/order-item[@attname='voice'
        and text()=current()/@*[local-name(.)='voice']]/@order"
        data-type="number"/>
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
      <xsl:variable name="selected">
        <xsl:call-template name="check-infl-sets">
          <xsl:with-param name="a_currentData" select="current()" />
        </xsl:call-template>
      </xsl:variable>
      <!--div class="debug_sel"><xsl:value-of select="$selected"/></div-->
      <xsl:call-template name="ending-cell">
        <xsl:with-param name="a_verbEndings" select="infl-form"/>
        <xsl:with-param name="a_colspan" select="$a_colspan"/>
        <xsl:with-param name="a_selected" select="$selected"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="headerrow">
    <xsl:param name="a_headerrow1"/>
    <xsl:for-each select="$a_headerrow1">
       <td>&#160;</td>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="add-footnote">
    <xsl:param name="a_item"/>
    <xsl:if test="$a_item/@footnote">
      <a href="#{$a_item/@footnote}" class="footnote"><xsl:value-of select="substring-after($a_item/@footnote,'-')"/></a>
      <span class="footnote-text"><xsl:value-of select="key('s_footnotes',$a_item/@footnote)"/></span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="ending-cell">
    <xsl:param name="a_verbEndings"/>
    <xsl:param name="a_selected"/>
    <xsl:param name="a_colspan"/>
    <td>
      <xsl:for-each select="$a_verbEndings">
        <xsl:variable name="entries" select="count($e_selectedEndings/*[@class='alph-entry'])"/>
        <xsl:variable name="selectedClass">
          <!-- if this ending matches the one supplied in the template params
            then add a 'selected' class to the data element -->
          <xsl:if test="$a_selected &gt; 0">selected</xsl:if>
        </xsl:variable>
        <xsl:variable name="notfirst">
          <xsl:if test="position() &gt; 1">notfirst</xsl:if>
        </xsl:variable>
        <span class="ending {@type} {$selectedClass} {$notfirst}">
          <xsl:value-of select="."/>
        </span>
        <xsl:call-template name="add-footnote">
          <xsl:with-param name="a_item" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </td>
    <xsl:call-template name="emptycell">
      <xsl:with-param name="a_counter" select="$a_colspan"/>
    </xsl:call-template>
  </xsl:template>

  <!-- template to produce colgroups for the table columns -->
  <xsl:template name="colgroups">
    <xsl:param name="a_includeVoice"/>
    <colgroup class="leftheader">
      <col realIndex="0"/>
      <col realIndex="1"/>
    </colgroup>
    <xsl:choose>
      <xsl:when test="$a_includeVoice = 'true'">
        <colgroup class="header1">
          <col realIndex="2"/>
          <col realIndex="3"/>
        </colgroup>
        <colgroup class="header1">
          <col realIndex="4"/>
          <col realIndex="5"/>
        </colgroup>
      </xsl:when>
      <xsl:otherwise>
        <colgroup class="header2">
          <col realIndex="2" colspan="1"/>
        </colgroup>
        <colgroup class="header1">
          <col realIndex="3" colspan="1"/>
        </colgroup>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="headers">
    <xsl:param name="a_headerrow1"/>
    <xsl:param name="a_includeVoice"/>
    <xsl:param name="a_colspan"/>
    <!-- add the voice header row -->
    <xsl:if test="$a_includeVoice = 'true'">
      <tr id="headerrow1-irreg">
        <th colspan="2" class="always-visible">
          <span class="header-text">voice</span>
        </th>
        <xsl:for-each select="//order-item[@attname='voice']">
          <xsl:sort select="/infl-data/order-table/order-item[@attname='voice'
            and text()=current()]/@voice" data-type="number"/>
          <th colspan="2">
            <span class="header-text"><xsl:value-of select="."/></span>
          </th>
        </xsl:for-each>
      </tr>
    </xsl:if>
    <tr id="headerrow1">
      <th colspan="2" class="always-visible">
        <span class="header-text"><xsl:value-of select="'mood'"/></span>
      </th>
      <xsl:choose>
        <xsl:when test="$a_includeVoice = 'true'">
          <xsl:for-each select="//order-item[@attname='voice']">
            <xsl:sort select="/infl-data/order-table/order-item[@attname='voice'
            and text()=current()]/@voice" data-type="number"/>
            <xsl:for-each select="$a_headerrow1">
              <xsl:sort select="@order" data-type="number"/>
              <th>
                <span class="header-text"><xsl:value-of select="."/></span>
              </th>
            </xsl:for-each>
            <xsl:variable name="counter" select="$a_colspan div 2"/>
            <xsl:call-template name="emptyheader">
              <xsl:with-param name="a_counter" select="$counter"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$a_headerrow1">
            <xsl:sort select="@order" data-type="number"/>
            <th>
              <span class="header-text"><xsl:value-of select="."/></span>
            </th>
          </xsl:for-each>
          <xsl:call-template name="emptyheader">
            <xsl:with-param name="a_counter" select="$a_colspan"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </tr>
  </xsl:template>

  <xsl:template name="check-infl-sets">
    <xsl:param name="a_currentData"/>
    <xsl:variable name="matches">
      <xsl:for-each select="$e_selectedEndings//*[@class='alph-infl-set']">
        <xsl:for-each select="*[@class='alph-infl']">
          <xsl:call-template name="find-infl-match">
            <xsl:with-param name="a_currentData" select="$a_currentData"/>
            <xsl:with-param name="a_filteredData" select="(.)"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <!--xsl:value-of select="$matches"/-->
    <xsl:choose>
      <xsl:when test="contains($matches,'1')">
        1
      </xsl:when>
      <xsl:otherwise>
        0
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="find-infl-match">
    <xsl:param name="a_currentData"/>
    <xsl:param name="a_filteredData"/>
    <xsl:param name="a_attPos" select="0"/>
    <xsl:variable name="numAtts" select="count($a_currentData/@*)"/>
    <xsl:choose>
      <xsl:when test="$a_attPos = $numAtts">
        <xsl:value-of select="count($a_filteredData)"/>
        <!-- if we have tested all the possible attributes return the match count-->
        <!--xsl:value-of select="count($a_filteredData)"/-->
        <!--xsl:if test="boolean(exsl:node-set($a_filteredData))"><div class="debug_fil">blip</div></xsl:if-->
      </xsl:when>
      <xsl:when test="($a_attPos &lt; $numAtts) and $a_filteredData">
        <!-- variables are: voice, mood, tense, num, person, and case -->
        <!-- only try match if current conjugation data element has the attribute -->
        <xsl:for-each select="$a_currentData/@*">
          <xsl:if test="position() = $a_attPos + 1">
            <xsl:variable name="attName" select="name()"/>
            <xsl:variable name="className">
               <xsl:value-of select="concat('alph-',$attName)"/>
            </xsl:variable>
            <!-- TODO - this is incorrect when multiple infl elements with combination of match (e.g. see feram) -->
            <xsl:variable name="latestData"
              select="$a_filteredData[
              ((*[@class=$className]/text() = $a_currentData/@*[local-name(.)=$attName])
              or
               (*[@class=$className]/@context = $a_currentData/@*[local-name(.)=$attName])
              )
              ]"/>

            <!--div class="debug_testrecurs">
              Postion: <xsl:value-of select="$a_attPos"/>
              Attribute: <xsl:value-of select="$attName"/>
              Class: <xsl:value-of select="$className"/>
              Tense: <xsl:value-of select="$a_currentData/@tense"/>
              </div-->

            <xsl:call-template name="find-infl-match">
              <xsl:with-param name="a_currentData" select="$a_currentData"/>
              <xsl:with-param name="a_filteredData"
                select="$latestData"/>
              <xsl:with-param name="a_attPos" select="$a_attPos+1"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- empty cells to fill row -->
  <xsl:template name="emptycell">
    <xsl:param name="a_counter"/>
    <xsl:if test="$a_counter &gt; 1">
      <td class="emptycell">&#160;</td>
      <xsl:call-template name="emptycell">
        <xsl:with-param name="a_counter" select="$a_counter -1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- empty header cells to fill row -->
  <xsl:template name="emptyheader">
    <xsl:param name="a_counter"/>
    <xsl:if test="$a_counter &gt; 1">
      <th class="emptyheader">&#160;</th>
      <xsl:call-template name="emptyheader">
        <xsl:with-param name="a_counter" select="$a_counter -1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:exsl="http://exslt.org/common">
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
     Stylesheet for transformation of paradigm tables
     Parameters per alph-infl-params.xsl

     Stylesheet-specific params:
       $e_paradigmId: list of paradigm ids to filter transformed paradigms to
       $e_queryMode: set to true if transformed output is for Quiz display
  -->

  <xsl:import href="alph-infl-params.xsl"/>
  <xsl:import href="alph-infl-extras.xsl"/>
  <xsl:import href="alph-infl-match.xsl"/>
  <xsl:import href="paradigm-match.xsl"/>

  <xsl:output encoding="UTF-8" indent="yes" method="html"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="e_paradigmId"/>
  <xsl:param name="e_queryMode" select="false()"/>

  <!-- debug -->
  <xsl:param name="e_testEndings">
    <div class="alph-entry"><div lemma-lex="lsj" lemma-lang="grc" lemma-id="n33457" lemma-key="ἐλαύνω" class="alph-dict"><span class="alph-hdwd">ἐλαύνω: </span><div class="alph-morph"><span context="verb" class="alph-pofs">verb</span></div></div><div class="alph-mean">drive, set in motion</div><div context="ἐλᾶ" class="alph-infl-set"><span class="alph-term">ἐλ-<span class="alph-suff">ᾶ</span></span><span context="Attic_Doric_Aeolic" class="alph-dial">(<span class="alph-nopad">Attic Doric Aeolic</span>)</span><span>(<span context="a_stem" class="alph-nopad alph-derivtype">d=a_stem</span>, <span context="aw_fut" class="alph-nopad alph-stemtype">s=aw_fut</span>, <span context="contr" class="alph-nopad alph-morphflags">m=contr</span>)</span><div class="alph-infl"><span context="1st" class="alph-pers">1st person</span><span context="singular" class="alph-num">singular;</span><span class="alph-tense">future</span><span context="indicative" class="alph-mood">indicative;</span><span class="alph-voice">active</span></div></div><div context="ἐλᾶ" class="alph-infl-set"><span class="alph-term">ἐλ-<span class="alph-suff">ᾶ</span></span><span context="epic_Doric_Aeolic" class="alph-dial">(<span class="alph-nopad">epic Doric Aeolic</span>)</span><span>(<span context="a_stem" class="alph-nopad alph-derivtype">d=a_stem</span>, <span context="aw_pr" class="alph-nopad alph-stemtype">s=aw_pr</span>, <span context="contr_poetic_rare" class="alph-nopad alph-morphflags">m=contr poetic rare</span>)</span><div class="alph-infl"><span context="1st" class="alph-pers">1st person</span><span context="singular" class="alph-num">singular;</span><span class="alph-tense">present</span><span context="subjunctive" class="alph-mood">subjunctive;</span><span class="alph-voice">active</span></div><div class="alph-infl"><span context="1st" class="alph-pers">1st person</span><span context="singular" class="alph-num">singular;</span><span class="alph-tense">present</span><span context="indicative" class="alph-mood">indicative;</span><span class="alph-voice">active</span></div></div></div>
    <!--div class="alph-entry">
      <div lemma-lex="lsj" lemma-lang="grc" lemma-id="n20598" lemma-key="βουλεύω" class="alph-dict">
        <span class="alph-hdwd">βουλεύω: </span>
        <div class="alph-morph">
          <span context="verb" class="alph-pofs">verb</span>
        </div>
      </div>
      <div class="alph-mean">take counsel, deliberate</div>
      <div context="βουλευω" class="alph-infl-set">
        <span class="alph-term">βουλευ-<span class="alph-suff">ω</span></span>
        <span>(<span context="euw" class="alph-nopad alph-derivtype">d=euw</span>,
          <span context="w_stem" class="alph-nopad alph-stemtype">s=w_stem</span>)
        </span>
        <div class="alph-infl">
          <span context="1st" class="alph-pers">1st person</span>
          <span context="singular" class="alph-num">singular;</span>
          <span class="alph-tense">present</span>
          <span context="indicative" class="alph-mood">indicative;</span>
          <span class="alph-voice">active</span>
        </div>
        <div class="alph-infl">
          <span context="1st" class="alph-pers">1st person</span>
          <span context="singular" class="alph-num">singular;</span>
          <span class="alph-tense">present</span>
          <span context="subjunctive" class="alph-mood">subjunctive;</span>
          <span class="alph-voice">active</span>
        </div>
      </div>
    </div-->
  </xsl:param>

  <!-- DEBUG -->
  <!--xsl:param name='e_selectedEndings' select="exsl:node-set($e_testEndings)"/-->

  <xsl:key name="s_footnotes" match="footnote" use="@id"/>

  <xsl:template match="/infl-paradigms">
    <xsl:variable name="tableNotes">
      <xsl:if test="@footnote">
        <div id="table-notes">
          <xsl:call-template name="add-footnote">
            <xsl:with-param name="a_item" select="."/>
          </xsl:call-template>
        </div>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="inflConstraintData">
      <xsl:if test="((not($e_paradigmId) or $e_paradigmId = 'all') and $e_selectedEndings)">
        <xsl:call-template name="get-paradigms-for-selection">
          <xsl:with-param name="a_matchTable" select="morpheus-paradigm-match"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="data">
      <xsl:variable name="paradigmList">
        <xsl:choose>
          <xsl:when test="$e_paradigmId">
            <xsl:value-of select="$e_paradigmId"/>
          </xsl:when>
          <xsl:when test="$inflConstraintData">
            <xsl:for-each select="exsl:node-set($inflConstraintData)/match_for_infl">
              <xsl:value-of select="@paradigm_id_ref"/>,
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>all</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$paradigmList='all'">
          <xsl:copy-of select="//infl-paradigm"/>
        </xsl:when>
        <xsl:when test="$paradigmList">
          <xsl:call-template name="get-paradigms">
            <xsl:with-param name="a_list" select="$paradigmList"/>
            <xsl:with-param name="a_delimiter" select="','"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$e_fragment">
        <xsl:copy-of select="$tableNotes"/>
        <div id="alph-infl-table">
          <div class="alph-infl-caption">
            <xsl:call-template name="form-caption">
              <xsl:with-param name="a_selectedEndings" select="$e_selectedEndings"/>
              <xsl:with-param name="a_form" select="$e_form"/>
              <xsl:with-param name="a_hasData" select="$data != ''"/>
            </xsl:call-template>
          </div>
          <xsl:choose>
            <xsl:when test="$data = ''">
              <xsl:apply-templates select="morpheus-paradigm-match/nomatch"/>
            </xsl:when>
            <xsl:when test="$e_selectedEndings and $e_paradigmId != 'all'">
              <div class="alpheios-hint">
                <xsl:text>The following table(s) show conjugation patterns for verbs which are similar to those of </xsl:text>
                <xsl:element name="span">
                  <xsl:attribute name="class">alph-infl-form</xsl:attribute>
                  <xsl:value-of select="$e_form"/>.
                </xsl:element>
              </div>
            </xsl:when>
          </xsl:choose>
          <xsl:call-template name="paradigms">
            <xsl:with-param name="a_paradigms" select="exsl:node-set($data)"/>
            <xsl:with-param name="a_inflConstraintData" select="exsl:node-set($inflConstraintData)/match_for_infl"/>
          </xsl:call-template>
          <xsl:if test="$data != ''">
            <xsl:apply-templates select="//disclaimer"/>
          </xsl:if>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <html>
          <head>
            <link rel="stylesheet" type="text/css" href="chrome://alpheios/skin/alph-infl.css"/>
            <link rel="stylesheet" type="text/css" href="chrome://alpheios/skin/alph-infl-paradigm.css"/>
            <xsl:if test="$e_matchPofs">
              <link rel="stylesheet" type="text/css" href="chrome://alpheios/skin/alph-infl-{$e_matchPofs}.css"/>
            </xsl:if>
          </head>
          <body>
            <xsl:copy-of select="$tableNotes"/>
            <div class="alph-infl-caption">
              <xsl:call-template name="form-caption">
                <xsl:with-param name="a_selectedEndings" select="$e_selectedEndings"/>
                <xsl:with-param name="a_form" select="$e_form"/>
                <xsl:with-param name="a_hasData" select="$data != ''"/>
              </xsl:call-template>
            </div>
            <xsl:if test="$data=''">
              <xsl:apply-templates select="morpheus-paradigm-match/nomatch"/>
            </xsl:if>
            <xsl:call-template name="paradigms">
              <xsl:with-param name="a_paradigms" select="exsl:node-set($data)"/>
              <xsl:with-param name="a_inflConstraintData" select="exsl:node-set($inflConstraintData)/match_for_infl"/>
            </xsl:call-template>
          </body>
        </html>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="paradigms">
    <xsl:param name="a_paradigms"/>
    <xsl:param name="a_inflConstraintData"/>
    <xsl:for-each select="$a_paradigms/infl-paradigm">
      <xsl:variable name="paradigmId" select="@id"/>
      <div id="{$paradigmId}">
        <div class="title"><xsl:apply-templates select="title"/></div>
        <xsl:if test="@lemmas">
          <xsl:variable name="lemmaList" select="@lemmas"/>
          <div class="paradigm-links"><a class="alph-lang-infl-link principal-parts" href="{concat('#',$lemmaList)}">Principal Parts >></a></div>
        </xsl:if>
        <xsl:for-each select="paradigm-class">
          <div class="paradigm-class">
            <xsl:apply-templates select="title"/>
            <xsl:call-template name="paradigm-table">
              <xsl:with-param name="a_tables" select="table"/>
              <xsl:with-param name="a_inflConstraintData"
                select="$a_inflConstraintData[@paradigm_id_ref = $paradigmId]"/>
            </xsl:call-template>
          </div>
        </xsl:for-each>
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="paradigm-table">
    <xsl:param name="a_tables"/>
    <xsl:param name="a_inflConstraintData"/>
    <xsl:for-each select="$a_tables">
      <xsl:element name="table">
        <xsl:attribute name="class"><xsl:value-of select="@role"/></xsl:attribute>
        <xsl:for-each select="row">
          <xsl:element name="tr">
            <xsl:attribute name="class"><xsl:value-of select="@role"/></xsl:attribute>
            <xsl:for-each select="cell">
              <xsl:if test="@role = 'label'">
                <xsl:element name="th">
                  <xsl:variable name="class">
                    <xsl:if test="not(following-sibling::cell[1]/text())"><xsl:text>next-empty </xsl:text></xsl:if>
                    <xsl:if test="not(preceding-sibling::cell[1]/text())"><xsl:text>prev-empty </xsl:text></xsl:if>
                    <xsl:if test="../@role='data' and following-sibling::cell[1]/@role[. = 'label']"><xsl:text>next-label </xsl:text></xsl:if>
                    <xsl:if test="../@role='data' and preceding-sibling::cell[1]/@role[. = 'label']"><xsl:text>prev-label </xsl:text></xsl:if>
                    <xsl:if test="not(text())"><xsl:text>empty-cell </xsl:text></xsl:if>
                  </xsl:variable>
                  <xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute>
                  <xsl:for-each select="@*[local-name(.) !='role']">
                    <xsl:attribute name="{concat('alph-',local-name(.))}"><xsl:value-of select="."/></xsl:attribute>
                  </xsl:for-each>
                  <xsl:apply-templates/>
                </xsl:element>
              </xsl:if>
              <xsl:if test="@role='data'">
                <xsl:variable name="selected">
                  <xsl:if test="$e_selectedEndings and not($e_queryMode)">
                    <xsl:call-template name="check-infl-sets">
                      <xsl:with-param name="a_selectedEndings"
                        select="$e_selectedEndings"/>
                      <xsl:with-param name="a_currentData" select="."/>
                      <xsl:with-param name="a_matchPofs" select="$e_matchPofs"/>
                      <xsl:with-param name="a_inflConstraint"
                        select="$a_inflConstraintData"/>
                    </xsl:call-template>
                  </xsl:if>
                </xsl:variable>
                <xsl:element name="td">
                  <xsl:attribute name="class">
                    <!-- don't highlight empty cells -->
                    <xsl:if test="($selected != '') and (text() or child::*/text())">
                      <xsl:text>selected </xsl:text>
                    </xsl:if>
                    <xsl:text>ending-group</xsl:text>
                  </xsl:attribute>
                  <xsl:for-each select="@*[local-name(.) !='role']">
                    <xsl:attribute name="{concat('alph-',local-name(.))}">
                      <xsl:value-of select="concat('|', translate(.,' ','|'), '|')"/>
                    </xsl:attribute>
                  </xsl:for-each>
                  <xsl:call-template name="add-footnote">
                    <xsl:with-param name="a_item" select="."/>
                  </xsl:call-template>
                  <xsl:apply-templates/>

                  <!--
                  <div class="attributes">
                    <xsl:for-each select="@*[local-name(.) !='role']">
                      <xsl:value-of select="."/>
                      <xsl:text> </xsl:text>
                    </xsl:for-each>
                  </div>
                  -->
                </xsl:element>
              </xsl:if>
            </xsl:for-each>
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="span">
    <xsl:element name="span">
      <xsl:attribute name="xml:lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
      <xsl:if test="$e_queryMode">
        <xsl:attribute name="class">ending</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="get-paradigms">
    <xsl:param name="a_list" />
    <xsl:param name="a_seen"/>
    <xsl:param name="a_delimiter" />
    <xsl:variable name="newlist">
      <xsl:choose>
        <xsl:when test="contains($a_list, $a_delimiter)"><xsl:value-of select="normalize-space($a_list)" /></xsl:when>
        <xsl:otherwise><xsl:value-of select="concat(normalize-space($a_list), $a_delimiter)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="first" select="substring-before($newlist, $a_delimiter)" />
    <!-- get rid of duplicates -->
    <xsl:variable name="remaining" select="substring-after($newlist, $a_delimiter)" />
    <!-- eliminate duplicates -->
    <xsl:if test="not(contains($a_seen,concat($a_delimiter,$first,$a_delimiter)))">
      <xsl:copy-of select="//infl-paradigm[@id=$first]"/>
    </xsl:if>
    <xsl:if test="$remaining">
      <xsl:call-template name="get-paradigms">
        <xsl:with-param name="a_list" select="$remaining" />
        <xsl:with-param name="a_seen" select="concat($a_seen,$a_delimiter,$first,$a_delimiter)"/>
        <xsl:with-param name="a_delimiter"><xsl:value-of select="$a_delimiter"/></xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="get-paradigms-for-selection">
    <xsl:param name="a_matchTable"/>
    <!-- for each inflection set
        get alph-dial, alph-stemtype, alph-morphflags, alph-derivtype
        look for item in morpheus-paradigm-match which has the same attributes
        if multiple take one which most matched attributes?
    -->
    <xsl:for-each select="$e_selectedEndings//*[@class='alph-infl']">
      <xsl:variable name="infl" select="current()"/>
      <xsl:variable name="matchElems">
        <xsl:for-each select="$a_matchTable/match">
          <xsl:call-template name="check-constrained-match">
            <xsl:with-param name="a_matchElem" select="current()"/>
            <xsl:with-param name="a_infl" select="$infl"/>
            <xsl:with-param name="a_inflId" select="generate-id($infl)"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="bestMatches">
        <xsl:call-template name="best-match">
          <xsl:with-param name="a_nodes" select="exsl:node-set($matchElems)"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:copy-of select="$bestMatches"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="check-constrained-match">
    <xsl:param name="a_infl"/>
    <xsl:param name="a_matchElem"/>
    <xsl:param name="a_inflId"/>
    <xsl:param name="a_num" select="1"/>
    <xsl:variable name="numConstraints" select="count($a_matchElem/constraint)"/>
    <xsl:variable name="attName"
                  select="concat('alph-',$a_matchElem/constraint[$a_num]/@name)"/>

    <xsl:variable name="matched">

      <xsl:choose>
        <!-- special handling for lemma -->
        <xsl:when test="$attName = 'alph-lemma'">
          <xsl:if
            test="$a_infl/ancestor::*[@class='alph-infl-set']
              /preceding-sibling::*[@class='alph-dict']/@lemma-key
                = $a_matchElem/constraint[$a_num]/text()">1
          </xsl:if>
            <xsl:if 
                test="substring-before($a_infl/ancestor::*[@class='alph-infl-set']
                    /preceding-sibling::*[@class='alph-dict']/@lemma-key,'1')
                    = $a_matchElem/constraint[$a_num]/text()">1
            </xsl:if>
        </xsl:when>
        <!-- pofs may be on inflection set or dict -->
        <xsl:when test="$attName = 'alph-pofs'">
          <xsl:variable name="matchTextLower"
            select="translate($a_matchElem/constraint[$a_num]/text(),
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
          <xsl:if test="
            ($a_infl/ancestor::*[@class='alph-infl-set']
              /preceding-sibling::*[contains(@class,'alph-dict')]//*
                [contains(@class,'alph-pofs')
                 and
                 contains(
                  translate(concat('|',@context,'|'),
                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),
                  concat('|',$matchTextLower,'|'))
                ]
             )
             or
             ($a_infl/ancestor::*[@class='alph-infl-set']//*
               [contains(@class,'alph-pofs')
               and
               contains(
                 translate(concat('|',@context,'|'),
                 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),
                 concat('|',$matchTextLower,'|'))
               ]
             )">1</xsl:if>
        </xsl:when>
        <!-- inflection_set atts -->
        <xsl:when test="
          ($attName = 'alph-stemtype') or
          ($attName = 'alph-derivtype') or
          ($attName = 'alph-morphflags') or
          ($attName = 'alph-dial')">
          <xsl:variable name="matchTextLower"
            select="translate($a_matchElem/constraint[$a_num]/text(),
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
          <xsl:if test="$a_infl/ancestor::*[@class='alph-infl-set']//*[contains(@class,$attName)
            and
            ((translate(text(),
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')= $matchTextLower)
            or
            (contains(
            translate(concat('|',@context,'|'),
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),
            concat('|',$matchTextLower,'|')
            )
            ))
            ]">1
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="matchTextLower"
            select="translate($a_matchElem/constraint[$a_num]/text(),
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
          <xsl:if test="$a_infl//*[contains(@class,$attName)
            and
            ((translate(text(),
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')= $matchTextLower)
            or
            (contains(
            translate(concat('|',@context,'|'),
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),
            concat('|',$matchTextLower,'|')
            )
            ))
            ]">1
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$numConstraints = $a_num">
        <xsl:if test="$matched=1">
          <xsl:element name="match_for_infl">
            <xsl:attribute name="infl_id">
              <xsl:value-of select="$a_inflId"/>
            </xsl:attribute>
            <xsl:attribute name="match_order">
              <xsl:value-of select="$a_matchElem/@match_order"/>
            </xsl:attribute>
            <xsl:attribute name="paradigm_id_ref">
              <xsl:value-of select="@paradigm_id_ref"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$matched=1">
        <xsl:call-template name="check-constrained-match">
          <xsl:with-param name="a_num" select="number($a_num+1)"/>
          <xsl:with-param name="a_infl" select="$a_infl"/>
          <xsl:with-param name="a_inflId" select="$a_inflId"/>
          <xsl:with-param name="a_matchElem" select="$a_matchElem"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="best-match">
    <xsl:param name="a_nodes"/>
    <!-- when looking for the best match, we need to look at the matches
       for each inflection separately
    -->
    <xsl:if test="$a_nodes">
      <xsl:variable name="inflIds" select="$a_nodes/match_for_infl/@infl_id"/>
      <xsl:for-each select="$inflIds">
        <xsl:variable name="lastInflId" select="."/>
        <xsl:if test="generate-id(.) = generate-id($inflIds[.=current()])">
          <xsl:variable name="max">
            <xsl:for-each select="$a_nodes/match_for_infl[@infl_id=$lastInflId]">
              <xsl:sort select="@match_order"
                data-type="number"
                order="descending"/>
              <xsl:if test="position() = 1">
                <xsl:value-of select="number(@match_order)" />
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:for-each select="$a_nodes/match_for_infl
            [(@infl_id=$lastInflId) and (number(@match_order) = $max)]">
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template match="nomatch">
    <div class="paradigm-nomatch"><xsl:apply-templates/></div>
  </xsl:template>
</xsl:stylesheet>

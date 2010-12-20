<?xml version="1.0" encoding="UTF-8"?>

<!--
  Copyright 2008-2010 Cantus Foundation
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
  Stylesheet for transforming lexicon output to HTML
-->

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:exsl="http://exslt.org/common"
  version="1.0"
  exclude-result-prefixes="xs">

  <xsl:import href="beta2unicode.xsl"/>
  <xsl:import href="arabic-uni-util.xsl"/>

  <xsl:template match="/">
    <html>
      <head>
        <link rel="stylesheet" type="text/css" href="alpheios.css"/>
      </head>
      <body>
        <div id="alph-text">
          <xsl:apply-templates select="//word|//error|//unknown"/>
          <div id="alph-morph-credits"></div>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="word">
    <div class="alph-word">
      <!-- set context to word form if present -->
      <!-- converting betacode to unicode if necessary -->
      <xsl:if test="form">
        <xsl:attribute name="context">
          <xsl:call-template name="convert-text">
            <xsl:with-param name="a_item" select="form"/>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>

      <!-- sort entries by decreasing frequency of occurrence -->
      <!-- and then by part of speech -->
      <!-- arbitrarily choosing the first in the rare case where multiple dict elements exist -->
      <xsl:for-each select="entry">
        <xsl:sort select="dict[1]/freq/@order" data-type="number"
          order="descending"/>
        <xsl:sort select="dict[1]/pofs/@order" data-type="number"
          order="descending"/>

        <div class="alph-entry">

          <!-- process dictionary info and meanings -->
          <xsl:for-each select="dict|mean">
            <xsl:apply-templates select="."/>
          </xsl:for-each>

          <xsl:variable name="inflSets">
          <!-- process all forms having no dialect -->
          <xsl:for-each select="infl[not(dial)]">
            <xsl:sort select="term/stem"/>
            <xsl:sort select="term/pref"/>
            <xsl:sort select="term/suff"/>
            <xsl:sort select="pofs/@order" data-type="number" order="descending"/>
            <xsl:variable name="preceding"
              select="preceding-sibling::infl[(term/stem=current()/term/stem) and
                                              ((not(term/pref) and not(current()/term/pref)) or
                                              (term/pref=current()/term/pref))and
                                              ((not(term/suff) and not(current()/term/suff)) or
                                               (term/suff=current()/term/suff)) and
                                              (pofs=current()/pofs) and
                                              ((not(comp) and not(current()/comp)) or
                                               (comp=current()/comp)) and
                                               not(dial)]"/>
            <xsl:if test="count($preceding) = 0">
              <!-- process all inflections having this form (stem and part-of-speech) -->
              <xsl:call-template name="inflection-set">
                <xsl:with-param name="a_in"
                  select="../infl[(term/stem=current()/term/stem) and
                                  ((not(term/pref) and not(current()/term/pref)) or
                                  (term/pref=current()/term/pref))and
                                  ((not(term/suff) and not(current()/term/suff)) or
                                  (term/suff=current()/term/suff)) and
                                  (pofs=current()/pofs) and
                                  ((not(comp) and not(current()/comp)) or
                                  (comp=current()/comp)) and
                                  not(dial)]"
                />
              </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
          <!-- handle any forms that have no dialect and no stem or part of speech-->
          <xsl:call-template name="inflection-set">
            <xsl:with-param name="a_in"
              select="infl[not(dial) and (not(term/stem) or not(pofs))]"/>
          </xsl:call-template>
          <!-- process all forms having dialect -->
          <xsl:for-each select="infl[dial]">
            <xsl:sort select="term/stem"/>
            <xsl:sort select="term/pref"/>
            <xsl:sort select="term/suff"/>
            <xsl:sort select="pofs/@order" data-type="number" order="descending"/>
            <xsl:sort select="dial"/>
            <xsl:variable name="preceding"
              select="preceding-sibling::infl[(term/stem=current()/term/stem) and
                                              ((not(term/pref) and not(current()/term/pref)) or
                                              (term/pref=current()/term/pref))and
                                              ((not(term/suff) and not(current()/term/suff)) or
                                              (term/suff=current()/term/suff)) and
                                              (pofs=current()/pofs) and
                                              (dial=current()/dial) and
                                              ((not(comp) and not(current()/comp)) or
                                               (comp=current()/comp)) and
                                              dial]">
            </xsl:variable>
            <xsl:if test="count($preceding) = 0">
              <!-- process all inflections having this form (stem and part-of-speech) -->
              <xsl:call-template name="inflection-set">
                <xsl:with-param name="a_in"
                  select="../infl[(term/stem=current()/term/stem) and
                                  ((not(term/pref) and not(current()/term/pref)) or
                                  (term/pref=current()/term/pref))and
                                  ((not(term/suff) and not(current()/term/suff)) or
                                  (term/suff=current()/term/suff)) and
                                  (pofs=current()/pofs) and
                                  (dial=current()/dial) and
                                  ((not(comp) and not(current()/comp)) or
                                   (comp=current()/comp)) and
                                  dial]"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
          <!-- handle any forms that have dialect and no stem or part of speech-->
          <xsl:for-each select="infl[dial and (not(term/stem) or not(pofs))]">
            <xsl:sort select="dial"/>
            <xsl:variable name="preceding"
              select="preceding-sibling::infl[(dial=current()/dial) and
                                              ((not(comp) and not(current()/comp)) or
                                               (comp=current()/comp)) and
                                              dial and
                                              (not(term/stem) or not(pofs))]"/>
            <xsl:if test="count($preceding) = 0">
              <xsl:call-template name="inflection-set">
                <xsl:with-param name="a_in"
                  select="../infl[(dial=current()/dial) and
                                  ((not(comp) and not(current()/comp)) or
                                   (comp=current()/comp)) and
                                   dial and
                                   (not(term/stem) or not(pofs))]"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
          </xsl:variable>

          <!-- process inflected forms -->
          <xsl:if test="$inflSets != ''">
            <!-- one label for all forms -->
            <div class="alpheios-label alpheios-form-label">Form(s):</div>
            <xsl:copy-of select="$inflSets"/>
          </xsl:if>

        </div>
      </xsl:for-each>
      <!-- end for each entry -->
    </div>
  </xsl:template>
  <!-- end match word -->

  <xsl:template match="unknown">
    <div class="alph-unknown">
      <xsl:text>Unknown: </xsl:text>
      <span class="alph-hdwd">
        <xsl:call-template name="convert-text">
          <xsl:with-param name="a_item" select="."/>
        </xsl:call-template>
      </span>
    </div>
  </xsl:template>

  <xsl:template match="error">
    <div class="alph-error">
      <xsl:text>Error: </xsl:text>
      <span class="alph-hdwd">
        <xsl:value-of select="."/>
      </span>
    </div>
  </xsl:template>

  <xsl:template match="dict">
    <xsl:element name="div">
      <xsl:attribute name="class">alph-dict</xsl:attribute>
      <xsl:attribute name="lemma-key">
        <xsl:call-template name="convert-text">
          <xsl:with-param name="a_item" select="hdwd"/>
        </xsl:call-template>
      </xsl:attribute>

      <!-- define order in which elements should appear -->
      <xsl:choose>
        <xsl:when test="hdwd">
          <xsl:call-template name="item-plus-text">
            <xsl:with-param name="a_item" select="hdwd"/>
            <xsl:with-param name="a_suffix" select="': '"/>
            <xsl:with-param name="a_stripSense" select="true()"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="../infl[1]/term">
          <xsl:variable name="hdwd">
            <hdwd>
              <xsl:attribute name="xml:lang">
                <xsl:value-of select="../infl[1]/term/@xml:lang"/>
              </xsl:attribute>
              <xsl:for-each select="../infl[1]/term/*">
                <xsl:value-of select="./text()"/>
              </xsl:for-each>
            </hdwd>
          </xsl:variable>
          <span class="alph-hdwd">
            <xsl:call-template name="convert-text">
              <xsl:with-param name="a_item" select="exsl:node-set($hdwd)"/>
              <xsl:with-param name="a_stripSense" select="true()"/>
            </xsl:call-template>
            <xsl:text>: </xsl:text>
          </span>
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="item-plus-text">
        <xsl:with-param name="a_item" select="pron"/>
        <xsl:with-param name="a_prefix" select="'['"/>
        <xsl:with-param name="a_suffix" select="'] '"/>
      </xsl:call-template>

      <!-- Note:  Only one of case, gender, or kind can appear,
           depending on part of speech, therefore we can pass all
           through a single parameter -->
      <xsl:element name="div">
        <xsl:attribute name="class">alph-morph</xsl:attribute>
        <xsl:choose>
          <xsl:when test="pofs">
            <xsl:call-template name="part-of-speech">
              <xsl:with-param name="a_attr" select="case|gend|kind"/>
              <xsl:with-param name="a_pofs" select="pofs"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="../infl[1]/pofs">
            <xsl:call-template name="part-of-speech">
              <xsl:with-param name="a_attr" select="case|gend|kind"/>
              <xsl:with-param name="a_pofs" select="../infl[1]/pofs"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
        <xsl:variable name="pofs">
          <xsl:choose>
            <xsl:when test="pofs">
              <xsl:value-of select="pofs"/>
            </xsl:when>
            <xsl:when test="../infl[1]/pofs">
              <xsl:value-of select="../infl[1]/pofs"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="decl">
            <xsl:call-template name="declension">
              <xsl:with-param name="a_item" select="decl"/>
              <xsl:with-param name="a_pofs" select="$pofs"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="../infl[1]/decl">
            <xsl:call-template name="declension">
              <xsl:with-param name="a_item" select="../infl[1]/decl"/>
              <xsl:with-param name="a_pofs" select="$pofs"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="conj">
            <xsl:call-template name="item-plus-text-plus-context">
              <xsl:with-param name="a_item" select="conj"/>
              <xsl:with-param name="a_suffix" select="' conjugation'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="../infl[1]/conj">
            <xsl:call-template name="item-plus-text-plus-context">
              <xsl:with-param name="a_item" select="../infl[1]/conj"/>
              <xsl:with-param name="a_suffix" select="' conjugation'"/>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
        <xsl:call-template name="parenthesize">
          <xsl:with-param name="a_items" select="age|area|geo|freq"/>
          <xsl:with-param name="a_spanName">attrlist</xsl:with-param>
          <xsl:with-param name="a_spanContext"/>
        </xsl:call-template>
        <xsl:call-template name="item-plus-text">
          <xsl:with-param name="a_item" select="src"/>
          <xsl:with-param name="a_prefix" select="'['"/>
          <xsl:with-param name="a_suffix" select="']'"/>
        </xsl:call-template>
        <xsl:call-template name="item-plus-text">
          <xsl:with-param name="a_item" select="note"/>
        </xsl:call-template>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <xsl:template match="mean">
    <div class="alph-mean">
      <xsl:value-of select="."/>
    </div>
  </xsl:template>

  <xsl:template name="part-of-speech">
    <xsl:param name="a_attr"/>
    <xsl:param name="a_pofs"/>

    <xsl:if test="$a_attr|$a_pofs">
      <span class="alph-pofs" context="{translate($a_pofs,' ','_')}">
        <xsl:choose>
          <!-- say "verb taking <x>" rather than "taking <x> verb" -->
          <xsl:when test="starts-with($a_attr,'taking ')">
            <xsl:value-of select="$a_pofs"/>
            <xsl:text> </xsl:text>
            <span class="alph-attr">
              <xsl:value-of select="$a_attr"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <!-- all other attributes come before part of speech-->
            <xsl:if test="$a_attr">
              <span class="alph-attr">
                <xsl:value-of select="$a_attr"/>
              </span>
            </xsl:if>
            <xsl:value-of select="$a_pofs"/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="parenthesize">
    <xsl:param name="a_items"/>
    <xsl:param name="a_spanName"/>
    <xsl:param name="a_spanContext"/>

    <xsl:if test="$a_items">
      <span>
        <!-- if argument specifies class -->
        <xsl:if test="$a_spanName">
          <xsl:attribute name="class">
            <xsl:value-of select="concat('alph-', $a_spanName)"/>
          </xsl:attribute>
        </xsl:if>

        <!-- if argument specifies context -->
        <xsl:if test="$a_spanContext">
          <xsl:attribute name="context">
            <xsl:value-of select="translate($a_spanContext, ' ', '_')"/>
          </xsl:attribute>
        </xsl:if>

        <xsl:text>(</xsl:text>

        <!-- for each item supplied -->
        <xsl:for-each select="$a_items">
          <xsl:if test="position() != 1">, </xsl:if>
          <span>
            <xsl:attribute name="class">
              <xsl:choose>
                <!-- if item specifies class -->
                <xsl:when test="./@span-name">
                  <xsl:value-of
                    select="concat('alph-nopad alph-', ./@span-name)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>alph-nopad</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>

            <!-- if item specifies context -->
            <xsl:if test="./@span-context">
              <xsl:attribute name="context">
                <xsl:value-of select="translate(./@span-context, ' ', '_')"/>
              </xsl:attribute>
            </xsl:if>

            <xsl:value-of select="."/>
          </span>
        </xsl:for-each>

        <xsl:text>)</xsl:text>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template name="inflection-set">
    <xsl:param name="a_in"/>
    <xsl:variable name="pofs" select="$a_in[1]/pofs"/>

    <!-- if non-empty set -->
    <!-- ignore various parts of speech for which -->
    <!-- inflection adds nothing to dict info -->
    <xsl:if
      test="$a_in and
           (not($pofs) or
            (($pofs != 'conjunction') and
             ($pofs != 'preposition') and
             ($pofs != 'interjection') and
             ($pofs != 'particle')))">
      <!-- add the term as the value of the context attribute for the
                 inflection set -->
      <xsl:variable name="comp" select="$a_in[1]/comp"/>
      <div class="alph-infl-set">
        <xsl:attribute name="context">
          <xsl:call-template name="convert-text">
            <xsl:with-param name="a_item" select="$a_in[1]/term"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:apply-templates select="$a_in[1]/term"/>

        <!-- get pofs and decl from dictionary entry (or first inflection) -->
        <xsl:variable name="dictPofs">
          <xsl:choose>
            <xsl:when test="$a_in[1]/../dict[1]/pofs">
              <xsl:value-of select="$a_in[1]/../dict[1]/pofs"/>
            </xsl:when>
            <xsl:when test="$a_in[1]/../infl[1]/pofs">
              <xsl:value-of select="$a_in[1]/../infl[1]/pofs"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dictDecl">
          <xsl:choose>
            <xsl:when test="$a_in[1]/../dict[1]/decl">
              <xsl:value-of select="$a_in[1]/../dict[1]/decl"/>
            </xsl:when>
            <xsl:when test="$a_in[1]/../infl[1]/decl">
              <xsl:value-of select="$a_in[1]/../infl[1]/decl"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>

        <xsl:if test="($a_in[1]/pofs and not($a_in[1]/pofs = $dictPofs)) or
                      ($a_in[1]/decl and not($a_in[1]/decl = $dictDecl))">
          <span class="alph-nopad alph-formatting">(</span>
          <xsl:if test="$a_in[1]/pofs and not($a_in[1]/pofs = $dictPofs)">
            <xsl:call-template name="item-plus-text-plus-context">
              <xsl:with-param name="a_item" select="$a_in[1]/pofs"/>
              <xsl:with-param name="a_name" select="'pofs'"/>
              <xsl:with-param name="a_nopad" select="true()"/>
            </xsl:call-template>
            <xsl:if test="$a_in[1]/decl and not($a_in[1]/decl = $dictDecl)">
              <span class="alph-nopad alph-formatting">, </span>
            </xsl:if>
          </xsl:if>
          <xsl:if test="$a_in[1]/decl and not($a_in[1]/decl = $dictDecl)">
            <xsl:call-template name="declension">
              <xsl:with-param name="a_item" select="$a_in[1]/decl"/>
              <xsl:with-param name="a_pofs" select="$a_in[1]/pofs"/>
              <xsl:with-param name="a_nopad" select="true()"/>
            </xsl:call-template>
          </xsl:if>
          <span class="alph-formatting">)</span>
        </xsl:if>
        <xsl:call-template name="parenthesize">
          <xsl:with-param name="a_items" select="$a_in[1]/dial"/>
          <xsl:with-param name="a_spanName">dial</xsl:with-param>
          <xsl:with-param name="a_spanContext" select="$a_in[1]/dial"/>
        </xsl:call-template>

        <!-- extra info for matching, not displayed -->
        <xsl:if test="$a_in[1]/derivtype">
          <span>
            <xsl:attribute name="class">alph-nopad alph-derivtype</xsl:attribute>
            <xsl:attribute name="context">
              <xsl:value-of select="$a_in[1]/derivtype"/>
            </xsl:attribute>
          </span>
        </xsl:if>
        <xsl:if test="$a_in[1]/stemtype">
          <span>
            <xsl:attribute name="class">alph-nopad alph-stemtype</xsl:attribute>
            <xsl:attribute name="context">
              <xsl:value-of select="$a_in[1]/stemtype"/>
            </xsl:attribute>
          </span>
        </xsl:if>
        <xsl:if test="$a_in[1]/morph">
          <span>
            <xsl:attribute name="class">alph-nopad alph-morphflags</xsl:attribute>
            <xsl:attribute name="context">
              <xsl:value-of select="$a_in[1]/morph"/>
            </xsl:attribute>
          </span>
        </xsl:if>

        <!-- decide how to display form based on structure -->
        <xsl:choose>

          <!-- if inflections have case -->
          <xsl:when test="$a_in/case">
            <!-- possible number values and captions -->
            <xsl:variable name="values">
              <value>
                <xsl:attribute name="string">singular</xsl:attribute>
                <xsl:attribute name="caption">Singular</xsl:attribute>
              </value>
              <value>
                <xsl:attribute name="string">dual</xsl:attribute>
                <xsl:attribute name="caption">Dual</xsl:attribute>
              </value>
              <value>
                <xsl:attribute name="string">plural</xsl:attribute>
                <xsl:attribute name="caption">Plural</xsl:attribute>
              </value>
              <value>
                <xsl:attribute name="caption">Case</xsl:attribute>
              </value>
            </xsl:variable>
            <!-- for each possible number value -->
            <xsl:for-each select="exsl:node-set($values)/value">
              <xsl:if test="@string">
                <xsl:variable name="test" select="string(@string)"/>
                <xsl:call-template name="case-inflection-set">
                  <xsl:with-param
                    name="a_in"
                    select="$a_in[num = $test and (case|tense)]"/>
                  <xsl:with-param name="a_caption" select="@caption"/>
                </xsl:call-template>
                <xsl:if test="not(@string)">
                  <xsl:call-template name="case-inflection-set">
                    <xsl:with-param
                      name="a_in"
                      select="$a_in[not(num) and (case|tense)]"/>
                    <xsl:with-param name="a_caption" select="@caption"/>
                  </xsl:call-template>
                </xsl:if>
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
          <!-- end when inflections have case -->

          <!-- verb inflection -->
          <!-- verbs with tense -->
          <xsl:when test="$a_in/tense">
            <xsl:call-template name="verb-inflection-set">
              <xsl:with-param name="a_in" select="$a_in[tense]"/>
            </xsl:call-template>
          </xsl:when>

          <!-- verbs with no tense -->
          <xsl:when test="$a_in[1]/pofs = 'verb'">
            <div class="alph-infl">
              <xsl:call-template name="item-plus-text-plus-context">
                <xsl:with-param name="a_item" select="pers"/>
                <xsl:with-param name="a_suffix" select="' person'"/>
              </xsl:call-template>
              <xsl:call-template name="item-plus-text-plus-context">
                <xsl:with-param name="a_item" select="num"/>
                <xsl:with-param name="a_suffix" select="';'"/>
              </xsl:call-template>
              <xsl:call-template name="item-plus-text-plus-context">
                <xsl:with-param name="a_item" select="mood"/>
                <xsl:with-param name="a_suffix" select="';'"/>
              </xsl:call-template>
              <xsl:apply-templates select="voice"/>    
              <xsl:apply-templates select="$a_in/xmpl"/>
            </div>
          </xsl:when>
          <!-- end verb inflection -->

          <!-- adverb inflection -->
          <xsl:when test="$a_in[1]/pofs = 'adverb'">
            <xsl:if test="($comp and ($comp != 'positive')) or $a_in/xmpl">
              <div class="alph-infl">
                <xsl:apply-templates select="comp"/>
                <xsl:apply-templates select="$a_in/xmpl"/>                
              </div>
            </xsl:if>            
          </xsl:when>
          <!-- end adverb inflection -->
          
          <!-- miscellaneous others -->
          <xsl:otherwise>
            <div class="alph-infl">
              <xsl:apply-templates select="gend"/>
              <xsl:if test="$comp and ($comp != 'positive')">
                <xsl:apply-templates select="comp"/>
              </xsl:if>            
              <xsl:apply-templates select="$a_in/xmpl"/>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="case-inflection-set">
    <xsl:param name="a_in"/>
    <xsl:param name="a_caption"/>

    <xsl:for-each select="$a_in">
      <xsl:sort select="case/@order" data-type="number" order="descending"/>
      <xsl:variable name="curPos" select="position()"/>
      <xsl:variable name="curKey" select="concat(tense, '|', voice)"/>
      <xsl:variable name="test">
        <xsl:for-each select="$a_in">
          <xsl:sort select="case/@order" data-type="number" order="descending"/>
          <!-- if this is preceding inflection -->
          <xsl:if test="$curPos > position()">
            <xsl:variable name="key" select="concat(tense, '|', voice)"/>
            <!-- and same tense/voice -->
            <xsl:if test="$curKey = $key">
              <!-- flag it -->
              <xsl:text>1</xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <!-- if this is tense/voice combo we haven't seen yet -->
      <xsl:if test="string-length($test) = 0">
        <div class="alph-infl">
          <!-- put out heading -->
          <xsl:value-of select="$a_caption"/>
          <xsl:if test="tense">
            <xsl:text> </xsl:text>
            <xsl:call-template name="item-plus-text-plus-context">
              <xsl:with-param name="a_item" select="tense"/>
              <xsl:with-param name="a_nopad" select="true()"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="voice">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="voice">
              <xsl:with-param name="a_nopad" select="true()"/>
            </xsl:apply-templates>
          </xsl:if>
          <xsl:text>: </xsl:text>
          <xsl:call-template name="tense-voice-inflection-set">
            <xsl:with-param
              name="a_in"
              select="$a_in[concat(tense, '|', voice) = $curKey]"/>
          </xsl:call-template>         
          <xsl:apply-templates select="$a_in/xmpl"/>
        </div>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="tense-voice-inflection-set">
    <xsl:param name="a_in"/>
    <xsl:for-each select="$a_in">
      <xsl:sort select="case/@order" data-type="number" order="descending"/>
      <xsl:variable name="curPos" select="position()"/>
      <xsl:variable name="curKey" select="
        concat(term/stem, '|',
               term/suff, '|',
               case, '|',
               comp, '|',
               gend, '|',
               num, '|',
               pers, '|',
               mood, '|',
               sort)"/>
      <xsl:variable name="test">
        <xsl:for-each select="$a_in">
          <xsl:sort select="case/@order" data-type="number" order="descending"/>
          <!-- if this is preceding inflection -->
          <xsl:if test="$curPos > position()">
            <xsl:variable name="key" select="
              concat(term/stem, '|',
                     term/suff, '|',
                     case, '|',
                     comp, '|',
                     gend, '|',
                     num, '|',
                     pers, '|',
                     mood, '|',
                     sort)"/>
            <!-- and same values -->
            <xsl:if test="$curKey = $key">
              <!-- flag it -->
              <xsl:text>1</xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <!-- if this is inflection we haven't seen yet -->
      <xsl:if test="string-length($test) = 0">
        <xsl:if test="case">
          <xsl:apply-templates select="case"/>
        </xsl:if>
        <xsl:if test="comp and (comp != 'positive')">
          <xsl:apply-templates select="comp"/>          
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="verb-inflection-set">
    <xsl:param name="a_in"/>
    <xsl:for-each select="$a_in">
      <xsl:variable name="curPos" select="position()"/>
      <xsl:variable name="test">
        <xsl:for-each select="$a_in">
          <!-- if this is preceding inflection -->
          <xsl:if test="$curPos > position()">
            <!-- and same values -->
            <xsl:if test="
              (string($a_in[$curPos]/term/stem) = string(./term/stem)) and
              (string($a_in[$curPos]/term/suff) = string(./term/suff)) and
              (string($a_in[$curPos]/pofs) = string(./pofs)) and
              (string($a_in[$curPos]/case) = string(./case)) and
              (string($a_in[$curPos]/comp) = string(./comp)) and
              (string($a_in[$curPos]/gend) = string(./gend)) and
              (string($a_in[$curPos]/num) = string(./num)) and
              (string($a_in[$curPos]/pers) = string(./pers)) and
              (string($a_in[$curPos]/mood) = string(./mood)) and
              (string($a_in[$curPos]/sort) = string(./sort)) and
              (string($a_in[$curPos]/tense) = string(./tense)) and
              (string($a_in[$curPos]/voice) = string(./voice))">
              <!-- flag it -->
              <xsl:text>1</xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <!-- if this is inflection we haven't seen yet -->
      <xsl:if test="string-length($test) = 0">
        <div class="alph-infl">
          <xsl:call-template name="item-plus-text-plus-context">
            <xsl:with-param name="a_item" select="pers"/>
            <xsl:with-param name="a_suffix" select="' person'"/>
          </xsl:call-template>
          <xsl:call-template name="item-plus-text-plus-context">
            <xsl:with-param name="a_item" select="num"/>
            <xsl:with-param name="a_suffix" select="';'"/>
          </xsl:call-template>
          <xsl:call-template name="item-plus-text-plus-context">
            <xsl:with-param name="a_item" select="tense"/>
          </xsl:call-template>
          <xsl:call-template name="item-plus-text-plus-context">
            <xsl:with-param name="a_item" select="mood"/>
            <xsl:with-param name="a_suffix" select="';'"/>
          </xsl:call-template>
          <xsl:apply-templates select="voice"/>    
          <xsl:apply-templates select="$a_in/xmpl"/>
        </div>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="term">
    <span class="alph-term">
      <xsl:if test="starts-with(./ancestor-or-self::*/@xml:lang, 'ara')">
        <xsl:attribute name="dir">rtl</xsl:attribute>
      </xsl:if>
      <xsl:if test="pref">
        <span class="alph-pref">
          <xsl:call-template name="convert-text">
            <xsl:with-param name="a_item" select="pref"/>
          </xsl:call-template>
        </span>
        <xsl:text>-</xsl:text>
      </xsl:if>
      <xsl:call-template name="convert-text">
        <xsl:with-param name="a_item" select="stem"/>
        <!-- force final s to become medial not final sigma -->
        <!-- if there's a suffix -->
        <xsl:with-param name="a_partial" select="count(suff) > 0"/>
      </xsl:call-template>
      <xsl:if test="suff">
        <xsl:text>-</xsl:text>
      </xsl:if>
      <span class="alph-suff">
        <xsl:call-template name="convert-text">
          <xsl:with-param name="a_item" select="suff"/>
        </xsl:call-template>
      </span>
    </span>
  </xsl:template>

  <!--  Templates to handle simple text elements -->
  <xsl:template match="*">
    <xsl:param name="a_nopad" select="false()"/>
    <span>
      <xsl:attribute name="class">
        <xsl:if test="$a_nopad">
          <xsl:value-of select="concat('alph-nopad alph-', name(.))"/>
        </xsl:if>
        <xsl:if test="not($a_nopad)">
          <xsl:value-of select="concat('alph-', name(.))"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template match="case">
    <xsl:variable name="num" select="../num"/>
    <xsl:variable name="gend" select="../gend"/>
    <xsl:variable name="pofs" select="../pofs"/>
    <xsl:variable name="context">
      <xsl:value-of select="."/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="$num"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="$gend"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="$pofs"/>
    </xsl:variable>
    <span class="alph-case"
          context="{translate($context,' ','_')}"
          alph-num="{$num}"
          alph-gend="{$gend}"
          alph-pofs="{translate($pofs,' ','_')}">
      <xsl:value-of select="."/>
      <xsl:if
        test="$gend and not($gend = '') and not($gend = ../../dict/gend)">
        <xsl:choose>
          <xsl:when test="$gend='masculine'">
            <xsl:text> (m)</xsl:text>
          </xsl:when>
          <xsl:when test="$gend='feminine'">
            <xsl:text> (f)</xsl:text>
          </xsl:when>
          <xsl:when test="$gend='neuter'">
            <xsl:text> (n)</xsl:text>
          </xsl:when>
          <xsl:when test="$gend='all'">
            <xsl:text> (all)</xsl:text>
          </xsl:when>
          <xsl:when test="$gend='common'">
            <xsl:text> (common)</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> (?)</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </span>
  </xsl:template>

  <!-- declensions -->
  <!-- turn "x" into "x declension" -->
  <!-- turn "x & y" into "x" & "y declension" -->
  <xsl:template name="declension">
    <xsl:param name="a_item"/>
    <xsl:param name="a_pofs"/>
    <xsl:param name="a_nopad" select="false()"/>

    <!-- append '_adjective' to context if adjective, else no suffix -->
    <xsl:variable name="contextSuffix">
      <xsl:choose>
        <xsl:when test="$a_pofs = 'adjective'">
          <xsl:value-of select="'_adjective'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:for-each select="$a_item">
      <xsl:choose>
        <!-- if x & y -->
        <xsl:when test="contains(., ' &amp; ')">
          <!-- create x -->
          <xsl:variable name="first">
            <decl>
              <xsl:value-of select="substring-before(., ' &amp; ')"/>
            </decl>
          </xsl:variable>
          <xsl:call-template name="item-plus-text-plus-context">
            <xsl:with-param name="a_item" select="exsl:node-set($first)"/>
            <xsl:with-param name="a_name" select="'decl'"/>
            <xsl:with-param name="a_contextSuffix" select="$contextSuffix"/>
          </xsl:call-template>
          <xsl:text>&amp; </xsl:text>
          <!-- create y -->
          <xsl:variable name="second">
            <decl>
              <xsl:value-of select="substring-after(., ' &amp; ')"/>
            </decl>
          </xsl:variable>
          <xsl:call-template name="item-plus-text-plus-context">
            <xsl:with-param name="a_item" select="exsl:node-set($second)"/>
            <xsl:with-param name="a_name" select="'decl'"/>
            <xsl:with-param name="a_suffix" select="' declension'"/>
            <xsl:with-param name="a_contextSuffix" select="$contextSuffix"/>
            <xsl:with-param name="a_nopad" select="$a_nopad"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="item-plus-text-plus-context">
            <xsl:with-param name="a_item" select="."/>
            <xsl:with-param name="a_name" select="'decl'"/>
            <xsl:with-param name="a_suffix" select="' declension'"/>
            <xsl:with-param name="a_contextSuffix" select="$contextSuffix"/>
            <xsl:with-param name="a_nopad" select="$a_nopad"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- item plus leading/trailing text -->
  <!-- use name of item as class -->
  <!-- use value of item as context, if requested -->
  <xsl:template name="item-plus-text-plus-context">
    <xsl:param name="a_item"/>
    <xsl:param name="a_name"/>
    <xsl:param name="a_prefix" select="''"/>
    <xsl:param name="a_suffix" select="''"/>
    <xsl:param name="a_contextPrefix" select="''"/>
    <xsl:param name="a_contextSuffix" select="''"/>
    <xsl:param name="a_nopad" select="false()"/>

    <xsl:for-each select="$a_item">
      <xsl:variable name="itemName">
        <xsl:choose>
          <xsl:when test="$a_name">
            <xsl:value-of select="$a_name"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="name(.)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="itemContext">
        <xsl:value-of select="concat($a_contextPrefix, ., $a_contextSuffix)"/>
      </xsl:variable>
      <span>
        <xsl:attribute name="class">
          <xsl:if test="$a_nopad">
            <xsl:value-of select="concat('alph-nopad alph-', $itemName)"/>
          </xsl:if>
          <xsl:if test="not($a_nopad)">
            <xsl:value-of select="concat('alph-', $itemName)"/>
          </xsl:if>
        </xsl:attribute>
        <xsl:attribute name="context">
          <xsl:value-of select="translate($itemContext,' ','_')"/>
        </xsl:attribute>
        <xsl:value-of select="$a_prefix"/>
        <xsl:value-of select="."/>
        <xsl:value-of select="$a_suffix"/>
      </span>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="item-plus-text">
    <xsl:param name="a_item"/>
    <xsl:param name="a_name"/>
    <xsl:param name="a_prefix" select="''"/>
    <xsl:param name="a_suffix" select="''"/>
    <xsl:param name="a_stripSense" select="false()"/>
    <xsl:for-each select="$a_item">
      <xsl:variable name="itemName">
        <xsl:choose>
          <xsl:when test="$a_name">
            <xsl:value-of select="$a_name"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="name(.)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <span class="alph-{$itemName}">
        <xsl:value-of select="$a_prefix"/>
        <xsl:call-template name="convert-text">
          <xsl:with-param name="a_item" select="."/>
          <xsl:with-param name="a_stripSense" select="$a_stripSense"/>
        </xsl:call-template>
        <xsl:value-of select="$a_suffix"/>
      </span>
    </xsl:for-each>
  </xsl:template>

 <!-- convert text if necessary -->
  <xsl:template name="convert-text">
    <xsl:param name="a_item"/>
    <xsl:param name="a_partial" select="false()"/>
    <xsl:param name="a_stripSense" select="false()"/>

    <xsl:choose>
      <!-- ancient Greek -->
      <xsl:when test="starts-with($a_item/ancestor-or-self::*/@xml:lang, 'grc')">
        <xsl:call-template name="convert-text-grc">
          <xsl:with-param name="a_item" select="$a_item"/>
          <xsl:with-param name="a_partial" select="$a_partial"/>
          <xsl:with-param name="a_stripSense" select="$a_stripSense"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Arabic -->
      <xsl:when test="starts-with($a_item/ancestor-or-self::*/@xml:lang, 'ara')">
        <xsl:call-template name="convert-text-ara">
          <xsl:with-param name="a_item" select="$a_item"/>
          <xsl:with-param name="a_stripSense" select="$a_stripSense"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$a_item"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- convert Greek text -->
  <xsl:template name="convert-text-grc">
    <xsl:param name="a_item"/>
    <xsl:param name="a_partial" select="false()"/>
    <xsl:param name="a_stripSense" select="false()"/>

    <!-- is this betacode? -->
    <xsl:variable name="isbeta">
      <xsl:call-template name="is-beta">
        <xsl:with-param name="a_in" select="$a_item"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- get text in Unicode -->
    <xsl:variable name="text">
      <xsl:choose>
        <!-- if betacode -->
        <xsl:when test="$isbeta > 0">
          <xsl:variable name="itemText">
            <xsl:choose>
              <xsl:when test="$a_item/*">
                <xsl:for-each select="$a_item/*">
                  <xsl:value-of select="./text()"/>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$a_item/text()"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <!-- convert it to unicode -->
          <xsl:call-template name="beta-to-uni">
            <xsl:with-param name="a_in" select="$itemText"/>
            <xsl:with-param name="a_partial" select="$a_partial"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$a_item"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- strip sense indication if requested -->
    <xsl:choose>
      <xsl:when test="$a_stripSense">
        <xsl:call-template name="strip-trailing">
          <xsl:with-param name="a_in" select="$text"/>
          <xsl:with-param name="a_toStrip" select="'0123456789'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- convert Arabic text -->
  <xsl:template name="convert-text-ara">
    <xsl:param name="a_item"/>
    <xsl:param name="a_stripSense" select="false()"/>

    <xsl:variable name="itemText">
      <xsl:choose>
        <xsl:when test="$a_item/*">
          <xsl:for-each select="$a_item/*">
            <xsl:value-of select="./text()"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$a_item/text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- strip sense indication if requested -->
    <xsl:variable name="text">
      <xsl:choose>
        <xsl:when test="$a_stripSense">
          <xsl:call-template name="strip-trailing">
            <xsl:with-param name="a_in" select="$itemText"/>
            <xsl:with-param name="a_toStrip" select="'0123456789_'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$itemText"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- convert it to unicode -->
    <xsl:call-template name="ara-buckwalter-to-uni">
      <xsl:with-param name="a_in" select="$text"/>
    </xsl:call-template>
  </xsl:template>

  <!-- strip trailing characters from input -->
  <!-- default is to strip trailing digits -->
  <xsl:template name="strip-trailing">
    <xsl:param name="a_in"/>
    <xsl:param name="a_toStrip" select="'0123456789'"/>

    <xsl:variable name="lastChar"
      select="substring($a_in, string-length($a_in))"/>

    <xsl:choose>
      <!-- if empty input or last character is not in list -->
      <xsl:when test="translate($lastChar, $a_toStrip, '') = $lastChar">
        <!-- we're done - return input -->
        <xsl:value-of select="$a_in"/>
      </xsl:when>
      <!-- if last character is in list -->
      <xsl:otherwise>
        <!-- drop it and strip remaining (leading) part -->
        <xsl:call-template name="strip-trailing">
          <xsl:with-param name="a_in"
            select="substring($a_in, 1, string-length($a_in) - 1)"/>
          <xsl:with-param name="a_toStrip" select="$a_toStrip"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <xsl:template match="xmpl">
      <xsl:call-template name="item-plus-text">
        <xsl:with-param name="a_item" select="."/>
      </xsl:call-template>
  </xsl:template>
    
</xsl:stylesheet>

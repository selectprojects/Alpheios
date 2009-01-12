<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <!--
    Copyright 2008-2009 Cantus Foundation
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
    Convert short definitions in XML format to index format usable
    by xquery

    Lemmas are are assumed to be encoded in Greek Unicode.
    Vowel length diacritics are removed.
    Lemmas ending with "1" are repeated without the "1" to be used
    when the lookup term has no trailing digit.
  -->

  <xsl:import href="beta-uni-util.xsl"/>
  <xsl:output encoding="UTF-8" method="xml"/>

  <xsl:include href="grc-specialcases.xsl"/>

  <!-- template to transform entire file -->
  <xsl:template match="/">
    <xsl:element name="entrylist">
      <xsl:for-each select="entrylist/entry">
        <xsl:call-template name="entry">
          <xsl:with-param name="dict-lemma" select="data(./lemma)"/>
          <xsl:with-param name="lemma" select="data(./lemma)"/>
          <xsl:with-param name="id" select="data(./@id)"/>
          <xsl:with-param name="lexicon" select="/entrylist/@id"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <!-- template to transform one entry -->
  <xsl:template name="entry">
    <xsl:param name="dict-lemma"/>
    <xsl:param name="lemma"/>
    <xsl:param name="id"/>
    <xsl:param name="lexicon"/>

    <!-- if lemma ends in "1" -->
    <xsl:variable name="lemma-len" select="string-length($lemma)"/>
    <xsl:if
      test="($lemma-len >= 2) and
            (substring($lemma, $lemma-len, 1) = '1') and
            not(contains('0123456789', substring($lemma, $lemma-len - 1, 1)))">
      <!-- put out lemma without "1" -->
      <xsl:call-template name="entry">
        <xsl:with-param name="dict-lemma" select="$dict-lemma"/>
        <xsl:with-param name="lemma"
          select="substring($lemma, 1, $lemma-len - 1)"/>
        <xsl:with-param name="id" select="$id"/>
        <xsl:with-param name="lexicon" select="$lexicon"/>
      </xsl:call-template>
    </xsl:if>

    <!-- strip vowel length diacritics and capitalization -->
    <xsl:variable name="key1">
      <xsl:call-template name="uni-strip">
        <xsl:with-param name="input" select="$lemma"/>
        <xsl:with-param name="strip-vowels" select="true()"/>
        <xsl:with-param name="strip-diaereses" select="true()"/>
        <xsl:with-param name="strip-caps" select="true()"/>
      </xsl:call-template>
    </xsl:variable>

    <!--
      if on special list
      recalculate key with only vowel length removed and prepend @
    -->
    <xsl:variable name="key">
      <xsl:choose>
        <xsl:when test="count($special-cases/table[@id = $lexicon]/
                                  case[@lemma = $key1]) > 0">
          <xsl:variable name="key2">
            <xsl:call-template name="uni-strip">
              <xsl:with-param name="input" select="data($lemma)"/>
              <xsl:with-param name="strip-vowels" select="true()"/>
              <xsl:with-param name="strip-diaereses" select="false()"/>
              <xsl:with-param name="strip-caps" select="false()"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="concat('@', $key2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$key1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- put out lemma on separate line -->
    <xsl:element name="entry">
      <xsl:attribute name="lemma" select="$dict-lemma"/>
      <xsl:attribute name="key" select="$key"/>
      <xsl:attribute name="id" select="./@id"/>
    </xsl:element>
    <xsl:text>&#x000A;</xsl:text>
  </xsl:template>

</xsl:stylesheet>

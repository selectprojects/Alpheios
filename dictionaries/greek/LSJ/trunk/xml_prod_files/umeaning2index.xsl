<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <!--
    Copyright 2008 Cantus Foundation
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
    Convert short LSJ definitions in XML format to index format usable
    by xquery

    Lemmas are are assumed to be encoded in Greek Unicode.
    Vowel length diacritics are removed.
    Lemmas ending with "1" are repeated without the "1" to be used
    when the lookup term has no trailing digit.
  -->

  <xsl:import href="beta-uni-util.xsl"/>
  <xsl:output encoding="UTF-8" method="xml"/>

  <xsl:variable name="special-cases">
    <table>
      <case lemma="βύνη"/>
      <case lemma="βώμιος"/>
      <case lemma="γευστός"/>
      <case lemma="δάν"/>
      <case lemma="δαμία"/>
      <case lemma="δήν"/>
      <case lemma="δῆλος"/>
      <case lemma="δίς"/>
      <case lemma="δῖος1"/>
      <case lemma="εὖρος"/>
      <case lemma="εὐσέβεια"/>
      <case lemma="θήρα"/>
      <case lemma="θρᾷττα"/>
      <case lemma="κάδμος"/>
      <case lemma="κάρνειος"/>
      <case lemma="κάστωρ"/>
      <case lemma="καρπάσιον"/>
      <case lemma="καρύινος"/>
      <case lemma="κίρκη"/>
      <case lemma="κόλχος"/>
      <case lemma="κρήτη"/>
      <case lemma="κρόνος"/>
      <case lemma="κύπριος"/>
      <case lemma="κύπρος"/>
      <case lemma="κῦρος"/>
      <case lemma="κυβέλη"/>
      <case lemma="κώρυκος"/>
      <case lemma="κωρυκίς"/>
      <case lemma="λ"/>
      <case lemma="λάμια"/>
      <case lemma="λάρτιος"/>
      <case lemma="λίνδος"/>
      <case lemma="λίνος"/>
      <case lemma="λύκιος"/>
      <case lemma="μαῖα"/>
      <case lemma="μίτρα"/>
      <case lemma="μόριος"/>
      <case lemma="νάιος"/>
      <case lemma="νέαιρα"/>
      <case lemma="νεμέσιον"/>
      <case lemma="πάν"/>
      <case lemma="πάνορμος"/>
      <case lemma="παρθένος"/>
      <case lemma="περσέπολις"/>
      <case lemma="πλάτων"/>
      <case lemma="πολιάς"/>
      <case lemma="πύλος"/>
      <case lemma="σάραπις"/>
      <case lemma="σαβάζω"/>
      <case lemma="σήρ"/>
      <case lemma="σηστός"/>
      <case lemma="σκῦρος"/>
      <case lemma="σμύρνα"/>
      <case lemma="σπάρτη"/>
      <case lemma="σπανός"/>
      <case lemma="συβαρίζω"/>
      <case lemma="συρίζω"/>
      <case lemma="τ"/>
      <case lemma="χείμερος"/>
      <case lemma="χείρων"/>
      <case lemma="χειμάζω"/>
      <case lemma="χωρισμός"/>
      <case lemma="ψ"/>
    </table>
  </xsl:variable>
  
  <!-- template to transform entire file -->
  <xsl:template match="/">
    <xsl:element name="entrylist">
      <xsl:apply-templates select="entrylist/entry"/>
    </xsl:element>
  </xsl:template>

  <!-- template to transform one entry -->
  <xsl:template match="entry">
    <!-- strip vowel length diacritics and capitalization -->
    <xsl:variable name="lemma" select="data(./lemma)"/>
    <xsl:variable name="key1">
      <xsl:call-template name="uni-strip">
        <xsl:with-param name="input" select="$lemma"/>
        <xsl:with-param name="strip-vowels" select="true()"/>
        <xsl:with-param name="strip-caps" select="true()"/>
      </xsl:call-template>
    </xsl:variable>

    <!--
      if on special list
      recalculate uni-lemma without capitalization removed and prepend @
    -->
    <xsl:variable name="key">
      <xsl:choose>
        <xsl:when test="count($special-cases//case[@lemma = $key1]) > 0">
          <xsl:variable name="key2">
            <xsl:call-template name="uni-strip">
              <xsl:with-param name="input" select="data($lemma)"/>
              <xsl:with-param name="strip-vowels" select="true()"/>
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

    <!-- if key ends in "1" -->
    <xsl:variable name="keylen" select="string-length($key)"/>
    <xsl:if
      test="($keylen >= 2) and
            (substring($key, $keylen, 1) = '1') and
            not(contains('0123456789', substring($key, $keylen - 1, 1)))">
      <!-- put out key without "1" -->
      <xsl:element name="entry">
        <xsl:attribute name="lemma" select="$lemma"/>
        <xsl:attribute name="key" select="substring($key, 1, $keylen - 1)"/>
        <xsl:attribute name="id" select="./@id"/>
      </xsl:element>
    </xsl:if>

    <!-- put out full lemma -->
    <xsl:element name="entry">
      <xsl:attribute name="lemma" select="$lemma"/>
      <xsl:attribute name="key" select="$key"/>
      <xsl:attribute name="id" select="./@id"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>

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
    Convert short LSJ definitions in XML format to data format usable
    by language extensions

    Lemmas are are assumed to be encoded in Greek Unicode.
    Vowel length diacritics are removed.
    Lemma and meanings are concatenated with a period between.
    Lemmas ending with "1" are repeated without the "1" to be used
    when the lookup term has no trailing digit.
  -->

  <xsl:import href="beta-uni-util.xsl"/>

  <xsl:output encoding="UTF-8" method="text"/>

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
    <!-- for each entry with a meaning -->
    <xsl:for-each select="entrylist/entry">
      <xsl:call-template name="entry">
        <xsl:with-param name="lemma" select="./lemma"/>
        <xsl:with-param name="meaning" select="./meaning"/>
        <xsl:with-param name="id" select="./@id"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- template to transform one entry -->
  <xsl:template name="entry">
    <xsl:param name="lemma"/>
    <xsl:param name="meaning"/>
    <xsl:param name="id"/>

    <!-- strip vowel length diacritics and capitalization -->
    <xsl:variable name="uni-temp1">
      <xsl:call-template name="uni-strip">
        <xsl:with-param name="input" select="data($lemma)"/>
        <xsl:with-param name="strip-vowels" select="true()"/>
        <xsl:with-param name="strip-caps" select="true()"/>
      </xsl:call-template>
    </xsl:variable>

    <!--
      if on special list
        put out with @ as meaning and no id
        recalculate uni-lemma without capitalization removed
        and prepend @
    -->
    <xsl:variable name="special-count"
                  select="count($special-cases//case[@lemma = $uni-temp1])"/>
    <xsl:if test="$special-count > 0">
      <xsl:value-of select="concat($uni-temp1, ',@|&#x000A;')"/>
    </xsl:if>
    <xsl:variable name="uni-lemma">
      <xsl:choose>
        <xsl:when test="$special-count > 0">
          <xsl:variable name="uni-temp2">
            <xsl:call-template name="uni-strip">
              <xsl:with-param name="input" select="data($lemma)"/>
              <xsl:with-param name="strip-vowels" select="true()"/>
              <xsl:with-param name="strip-caps" select="false()"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="concat('@', $uni-temp2)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$uni-temp1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- if lemma ends in "1" -->
    <xsl:variable name="templen" select="string-length($uni-lemma)"/>
    <xsl:if
      test="($templen >= 2) and
                  (substring($uni-lemma, $templen, 1) = '1') and
                  not(contains('0123456789',
                               substring($uni-lemma, $templen - 1, 1)))">
      <!-- put out lemma without "1" -->
      <xsl:value-of
        select="concat(substring($uni-lemma, 1, $templen - 1),
        ',',
        normalize-space($meaning),
        '|',
        $id,
        '&#x000A;')"
      />
    </xsl:if>

    <!-- put out full lemma -->
    <xsl:value-of
      select="concat($uni-lemma,
                     ',',
                     normalize-space($meaning),
                     '|',
                     $id,
                     '&#x000A;')"
    />
  </xsl:template>

</xsl:stylesheet>

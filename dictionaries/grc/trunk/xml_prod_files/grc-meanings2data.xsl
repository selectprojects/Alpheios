<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:local="http://alpheios.net/namespaces/xslt"
                version="2.0">

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
    Convert short definitions in XML format to data format usable
    by language extensions to look up definitions and ids.

    Lemmas are are assumed to be encoded in Greek Unicode.
    Various diacritics and capitalization are removed.
    Lemmas, meanings, and ids are concatenated with pipes (|) between.
    Lemmas ending with "1" are repeated without the "1" to be used
    when the lookup term has no trailing digit.

    What is output is controlled by two parameters, output-meanings and
    output-ids.  Lines with no content (meaning and/or id, as requested,
    are empty) are suppressed.
  -->

  <xsl:import href="beta-uni-util.xsl"/>

  <xsl:output encoding="UTF-8" method="text"/>

  <!-- parameters controlling contents of output -->
  <xsl:param name="output-meanings"/>
  <xsl:param name="output-ids"/>

  <!--
    Special cases

    These are sets (typically 2, but possibly more) of lemmas that cannot be
    distinguished from each other after application of the uni-strip template.
    For such lemmas, two entries are made in the output.  The first has
    the stripped lemma as key, with a value of "@".  The second has "@"
    prepended to the lemma with only vowel-length diacritics removed, with the
    actual definition as value.

    Thus, the lookup software using the output should apply the same stripping
    operation and find the corresponding line.  If the value is not "@", it is
    the final value.  If it is "@", the lookup should be repeated with "@" plus
    the original lemma with vowel-length diacritics removed.

    Note: The lemmas in the table are stripped, so that only one entry is
    required for each set.
  -->
  <xsl:include href="grc-specialcases.xsl"/>

  <!-- template to transform entire file -->
  <xsl:template match="/">
    <!-- for each entry with a meaning -->
    <xsl:for-each select="entrylist/entry">
      <xsl:call-template name="entry">
        <xsl:with-param name="lemma" select="./lemma"/>
        <xsl:with-param name="meaning" select="./meaning"/>
        <xsl:with-param name="id" select="./@id"/>
        <xsl:with-param name="lexicon" select="/entrylist/@id"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- template to transform one entry -->
  <xsl:template name="entry">
    <xsl:param name="lemma"/>
    <xsl:param name="meaning"/>
    <xsl:param name="id"/>
    <xsl:param name="lexicon"/>

    <!-- if lemma ends in "1" -->
    <xsl:variable name="lemma-len" select="string-length($lemma)"/>
    <xsl:if
      test="($lemma-len >= 2) and
            (substring($lemma, $lemma-len, 1) = '1') and
            not(contains('0123456789',
                         substring($lemma, $lemma-len - 1, 1)))">
      <!-- put out lemma without "1" -->
      <xsl:call-template name="entry">
        <xsl:with-param name="lemma"
          select="substring($lemma, 1, $lemma-len - 1)"/>
        <xsl:with-param name="meaning" select="$meaning"/>
        <xsl:with-param name="id" select="$id"/>
        <xsl:with-param name="lexicon" select="$lexicon"/>
      </xsl:call-template>
    </xsl:if>

    <!-- strip vowel length diacritics and capitalization -->
    <xsl:variable name="uni-temp1">
      <xsl:call-template name="uni-strip">
        <xsl:with-param name="input" select="data($lemma)"/>
        <xsl:with-param name="strip-vowels" select="true()"/>
        <xsl:with-param name="strip-diaereses" select="true()"/>
        <xsl:with-param name="strip-caps" select="true()"/>
      </xsl:call-template>
    </xsl:variable>

    <!--
      if on special list
        recalculate uni-lemma without capitalization and diaereses removed
        and prepend @
    -->
    <xsl:variable name="special-count"
      select="count($special-cases/table[@id = $lexicon]/
                          case[@lemma = $uni-temp1])"/>
    <xsl:variable name="uni-lemma">
      <xsl:choose>
        <xsl:when test="$special-count > 0">
          <xsl:variable name="uni-temp2">
            <xsl:call-template name="uni-strip">
              <xsl:with-param name="input" select="data($lemma)"/>
              <xsl:with-param name="strip-vowels" select="true()"/>
              <xsl:with-param name="strip-diaereses" select="false()"/>
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

    <!--
      if any data to put out:
        if special case, put out with @ as meaning and id
        put out full lemma
    -->
    <xsl:variable name="line">
      <xsl:value-of select="local:output-value($uni-lemma, $meaning, $id)"/>
    </xsl:variable>
    <xsl:if test="string-length($line) > 0">
      <xsl:if test="$special-count > 0">
        <xsl:value-of select="local:output-value($uni-temp1, '@', '@')"/>
      </xsl:if>
      <xsl:value-of select="$line"/>
    </xsl:if>
  </xsl:template>

  <!-- template to put out one line -->
  <xsl:function name="local:output-value" as="xs:string">
    <xsl:param name="lemma"/>
    <xsl:param name="meaning"/>
    <xsl:param name="id"/>

    <!-- calculate meaning, id, and separator according to params -->
    <xsl:variable name="out-meaning">
      <xsl:if test="$output-meanings">
        <xsl:value-of select="$meaning"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="out-sep">
      <xsl:if test="$output-meanings and $output-ids">
        <xsl:value-of select="'|'"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="out-id">
      <xsl:if test="$output-ids">
        <xsl:value-of select="$id"/>
      </xsl:if>
    </xsl:variable>

    <!-- output line with terminator -->
    <xsl:choose>
      <xsl:when test="(string-length($out-meaning) > 0) or
        (string-length($out-id) > 0)">
        <xsl:value-of select="concat($lemma,
                                     '|',
                                     $out-meaning,
                                     $out-sep,
                                     $out-id,
                                     '&#x000A;')"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:function>

</xsl:stylesheet>

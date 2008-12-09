<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

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

  <!-- template to transform entire file -->
  <xsl:template match="/">
    <xsl:element name="entrylist">
      <xsl:apply-templates select="entrylist/entry"/>
    </xsl:element>
  </xsl:template>

  <!-- template to transform one entry -->
  <xsl:template match="entry">
    <!-- strip vowel length diacritics -->
    <xsl:variable name="lemma" select="data(./lemma)"/>
    <xsl:variable name="key">
      <xsl:call-template name="uni-strip-length">
        <xsl:with-param name="input" select="$lemma"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="keylen" select="string-length($key)"/>

    <!-- if key ends in "1" -->
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

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

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

  <!-- template to transform entire file -->
  <xsl:template match="/">
    <!-- for each entry -->
    <xsl:for-each select="entrylist/entry">
      <xsl:call-template name="entry">
        <xsl:with-param name="lemma" select="./lemma"/>
        <xsl:with-param name="meaning" select="./meaning"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- template to transform one entry -->
  <xsl:template name="entry">
    <xsl:param name="lemma"/>
    <xsl:param name="meaning"/>

    <!-- strip vowel length diacritics -->
    <xsl:variable name="uni-lemma">
      <xsl:call-template name="uni-strip-length">
        <xsl:with-param name="input" select="data($lemma)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="templen" select="string-length($uni-lemma)"/>

    <!-- if lemma ends in "1" -->
    <xsl:if test="($templen >= 2) and
                  (substring($uni-lemma, $templen, 1) = '1') and
                  not(contains('0123456789',
                               substring($uni-lemma, $templen - 1, 1)))">
      <!-- put out lemma without "1" -->
      <xsl:value-of
        select="concat(substring($uni-lemma, 1, $templen - 1),
        ',',
        normalize-space($meaning),
        '&#x000A;')"
      />
    </xsl:if>

    <!-- put out full lemma -->
    <xsl:value-of
      select="concat($uni-lemma,
                     ',',
                     normalize-space($meaning),
                     '&#x000A;')"
    />
  </xsl:template>

</xsl:stylesheet>

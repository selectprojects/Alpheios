<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <!--
    Convert short LSJ definitions in XML format to data format usable
    by language extensions

    Lemmas are translated from betacode to unicode.
    Vowel length diacritics are removed.
    Lemma and meanings are concatenated with a period between.
    Lemmas ending with "1" are repeated without the "1" to be used
    when the lookup term has no trailing digit.
  -->

  <xsl:import href="beta2unicode.xsl"/>

  <xsl:output encoding="UTF-8" method="text"/>

  <!-- template to transform entire file -->
  <xsl:template match="/">
    <!-- for each entry with a meaning -->
    <xsl:for-each select="entrylist/entry">
      <xsl:if test="exists(./meaning)">
        <xsl:call-template name="entry">
          <xsl:with-param name="lemma" select="./lemma"/>
          <xsl:with-param name="meaning" select="./meaning"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- template to transform one entry -->
  <xsl:template name="entry">
    <xsl:param name="lemma"/>
    <xsl:param name="meaning"/>

    <!-- convert lemma to unicode, stripping vowel length -->
    <xsl:variable name="stripped-lemma">
      <xsl:call-template name="beta-strip-length">
        <xsl:with-param name="input" select="data($lemma)"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="uni-lemma">
      <xsl:call-template name="beta-to-uni">
        <xsl:with-param name="input" select="$stripped-lemma"/>
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

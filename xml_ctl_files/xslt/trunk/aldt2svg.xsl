<?xml version="1.0" encoding="UTF-8"?>

<!--
  Stylesheet to transform XML conforming to
  the Ancient Language Dependency Treebank schema (version 1.5)
  to XML conforming to SVG
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">

  <xsl:include href="beta2unicode.xsl"/>
  <xsl:include href="aldt-util.xsl"/>

  <xsl:strip-space elements="*"/>

  <!--
        Convert sentence to group element
        Immediate children are root words for whole sentence
  -->
  <xsl:template match="sentence">
    <xsl:variable name="is-beta" select="./@xml:lang = 'grc-x-beta'"/>

    <svg xmlns="http://www.w3.org/2000/svg">
      <xsl:element name="g" namespace="http://www.w3.org/2000/svg">
        <xsl:element name="text" namespace="http://www.w3.org/2000/svg">
          <xsl:choose>
            <!-- if this is betacode -->
            <xsl:when test="$is-beta">
              <!-- convert span from betacode to unicode -->
              <xsl:call-template name="beta-to-uni">
                <xsl:with-param name="input" select="@span"/>
              </xsl:call-template>
            </xsl:when>

            <!-- if not betacode -->
            <xsl:otherwise>
              <!-- just use span -->
              <xsl:value-of select="@span"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
        <xsl:element name="line" namespace="http://www.w3.org/2000/svg"/>

        <!-- transform root words in sentence -->
        <xsl:call-template name="word-set">
          <xsl:with-param name="words" select="./word[@head='0']"/>
          <xsl:with-param name="is-beta" select="$is-beta"/>
        </xsl:call-template>
      </xsl:element>
    </svg>
  </xsl:template>

  <!--
        Convert words to list members
        Immediate children of a word are words dependent on it
        (those whose head attribute equals the word's id)
  -->
  <xsl:template name="word-set">
    <xsl:param name="words"/>
    <xsl:param name="is-beta"/>

    <xsl:for-each select="$words">
      <!-- group element -->
      <xsl:element name="g" namespace="http://www.w3.org/2000/svg">

        <!-- text element -->
        <xsl:element name="text" namespace="http://www.w3.org/2000/svg">
          <!-- class attribute is part of speech -->
          <xsl:apply-templates select="$aldt-morphology-table" mode="short2long">
            <xsl:with-param name="category">pos</xsl:with-param>
            <xsl:with-param name="key" select="substring(@postag,1,1)"/>
            <xsl:with-param name="name" select="'class'"/>
          </xsl:apply-templates>

          <!-- Create text from word form and relation -->
          <xsl:variable name="form">
            <xsl:choose>
              <!-- if this is betacode -->
              <xsl:when test="$is-beta">
                <!-- convert form from betacode to unicode -->
                <xsl:call-template name="beta-to-uni">
                  <xsl:with-param name="input" select="@form"/>
                </xsl:call-template>
              </xsl:when>

              <!-- if not betacode -->
              <xsl:otherwise>
                <!-- just use form -->
                <xsl:value-of select="@form"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:value-of select="concat($form, ' (', @relation, ')')"/>
        </xsl:element>

        <!-- line element -->
        <xsl:element name="line" namespace="http://www.w3.org/2000/svg"/>

        <!-- Recursively build children from this word's dependents -->
        <xsl:variable name="id" select="@id"/>
        <xsl:call-template name="word-set">
          <xsl:with-param name="words" select="../word[@head=$id]"/>
          <xsl:with-param name="is-beta" select="$is-beta"/>
        </xsl:call-template>

      </xsl:element>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

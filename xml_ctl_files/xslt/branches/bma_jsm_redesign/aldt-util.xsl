<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common">

  <!-- 
  Table mapping morphological tag abbreviations to
  full names for Ancient Language Dependency Treebank
-->
  <xsl:variable name="raw-aldt-morphology-table">
    <aldt-morphology-table>
      <!-- part of speech -->
      <entry>
        <category>pos</category>
        <short>n</short>
        <long>noun</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>v</short>
        <long>verb</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>t</short>
        <long>participle</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>a</short>
        <long>adjective</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>d</short>
        <long>adverb</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>c</short>
        <long>conjunction</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>l</short>
        <long>article</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>g</short>
        <long>particle</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>r</short>
        <long>preposition</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>p</short>
        <long>pronoun</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>m</short>
        <long>numeral</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>i</short>
        <long>interjection</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>e</short>
        <long>exclamation</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>x</short>
        <long>irregular</long>
      </entry>
      <entry>
        <category>pos</category>
        <short>u</short>
        <long>punctuation</long>
      </entry>

      <!-- person -->
      <entry>
        <category>person</category>
        <short>1</short>
        <long>first_person</long>
      </entry>
      <entry>
        <category>person</category>
        <short>2</short>
        <long>second_person</long>
      </entry>
      <entry>
        <category>person</category>
        <short>3</short>
        <long>third_person</long>
      </entry>

      <!-- number -->
      <entry>
        <category>number</category>
        <short>s</short>
        <long>singular</long>
      </entry>
      <entry>
        <category>number</category>
        <short>p</short>
        <long>plural</long>
      </entry>
      <entry>
        <category>number</category>
        <short>d</short>
        <long>dual</long>
      </entry>

      <!-- tense -->
      <entry>
        <category>tense</category>
        <short>p</short>
        <long>present</long>
      </entry>
      <entry>
        <category>tense</category>
        <short>i</short>
        <long>imperfect</long>
      </entry>
      <entry>
        <category>tense</category>
        <short>r</short>
        <long>perfect</long>
      </entry>
      <entry>
        <category>tense</category>
        <short>l</short>
        <long>pluperfect</long>
      </entry>
      <entry>
        <category>tense</category>
        <short>t</short>
        <long>future_perfect</long>
      </entry>
      <entry>
        <category>tense</category>
        <short>f</short>
        <long>future</long>
      </entry>
      <entry>
        <category>tense</category>
        <short>a</short>
        <long>aorist</long>
      </entry>

      <!-- mood -->
      <entry>
        <category>mood</category>
        <short>i</short>
        <long>indicative</long>
      </entry>
      <entry>
        <category>mood</category>
        <short>s</short>
        <long>subjunctive</long>
      </entry>
      <entry>
        <category>mood</category>
        <short>o</short>
        <long>optative</long>
      </entry>
      <entry>
        <category>mood</category>
        <short>n</short>
        <long>infinitive</long>
      </entry>
      <entry>
        <category>mood</category>
        <short>m</short>
        <long>imperative</long>
      </entry>
      <entry>
        <category>mood</category>
        <short>g</short>
        <long>gerundive</long>
      </entry>
      <entry>
        <category>mood</category>
        <short>p</short>
        <long>participial</long>
      </entry>

      <!-- voice -->
      <entry>
        <category>voice</category>
        <short>a</short>
        <long>active</long>
      </entry>
      <entry>
        <category>voice</category>
        <short>p</short>
        <long>passive</long>
      </entry>
      <entry>
        <category>voice</category>
        <short>d</short>
        <long>deponent</long>
      </entry>
      <entry>
        <category>voice</category>
        <short>e</short>
        <long>medio_passive</long>
      </entry>

      <!-- gender -->
      <entry>
        <category>gender</category>
        <short>m</short>
        <long>masculine</long>
      </entry>
      <entry>
        <category>gender</category>
        <short>f</short>
        <long>feminine</long>
      </entry>
      <entry>
        <category>gender</category>
        <short>n</short>
        <long>neuter</long>
      </entry>

      <!-- case -->
      <entry>
        <category>case</category>
        <short>n</short>
        <long>nominative</long>
      </entry>
      <entry>
        <category>case</category>
        <short>g</short>
        <long>genitive</long>
      </entry>
      <entry>
        <category>case</category>
        <short>d</short>
        <long>dative</long>
      </entry>
      <entry>
        <category>case</category>
        <short>a</short>
        <long>accusative</long>
      </entry>
      <entry>
        <category>case</category>
        <short>b</short>
        <long>ablative</long>
      </entry>
      <entry>
        <category>case</category>
        <short>v</short>
        <long>vocative</long>
      </entry>
      <entry>
        <category>case</category>
        <short>i</short>
        <long>instrumental</long>
      </entry>
      <entry>
        <category>case</category>
        <short>l</short>
        <long>locative</long>
      </entry>

      <!-- degree -->
      <entry>
        <category>degree</category>
        <short>p</short>
        <long>positive</long>
      </entry>
      <entry>
        <category>degree</category>
        <short>c</short>
        <long>comparative</long>
      </entry>
      <entry>
        <category>degree</category>
        <short>s</short>
        <long>superlative</long>
      </entry>
    </aldt-morphology-table>
  </xsl:variable>
  <xsl:variable name="aldt-morphology-table"
    select="exsl:node-set($raw-aldt-morphology-table)/aldt-morphology-table"/>

  <!-- keys for lookup table -->
  <xsl:key name="aldt-morphology-lookup" match="aldt-morphology-table/entry"
    use="short"/>
  <xsl:key name="aldt-morphology-lookup" match="aldt-morphology-table/entry"
    use="long"/>

  <!--
    Template to calculate a long name from morphology code
    
    Parameters:
      category            morphological category (person, case, etc.)
      key                 short value to look up
      attribute           whether to output attribute or element (default=attr)
      name                name of attribute/element (default=use category)

    Return value:
      If code found in requested category
        attribute or element containing long value
      If code not found, empty
  -->
  <xsl:template match="aldt-morphology-table" mode="short2long">
    <xsl:param name="category"/>
    <xsl:param name="key"/>
    <xsl:param name="attribute" select="true()"/>
    <xsl:param name="name" select="''"/>

    <!-- use long value from entry with matching category -->
    <xsl:variable name="value"
      select="key('aldt-morphology-lookup', $key)[category=$category]/long"/>

    <xsl:if test="string-length($value) > 0">
      <!-- name to use for attribute/element -->
      <xsl:variable name="nameToUse">
        <xsl:choose>
          <xsl:when test="string-length($name) > 0">
            <xsl:value-of select="$name"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$category"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <!-- if returning attribute -->
        <xsl:when test="$attribute">
          <xsl:attribute name="{$nameToUse}">
            <xsl:value-of select="$value"/>
          </xsl:attribute>
        </xsl:when>
        <!-- if returning element -->
        <xsl:otherwise>
          <xsl:element name="{$nameToUse}">
            <xsl:value-of select="$value"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!--
    Template to calculate a morphology code from a long name
    
    Parameters:
      category            morphological category (person, case, etc.)
      key                 short value to look up
      attribute           whether to output attribute or element (default=attr)
      name                name of attribute/element (default=use category)

    Return value:
      If long name found in category, the short code
      If not found, "-"
  -->
  <xsl:template match="aldt-morphology-table" mode="long2short">
    <xsl:param name="category"/>
    <xsl:param name="key"/>

    <!-- use short value from entry with matching category -->
    <xsl:variable name="value"
      select="key('aldt-morphology-lookup', $key)[category=$category]/short"/>
    <xsl:if test="string-length($value) > 0">
      <xsl:value-of select="$value"/>
    </xsl:if>
    <xsl:if test="string-length($value) = 0">-</xsl:if>
  </xsl:template>

</xsl:stylesheet>

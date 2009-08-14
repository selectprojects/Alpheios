<?xml version="1.0" encoding="UTF-8"?>

<!--
  Stylesheet to transform XML conforming to
  the PML (Prague Markup Language) schema in aldt_schema.xml
  used in the tred tree editor
  to XML conforming to
  the Ancient Language Dependency Treebank schema (version 1.5)
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:treebank="http://nlp.perseus.tufts.edu/syntax/treebank/1.5 treebank-1.5.xsd"
  xmlns:pml="http://ufal.mff.cuni.cz/pdt/pml/"
  xmlns:aldt="http://treebank.alpheios.net/namespaces/aldt"
  exclude-result-prefixes="xs">

  <xsl:include href="uni2betacode.xsl"/>
  <xsl:include href="aldt-util.xsl"/>

  <xsl:strip-space elements="*"/>

  <!-- whether to use uppercase letters in betacode -->
  <xsl:variable name="upper" select="false()"/>

  <xsl:template match="/">
    <xsl:apply-templates select="pml:aldt_treebank"/>
  </xsl:template>

  <!--  Root node
    Change namespace, strip meta and tree elements
    (Note: global variable for namespace doesn't work here)
  -->
  <xsl:template match="pml:aldt_treebank">
    <xsl:variable name="language" select="@xml:lang"/>
    <xsl:element name="treebank" namespace="">
      <xsl:attribute name="version">1.5</xsl:attribute>
      <xsl:attribute name="xsi:schemaLocation"
        >http://nlp.perseus.tufts.edu/syntax/treebank/1.5 treebank-1.5.xsd</xsl:attribute>
      <xsl:if test="$language">
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="$language"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="pml:aldt_meta/*"/>
      <xsl:for-each select="pml:aldt_trees/pml:LM">
        <xsl:sort select="./@id" data-type="number"/>
        <xsl:call-template name="LM-sentence">
          <xsl:with-param name="lm" select="."/>
          <xsl:with-param name="language" select="$language"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <!--
        Sentence-level list member
        Copy all attributes and non-list elements
        Sort all word-level list members in id order
  -->
  <xsl:template name="LM-sentence">
    <xsl:param name="lm"/>
    <xsl:param name="language"/>

    <xsl:element name="sentence" namespace="">
      <xsl:choose>
        <!-- if this is Greek data -->
        <xsl:when test="$language = 'grc'">
          <!-- Convert span from unicode to betacode -->
          <xsl:attribute name="span" namespace="">
            <xsl:call-template name="uni-to-beta">
              <xsl:with-param name="input" select="$lm/@span"/>
              <xsl:with-param name="upper" select="$upper"/>
            </xsl:call-template>
          </xsl:attribute>
        </xsl:when>

        <!-- if not Greek -->
        <xsl:otherwise>
          <!-- just copy span -->
          <xsl:apply-templates select="$lm/@span"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="$lm/@id|$lm/@document_id|$lm/@subdoc"/>

      <xsl:if test="@primary1">
        <xsl:element name="primary">
          <xsl:value-of select="@primary1"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="@primary2">
        <xsl:element name="primary">
          <xsl:value-of select="@primary2"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="@secondary">
        <xsl:element name="secondary">
          <xsl:value-of select="@secondary"/>
        </xsl:element>
      </xsl:if>

      <xsl:for-each select=".//pml:LM">
        <xsl:sort select="./@id" data-type="number"/>
        <xsl:call-template name="LM-word">
          <xsl:with-param name="lm" select="."/>
          <xsl:with-param name="language" select="$language"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <!--
        Word-level list member
        Copy all attributes
        Set head attribute to be:
          0 if this is child of a sentence-level list member
            (grandparent is not a list member)
          else id of parent word
  -->
  <xsl:template name="LM-word">
    <xsl:param name="lm"/>
    <xsl:param name="language"/>

    <xsl:element name="word" namespace="">
      <xsl:choose>
        <!-- if this is Greek data -->
        <xsl:when test="$language = 'grc'">
          <!-- Convert lemma and form from unicode to betacode -->
          <xsl:attribute name="form" namespace="">
            <xsl:call-template name="uni-to-beta">
              <xsl:with-param name="input" select="$lm/@form"/>
              <xsl:with-param name="upper" select="$upper"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="lemma" namespace="">
            <xsl:call-template name="uni-to-beta">
              <xsl:with-param name="input" select="$lm/@lemma"/>
              <xsl:with-param name="upper" select="$upper"/>
            </xsl:call-template>
          </xsl:attribute>
        </xsl:when>

        <!-- if not Greek -->
        <xsl:otherwise>
          <!-- just copy form and lemma -->
          <xsl:apply-templates select="$lm/@form|$lm/@lemma"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Copy over some of attributes -->
      <xsl:apply-templates select="$lm/@id|$lm/@relation"/>

      <!-- Calculate head from parent's id or 0 if this is root word -->
      <xsl:attribute name="head">
        <xsl:if test="local-name($lm/../..) = 'LM'">
          <xsl:value-of select="$lm/../@id"/>
        </xsl:if>
        <xsl:if test="local-name($lm/../..) != 'LM'">0</xsl:if>
      </xsl:attribute>

      <!--
        Build postag attribute from individual morphological attributes
        Note: templates must be applied in given order to use proper
        positions in postag
      -->
      <xsl:attribute name="postag">
        <xsl:apply-templates select="$aldt-morphology-table" mode="long2short">
          <xsl:with-param name="category">pos</xsl:with-param>
          <xsl:with-param name="key" select="@pos"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$aldt-morphology-table" mode="long2short">
          <xsl:with-param name="category">person</xsl:with-param>
          <xsl:with-param name="key" select="@person"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$aldt-morphology-table" mode="long2short">
          <xsl:with-param name="category">number</xsl:with-param>
          <xsl:with-param name="key" select="@number"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$aldt-morphology-table" mode="long2short">
          <xsl:with-param name="category">tense</xsl:with-param>
          <xsl:with-param name="key" select="@tense"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$aldt-morphology-table" mode="long2short">
          <xsl:with-param name="category">mood</xsl:with-param>
          <xsl:with-param name="key" select="@mood"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$aldt-morphology-table" mode="long2short">
          <xsl:with-param name="category">voice</xsl:with-param>
          <xsl:with-param name="key" select="@voice"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$aldt-morphology-table" mode="long2short">
          <xsl:with-param name="category">gender</xsl:with-param>
          <xsl:with-param name="key" select="@gender"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$aldt-morphology-table" mode="long2short">
          <xsl:with-param name="category">case</xsl:with-param>
          <xsl:with-param name="key" select="@case"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$aldt-morphology-table" mode="long2short">
          <xsl:with-param name="category">degree</xsl:with-param>
          <xsl:with-param name="key" select="@degree"/>
        </xsl:apply-templates>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <!-- Generic template to copy content to new namespace -->
  <xsl:template match="*">
    <xsl:element name="{substring-after(name(.), 'aldt_')}" namespace="">
      <xsl:value-of select="./text()"/>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*"/>
    </xsl:element>
  </xsl:template>

  <!-- Generic template to copy attributes to new namespace -->
  <xsl:template match="@*">
    <xsl:attribute name="{name(.)}" namespace="">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>

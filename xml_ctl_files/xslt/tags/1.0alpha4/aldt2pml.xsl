<?xml version="1.0" encoding="UTF-8"?>

<!--
  Stylesheet to transform XML conforming to
  the Ancient Language Dependency Treebank schema (version 1.5)
  to XML conforming to
  the PML (Prague Markup Language) schema in aldt_schema.xml
  for use in the tred tree editor
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:aldt="http://treebank.alpheios.net/namespaces/aldt"
  exclude-result-prefixes="xs">

  <xsl:include href="beta2unicode.xsl"/>
  <xsl:include href="aldt-util.xsl"/>

  <xsl:strip-space elements="*"/>
  <xsl:variable name="s_pmlNamespace" select="'http://ufal.mff.cuni.cz/pdt/pml/'"/>

  <!-- whether to convert to precomposed or decomposed Unicode -->
  <xsl:variable name="precomposed" select="true()"/>

  <xsl:template match="/">
    <xsl:apply-templates select="/treebank"/>
  </xsl:template>

  <!--  Root node
        Change namespace, add meta and tree elements
        (Note: global variable for namespace doesn't work here)
  -->
  <xsl:template match="treebank">
    <xsl:variable name="language" select="@xml:lang"/>
    <xsl:element name="aldt_treebank"
      namespace="http://ufal.mff.cuni.cz/pdt/pml/">
      <xsl:if test="$language">
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="$language"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:element name="head" namespace="http://ufal.mff.cuni.cz/pdt/pml/">
        <xsl:element name="schema" namespace="http://ufal.mff.cuni.cz/pdt/pml/">
          <xsl:attribute name="href">aldt_schema.xml</xsl:attribute>
        </xsl:element>
      </xsl:element>
      <xsl:element name="aldt_meta" namespace="http://ufal.mff.cuni.cz/pdt/pml/">
        <xsl:apply-templates select="annotator"/>
      </xsl:element>
      <xsl:element name="aldt_trees"
        namespace="http://ufal.mff.cuni.cz/pdt/pml/">
        <xsl:apply-templates select="sentence">
          <xsl:with-param name="language" select="$language"/>
        </xsl:apply-templates>
      </xsl:element>
    </xsl:element>
  </xsl:template>

  <!--
        Convert sentence to list member
        Immediate children are root words for whole sentence
  -->
  <xsl:template match="sentence">
    <xsl:param name="language"/>

    <xsl:element name="LM" namespace="{$s_pmlNamespace}">
      <!--
            Convert annotator names to attributes
            (Haven't figured out how to make elements work in tred)
      -->
      <xsl:if test="primary[1]">
        <xsl:attribute name="primary1">
          <xsl:value-of select="primary[1]"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="primary[2]">
        <xsl:attribute name="primary2">
          <xsl:value-of select="primary[2]"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="secondary">
        <xsl:attribute name="secondary">
          <xsl:value-of select="secondary"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:choose>
        <!-- if this is Greek data -->
        <xsl:when test="$language = 'grc'">
          <!-- convert span from betacode to unicode -->
          <xsl:attribute name="span">
            <xsl:call-template name="beta-to-uni">
              <xsl:with-param name="a_in" select="@span"/>
                  <xsl:with-param name="precomposed" select="$precomposed"/>
            </xsl:call-template>
          </xsl:attribute>
        </xsl:when>
        
        <!-- if not Greek -->
        <xsl:otherwise>
          <!-- just copy span -->
          <xsl:copy-of select="@span"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- copy rest of attributes -->
      <xsl:copy-of select="@*[name(.) != 'span']"/>

      <!-- transform root words in sentence -->
      <xsl:call-template name="word-set">
        <xsl:with-param name="a_words" select="./word[@head='0']"/>
        <xsl:with-param name="a_language" select="$language"/>
      </xsl:call-template>
    </xsl:element>
  </xsl:template>

  <!--
        Convert words to list members
        Immediate children of a word are words dependent on it
        (those whose head attribute equals the word's id)
  -->
  <xsl:template name="word-set">
    <xsl:param name="a_words"/>
    <xsl:param name="a_language"/>

    <xsl:for-each select="$a_words">
      <!--
            Copy over some of attributes
            Note that head attribute is not copied.
            Instead it is converted into nested element hierarchy.
      -->
      <xsl:element name="LM" namespace="http://ufal.mff.cuni.cz/pdt/pml/">
        <xsl:copy-of select="@id|@relation"/>

        <xsl:choose>
          <!-- if this is Greek data -->
          <xsl:when test="$a_language = 'grc'">
            <!-- convert lemma and form from betacode to unicode -->
            <xsl:attribute name="form">
              <xsl:call-template name="beta-to-uni">
                <xsl:with-param name="a_in" select="@form"/>
                <xsl:with-param name="a_precomposed" select="$precomposed"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="lemma">
              <xsl:call-template name="beta-to-uni">
                <xsl:with-param name="a_in" select="@lemma"/>
                <xsl:with-param name="a_precomposed" select="$precomposed"/>
              </xsl:call-template>
            </xsl:attribute>
          </xsl:when>

          <!-- if not Greek -->
          <xsl:otherwise>
            <!-- just copy form and lemma -->
            <xsl:copy-of select="@form|@lemma"/>
          </xsl:otherwise>
        </xsl:choose>

        <!-- Break postag into separate morphological attributes -->
        <xsl:apply-templates select="$s_aldtMorphologyTable" mode="short2long">
          <xsl:with-param name="category">pos</xsl:with-param>
          <xsl:with-param name="key" select="substring(@postag,1,1)"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$s_aldtMorphologyTable" mode="short2long">
          <xsl:with-param name="category">person</xsl:with-param>
          <xsl:with-param name="key" select="substring(@postag,2,1)"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$s_aldtMorphologyTable" mode="short2long">
          <xsl:with-param name="category">number</xsl:with-param>
          <xsl:with-param name="key" select="substring(@postag,3,1)"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$s_aldtMorphologyTable" mode="short2long">
          <xsl:with-param name="category">tense</xsl:with-param>
          <xsl:with-param name="key" select="substring(@postag,4,1)"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$s_aldtMorphologyTable" mode="short2long">
          <xsl:with-param name="category">mood</xsl:with-param>
          <xsl:with-param name="key" select="substring(@postag,5,1)"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$s_aldtMorphologyTable" mode="short2long">
          <xsl:with-param name="category">voice</xsl:with-param>
          <xsl:with-param name="key" select="substring(@postag,6,1)"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$s_aldtMorphologyTable" mode="short2long">
          <xsl:with-param name="category">gender</xsl:with-param>
          <xsl:with-param name="key" select="substring(@postag,7,1)"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$s_aldtMorphologyTable" mode="short2long">
          <xsl:with-param name="category">case</xsl:with-param>
          <xsl:with-param name="key" select="substring(@postag,8,1)"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="$s_aldtMorphologyTable" mode="short2long">
          <xsl:with-param name="category">degree</xsl:with-param>
          <xsl:with-param name="key" select="substring(@postag,9,1)"/>
        </xsl:apply-templates>

        <!-- Recursively build children from this word's dependents -->
        <xsl:variable name="id" select="@id"/>
        <xsl:call-template name="word-set">
          <xsl:with-param name="a_words" select="../word[@head=$id]"/>
          <xsl:with-param name="a_language" select="$a_language"/>
        </xsl:call-template>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <!-- Generic template to copy content to new namespace -->
  <xsl:template match="*">
    <xsl:element name="aldt_{name(.)}" namespace="{$s_pmlNamespace}">
      <xsl:value-of select="./text()"/>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*"/>
    </xsl:element>
  </xsl:template>

  <!-- Generic template to copy attributes to new namespace -->
  <xsl:template match="@*">
    <xsl:attribute name="{name(.)}" namespace="{$s_pmlNamespace}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>

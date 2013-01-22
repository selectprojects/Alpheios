<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:treebank="http://nlp.perseus.tufts.edu/syntax/treebank/1.5" 
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:param name="e_lang" select="//*:treebank/@*:lang"/>
    <xsl:param name="e_queryUrl" select="'http://services-qa.projectbamboo.org/bsp/morphologyservice/analysis/word?'"/>
    <xsl:param name="e_engine" select="'morpheus'"/>
    <xsl:param name="e_params" select="concat('&amp;lang=',$e_lang,'&amp;engine=',$e_engine,'&amp;word=')"/>
    
    <xsl:output media-type="text/xml" omit-xml-declaration="no" method="xml" indent="no"/>
    <xsl:include href="morph-to-codes.xsl"/>
    
    <xsl:variable name="nontext">
        <nontext xml:lang="grc"> “”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\]\{\}\-</nontext>
        <nontext xml:lang="greek"> “”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\]\{\}\-</nontext>
        <nontext xml:lang="ara"> “”—&quot;‘’,.:;?!\[\]\{\}\-&#x060C;&#x060D;</nontext>
        <nontext xml:lang="lat"> “”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\]()\{\}\-</nontext>
        <nontext xml:lang="*"> “”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\]()\{\}\-</nontext>
    </xsl:variable>
    <!--xsl:variable name="refs" select="doc(concat($e_queryUrl,$e_editionUrn))"/-->
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="word">
        <xsl:variable name="match-nontext">
            <xsl:choose>
                <xsl:when test="$e_lang and $nontext/nontext[@xml:lang=$e_lang]">
                    <xsl:value-of select="$nontext/nontext[@xml:lang=$e_lang]"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$nontext/nontext[@xml:lang='*']"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="match_string" select="concat('^[', $match-nontext, ']$')"/>
        <xsl:variable name="punc">
            <xsl:analyze-string select="@form" regex="{$match_string}">
                <xsl:matching-substring><match/></xsl:matching-substring>
                <xsl:non-matching-substring/>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:element name="word">
            <xsl:choose>
                <xsl:when test="$punc/match">
                    <xsl:apply-templates select="@*[not(name() = 'lemma') and not(name() = 'postag') and not(name() = 'relation')]"/>
                    <xsl:attribute name="lemma" select="'punc1'"/>
                    <xsl:attribute name="postag" select="'u--------'"/>
                    <xsl:choose>
                        <xsl:when test="following-sibling::word">
                            <xsl:attribute name="relation" select="'AuxX'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="relation" select="'AuxK'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="results" select="doc(concat($e_queryUrl,$e_params,@form))"/>
                    <xsl:variable name="parsed">
                        <xsl:apply-templates select="$results//entry"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$parsed//morph">
                            <xsl:apply-templates select="@*[not(name() = 'lemma') and not(name() = 'postag')]"/>
                            <xsl:attribute name="lemma" select="(($parsed//morph)[1]/hdwd)[1]"/>
                            <xsl:attribute name="postag" select="(($parsed//morph)[1]/code)[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="@*"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*"></xsl:apply-templates>
            <xsl:apply-templates select="node()"></xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
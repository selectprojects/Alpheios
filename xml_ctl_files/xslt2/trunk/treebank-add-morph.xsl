<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:treebank="http://nlp.perseus.tufts.edu/syntax/treebank/1.5" 
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:param name="e_lang" select="'grc'"/>
    <xsl:param name="e_morphQueryUrl" select="'http://sosol.perseus.tufts.edu/bsp/morphologyservice/analysis/word?lang=REPLACE_LANG&amp;word=REPLACE_WORD&amp;engine=morpheus'"/>
    <xsl:param name="e_annotationQueryUrl" select="'http://sosol.perseus.tufts.edu/bsp/annotationservice/annotation/template/document?document_id=REPLACE_URN&amp;repos_type=cts&amp;mime_type=text/xml&amp;lang=REPLACE_LANG&amp;template_format=Perseus&amp;repos_uri=http://www.perseus.tufts.edu/hopper/CTS'"/>
    <xsl:param name="e_urn" select="'urn:cts:greekLit:tlg0012.tlg001.perseus-grc1:1.1'"/>
    
    
    <xsl:output media-type="text/plain" omit-xml-declaration="no" method="xml" indent="no"/>
    <xsl:include href="morph-to-codes.xsl"/>
    
    <!-- TODO we should split this up into AuxK, AuxX and AuxG -->
    <xsl:variable name="nontext">
        <nontext xml:lang="grc"> “”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\]\{\}\-</nontext>
        <nontext xml:lang="greek"> “”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\]\{\}\-</nontext>
        <nontext xml:lang="ara"> “”—&quot;‘’,.:;?!\[\]\{\}\-&#x060C;&#x060D;</nontext>
        <nontext xml:lang="lat"> “”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\]()\{\}\-</nontext>
        <nontext xml:lang="*"> “”—&quot;‘’,.:;&#x0387;&#x00B7;?!\[\]()\{\}\-</nontext>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:variable name="sentences" select="doc(replace(replace($e_annotationQueryUrl,'REPLACE_LANG',$e_lang),'REPLACE_URN',$e_urn))"/>
        <xsl:apply-templates select="$sentences//treebank:treebank"/>
    </xsl:template>

    <xsl:template match="*:word">
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
        <xsl:element name="word" namespace="http://nlp.perseus.tufts.edu/syntax/treebank/1.5">
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
                    <xsl:variable name="url" select="replace(replace($e_morphQueryUrl,'REPLACE_LANG',$e_lang),'REPLACE_WORD',@form)"/>
                    <xsl:variable name="results" select="doc($url)"/>
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
<?xml version="1.0" encoding="UTF-8"?>
<!-- tokenization functions (taken from alph-markwords.xquery)-->
<!-- wraptokens breaks text on language-specific tokens as defined in the nontext and breaktext variables and wraps the individual text tokens in tei namespaced wd elements -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    
    <xsl:variable name="nontext_all">
        <xsl:element name="nontext">
            <xsl:attribute name="lang">grc</xsl:attribute>
            <xsl:text>\s“”—&quot;‘’,.:;&#x0387;&#x00B7;\?!\[\]{}\-</xsl:text>    
        </xsl:element>
        <xsl:element name="nontext">
            <xsl:attribute name="lang">ara</xsl:attribute>
            <xsl:text>\s“”—&quot;‘’,.:;\?!\[\]{}\-</xsl:text>
        </xsl:element>
        <xsl:element name="nontext">
            <xsl:attribute name="lang">*</xsl:attribute>
            <xsl:text>\s“”—&quot;‘’,.:;&#x0387;&#x00B7;\?!\[\](){}\-</xsl:text>
        </xsl:element>
    </xsl:variable>
    <xsl:variable name="breaktext_all">
        <xsl:element name="breaktext">
            <xsl:attribute name="lang">*</xsl:attribute>
            <xsl:text>᾽</xsl:text>
        </xsl:element>
    </xsl:variable>    
        
    <xsl:template name="wraptokens">
        <xsl:param name="a_lang"/>
        <xsl:param name="a_text"/>
        <xsl:param name="a_parentId"/>
        <xsl:param name="a_startPos"/>
        <xsl:variable name="nontext">
            <xsl:choose>
                <xsl:when test="$nontext_all/nontext[@lang=$a_lang]">
                    <xsl:value-of select="$nontext_all/nontext[@lang=$a_lang]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$nontext_all/nontext[@lang='*']"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable> 
        <xsl:variable name="breaktext">
            <xsl:choose>
                <xsl:when test="$breaktext_all/breaktext[@lang=$a_lang]">
                    <xsl:value-of select="$breaktext_all/breaktext[@lang=$a_lang]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$breaktext_all/breaktext[@lang='*']"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable> 
        
        <xsl:variable name="matchtext">
            <xsl:choose>
                <xsl:when test="$breaktext">
                    <xsl:value-of select="concat('^([^', $nontext, $breaktext, ']+[',$breaktext,']?).*')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('^([^', $nontext, $breaktext, ']+).*')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    
        <xsl:variable name="matchnontext">
            <xsl:value-of select="concat('^([', $nontext, ']+).*')"/>
        </xsl:variable>
        <xsl:call-template name="wraptext">
            <xsl:with-param name="a_text" select="$a_text"/>
            <xsl:with-param name="a_matchtext" select="$matchtext"/>
            <xsl:with-param name="a_matchnontext" select="$matchnontext"/>
            <xsl:with-param name="a_parentId" select="concat($a_parentId,'-',$a_startPos)"/>
            <xsl:with-param name="a_startPos" select="1"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="wraptext">
        <xsl:param name="a_text"/>
        <xsl:param name="a_matchtext"/>
        <xsl:param name="a_matchnontext"/>
        <xsl:param name="a_parentId"/>
        <xsl:param name="a_startPos"/>
        <xsl:variable name="istext" select="matches($a_text,$a_matchtext)"/>
        <xsl:variable name="t">
            <xsl:choose>
                <xsl:when test="$istext">
                    <xsl:value-of select="replace($a_text,$a_matchtext,'$1')"/>                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace($a_text,$a_matchnontext,'$1')"/>                
                </xsl:otherwise>
            </xsl:choose>                
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$istext">
                <wd xmlns="http://www.tei-c.org/ns/1.0" n="{concat($a_parentId,'-',$a_startPos)}"><xsl:value-of select="$t"/></wd>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$t"/></xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="remainder" select="substring-after($a_text,$t)"/>
        <xsl:variable name="nextPos">
            <xsl:choose>
                <!-- only increment the position index if we have output a word -->
                <xsl:when test="$istext"><xsl:value-of select="$a_startPos+1"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$a_startPos"/></xsl:otherwise>
            </xsl:choose>            
        </xsl:variable>
        <xsl:if test="$remainder">
            <xsl:call-template name="wraptext">
                <xsl:with-param name="a_text" select="$remainder"/>
                <xsl:with-param name="a_matchtext" select="$a_matchtext"/>
                <xsl:with-param name="a_matchnontext" select="$a_matchnontext"/>
                <xsl:with-param name="a_parentId" select="$a_parentId"/>
                <xsl:with-param name="a_startPos" select="$nextPos"/>                
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>

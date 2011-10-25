<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    
    xmlns:forms="http://alpheios.net/namespaces/forms"
    version="2.0">
   
    <xsl:output indent="yes"/>
    <xsl:param name="e_lang"/>
    <xsl:param name="e_refs"/>
    <xsl:param name="e_pmatch"/>
    <xsl:param name="e_excludePofs"/>
    
    <xsl:variable name="refsdoc" select="doc($e_refs)"/>
    
    <xsl:key name="urn-by-ref" match="ref" use="text()"/> 
    
   
    <xsl:template match="/">
        <lemmas>
                     <xsl:choose>
                        <xsl:when test="$e_pmatch and $e_excludePofs = '1'">
                            <xsl:apply-templates select="//word[@postag and 
                                    not(matches(@postag,$e_pmatch)) and not(matches(@postag,'^-'))]"/>
                        </xsl:when>
                        <xsl:when test="$e_pmatch  and not($e_excludePofs = '1')">
                            <xsl:apply-templates select="//word[matches(@postag,$e_pmatch)]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="//word"/>
                        </xsl:otherwise>
                    </xsl:choose>
        </lemmas>
    </xsl:template>
    
    <xsl:template match="word">
        <xsl:message><xsl:value-of select="@id"></xsl:value-of></xsl:message>
        <xsl:variable name="s" select="../@id"/>
        <xsl:variable name="w" select="@id"/>
        <xsl:variable name="lookup" select="concat($s,'-',$w)"/>
        <xsl:variable name="ref" select="$refsdoc/refs/key('urn-by-ref', $lookup)[1]/@urn"/>
        <xsl:if test="$ref">
            <xsl:variable name="form" select="@form"/>
            <!-- TODO this calculation of position is incorrect  we need it in the context of the citation not
            the sentence  - use ref for now to make sure we get unique urns -->
            <xsl:variable name="position" select="count(preceding-sibling::word[@form=$form]) + 1"/>
            <xsl:variable name="sense" select="replace(@lemma,'^(.*?)(\d+)$','$2')"/>
            <xsl:variable name="urn" select="concat($ref,':',$form, '[',$position,']')"/>
            <xsl:variable name="lemma">
                <xsl:choose>
                <xsl:when test="matches(@lemma,'\d+$')">
                    <xsl:value-of select="replace(@lemma,'^(.*?)(\d+)$','$1')"/>
                </xsl:when>
                    <xsl:otherwise><xsl:value-of select="@lemma"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <lemma lang="{$e_lang}" form="{$form}" sense="{$sense}" lemma="{$lemma}">
                <forms:urn><xsl:value-of select="$urn"/></forms:urn>
            </lemma>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
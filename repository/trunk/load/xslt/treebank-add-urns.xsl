<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:treebank="http://nlp.perseus.tufts.edu/syntax/treebank/1.5" 
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:param name="e_queryUrl" select="'http://repos1.alpheios.net/exist/rest/db/xq/treebank-get-cts.xq?urn='"/>
    <xsl:param name="e_refs"/>
    <xsl:param name="e_editionUrn"></xsl:param>
    
    <xsl:output media-type="text/xml" omit-xml-declaration="no" method="xml" indent="no"/>
    
    <xsl:variable name="refs" select="doc(concat($e_queryUrl,$e_editionUrn))"/>
    
    <xsl:variable name="word-lookup">
        <refs>
            <xsl:for-each select="$refs/refs/ref">
                <xsl:variable name="urnParts" select="tokenize(@urn,':')"/>
                <xsl:variable name="editionParts" select="tokenize($urnParts[4],'\.')"/>
                <xsl:variable name="notionalUrn" 
                    select="string-join(
                        ($urnParts[1],$urnParts[2],$urnParts[3],string-join(($editionParts[1],$editionParts[2]),'.'),$urnParts[5]),':')"/>
                <xsl:element name="ref">
                    <xsl:attribute name="id"><xsl:value-of select="."/></xsl:attribute>
                    <xsl:copy-of select="$notionalUrn"></xsl:copy-of>
                </xsl:element> 
            </xsl:for-each>
        </refs>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="sentence">
        <xsl:variable name="id_match" select="concat('^',@id,'-')"/>
        <xsl:variable name="urns" select="distinct-values($word-lookup/refs/ref[matches(@id,$id_match)])"/>
        <xsl:choose>
            <xsl:when test="count($urns) > 0">
                <xsl:element name="sentence">   
                    <!-- replace the subdoc attribute with urns -->
                    <xsl:attribute name="subdoc" select="$urns"/>
                    <xsl:apply-templates select="@*[not(local-name(.) = 'subdoc')]"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="word">
        <xsl:element name="word">
            <xsl:variable name="id" select="concat(parent::sentence/@id,'-',@id)"/>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="cite" select="distinct-values($word-lookup/refs/ref[@id=$id])"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
        
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*"></xsl:apply-templates>
            <xsl:apply-templates select="node()"></xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
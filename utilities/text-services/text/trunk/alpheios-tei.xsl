<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    
    <!-- shared functionality for converting TEI documents to Alpheios Enhanced Display -->
    
    <xsl:param name="htmlTitlePrefix" select="'Alpheios:'"/>
    
    <!-- generates the title for the document from the teiHeader elements -->
    <xsl:template name="generateAlpheiosTitle">
        <xsl:variable name="myName">
            <xsl:value-of select="local-name(.)"/>
        </xsl:variable>
        <xsl:value-of select="$htmlTitlePrefix"/>
        <xsl:if test="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/text()">
            <xsl:value-of select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/>
            <xsl:text>, </xsl:text>
        </xsl:if>
        <xsl:variable name="title" select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"></xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($title,'.')">
                <xsl:value-of select="substring-before($title,'.')"/>
            </xsl:when>
            <xsl:otherwise> 
                <xsl:value-of select="$title"/>
                <xsl:if test="$myName='div2' and @n">
                    (<xsl:value-of select="@n"/>)
                </xsl:if>
                <xsl:if test="$myName='div2' and @alpheios-subtitle">
                    - <xsl:value-of select="@alpheios-subtitle"/>
                </xsl:if>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>  
</xsl:stylesheet>

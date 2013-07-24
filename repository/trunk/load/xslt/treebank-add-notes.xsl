<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- Merges a separate file of per-word notes into a custom notes attribute -->
    <!-- Notes file should be in the format <notes><note sid="sentenceid" wid="wordid" lemma="lemma">note</note></notes> -->
    <!-- e.g. <notes><note sid="2942875" wid="44459117" lemma="ipse1">d=- n=- c=1</note></note> -->
    
    <xsl:param name="e_notes"/>
    <xsl:variable name="notes" select="doc($e_notes)"/>
    
    <xsl:template match="/">
        <xsl:message>Notes: <xsl:value-of select="count($notes//note)"/></xsl:message>
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <xsl:template match="word">
        <xsl:variable name="sid" select="../@id"/>
        <xsl:variable name="wid" select="@cid"/>
        <xsl:variable name="lemma" select="@lemma"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:variable name="note1" select="$notes//note[@sid=$sid and @wid=$wid and @lemma=$lemma]"/>
            <xsl:variable name="note2" select="$notes//note[@sid=$sid and @wid=$wid]"/>
            <xsl:choose>
                <xsl:when test="$note1">
                    <xsl:attribute name="notes" select="$note1"/>    
                </xsl:when>
                <xsl:when test="count($note2) = 1">
                    <xsl:attribute name="notes" select="$note2"/>
                    <xsl:attribute name="check" select="$note2/@lemma"/>
                </xsl:when>
                <xsl:when test="count($note2) > 1">
                    <xsl:attribute name="check" select="string-join($note2/@lemma, ' ')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xd="http://www.pnp-software.com/XSLTdoc" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    exclude-result-prefixes="tei xd" 
    version="1.0">
    <xd:doc type="string" class="CSS">
        CSS file for Alpheios
    </xd:doc>
    <xsl:param name="alpheiosCss">alph-tei.css</xsl:param>
    <xd:doc type="string">
        Skip the javascript for Alpheios
    </xd:doc>
    <xsl:param name="skipJavascript">true</xsl:param>
    <xd:doc type="string">
        Generate Alpheios element ids using the type
    </xd:doc>
    <xsl:param name="alpheiosNTypeIDs">true</xsl:param>
    <xd:doc type="string">
        Flag to indicate alignment is available
    </xd:doc>
    <xsl:param name="alpheiosHasAlignment">true</xsl:param>
    <xd:doc type="string">
        Url to the Treebank morphology xquery for this document
    </xd:doc>
    <xsl:param name="alpheiosTreebankUrl" select="concat(
            'http://repos.alpheios.net:8080/exist/rest/db/xq/treebank-getmorph.xq?f=',
            $alpheiosTreebankDocId,
            '&amp;w=WORD')"/>            
    <xd:doc type="string">
        Url to the Treebank svg xquery for this document
    </xd:doc>
    <xsl:param name="alpheiosTreebankDiagramUrl"
            select="concat(
            'version=1.0;http://repos.alpheios.net:8080/exist/rest/db/app/treebank-editsentence.xhtml?doc=',
            $alpheiosTreebankDocId,
            '&amp;app=viewer&amp;id=SENTENCE&amp;w=WORD')"/>    
    <xd:doc type="string">
          Flag to indicate whether or not this is alpheios pedagogical text
    </xd:doc>
     <xsl:param name="alpheiosPedagogicalText">true</xsl:param>
    <xd:doc type="string">
        Base path to the alpheios pedagogical text site
    </xd:doc>
    <xsl:param name="alpheiosSiteBaseUrl">http://alpheios.net/alpheios-texts</xsl:param>
    <xd:doc type="string">
        Instruction to skip navigation elements
    </xd:doc>
    <xsl:param name="alpheiosSkipNav">false</xsl:param>
    <xd:doc type="string">
        Document Id (if not supplied, will be taken from the id element in the root document element)
    </xd:doc>
    <xsl:param name="alpheiosDocId" select="/TEI.2/@id"></xsl:param>
    <xd:doc type="string">
        Treebank document Id (if not supplied, will use alpheiosDocId)
    </xd:doc>
    <xsl:param name="alpheiosTreebankDocId" select="$alpheiosDocId"></xsl:param>   
</xsl:stylesheet>

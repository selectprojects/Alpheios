<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
        <xsl:include href="funding.xsl"/>            
        <xsl:template match="/">
            <xsl:variable name="docCount"><xsl:value-of select="results/count[@type='docForms']"/></xsl:variable>
            <xsl:variable name="docWordCount"><xsl:value-of select="results/count[@type='docTotalWords']"/></xsl:variable>
            <xsl:variable name="vocabCount"><xsl:value-of select="results/count[@type='vocabLemmas']"/></xsl:variable>
            <xsl:variable name="formLemmaFoundCount"><xsl:value-of select="results/count[@type='formLemmaFound']"/></xsl:variable>
            <xsl:variable name="possible"><xsl:if test="results/@docType !='treebank'"><xsl:text>possible </xsl:text></xsl:if></xsl:variable> 
            <xsl:variable name="analysis_string">
                <xsl:choose>
                        <xsl:when test="//lemmas/@found = 'true'">Found</xsl:when>
                        <xsl:otherwise>Not Found</xsl:otherwise>                
                </xsl:choose>
            </xsl:variable>
            <html>
                <head>
                    <link rel="stylesheet" type="text/css" href="../css/alpheios-vocab-anal.css"/>  
                    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"></script>
                    <script type="text/javascript" src="../script/alpheios-vocab.js"></script>
                </head>
                <body>
                    <h1 class="apptitle">Learned Vocabulary Analysis Results</h1>
                    <div class="results">
                        <div class="result">
                            <div class="label">Target Text:</div>
                            <xsl:if test="results/docUrns">
                                <ul>                                
                                    <xsl:for-each select="results/docUrns/urn">
                                        <li><xsl:value-of select="@label"/></li>    
                                    </xsl:for-each>                                            
                                </ul>                                            
                            </xsl:if>
                            <xsl:if test="results/docText">
                                <xsl:value-of select="results/docText"/>
                            </xsl:if>
                        </div>
                        <div class="result">
                            <div class="label">Vocabulary Source:</div>
                            <ul>                                                         
                                    <xsl:for-each select="results/vocabUrns/urn">
                                        <li><xsl:value-of select="@label"/></li>    
                                    </xsl:for-each>                                                                            
                            </ul>
                        </div>                        
                        <div class="result"><span class="label">Number of  words in target text</span><span><xsl:value-of select="$docWordCount"/></span></div>
                        <div class="result"><span class="label">Number of <xsl:value-of select="$possible"/>distinct form+lemma+sense in target text:</span><span><xsl:value-of select="$docCount"/></span></div>
                        <div class="result"><span class="label">Number of <xsl:value-of select="$possible"/>lemmas in vocabulary:</span><span><xsl:value-of select="$vocabCount"/></span></div>
                        <div class="result"><span class="label">% <xsl:value-of select="$analysis_string"/> (of <xsl:value-of select="$possible"/>lemmas in target text):</span><span><xsl:value-of select="format-number($formLemmaFoundCount div $docCount,'##.##%')"/></span></div>
                    </div>
                    <div class="detail">
                        <xsl:apply-templates select="results/lemmas"/>
                    </div>
                    <div class="rights_info">Alpheios is free software: you can redistribute it and/or modify it under the terms of the <a href="http://www.gnu.org/licenses/">GNU General Public License</a> as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.</div>
                    <xsl:copy-of select="$funding"/>
                  </body>
            </html>
        </xsl:template>
    
        <xsl:template match="lemmas">
            <xsl:if test="match">
            <table>
                <tr><th>Form</th><th>Lemma</th><th>Sense</th><th>Matched Form</th><th>Matched Sense</th><th>Refs</th></tr>
                    <xsl:for-each select="match">
                        <tr>
                            <td><xsl:value-of select="@form"/></td>
                            <td><xsl:value-of select="@lemma"/>
                                <xsl:if test="@matchWord != @lemma">
                                    (Matched on <xsl:value-of select="@matchWord"/>)
                                </xsl:if>
                            </td>
                            <td><xsl:value-of select="@sense"/></td>
                            <td><xsl:value-of select="@matchForm"/></td>
                            <td>Not implemented</td><!-- not yet implemented-->
                            <td>
                                <xsl:apply-templates select="."/>
                            </td>
                        </tr>
                    </xsl:for-each>                
            </table>
            </xsl:if>
        </xsl:template>
    
        <xsl:template match="tei:ptr[not(starts-with(@type,'paging'))]">
            <div class="urn"><a href="{@target}" target="_blank"><xsl:value-of select="."/></a></div>
        </xsl:template>
    
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    
        <xsl:template match="/">
            <xsl:variable name="docCount"><xsl:value-of select="results/count[@type='docForms']"/></xsl:variable>
            <xsl:variable name="vocabCount"><xsl:value-of select="results/count[@type='vocabLemmas']"/></xsl:variable>
            <xsl:variable name="formLemmaFoundCount"><xsl:value-of select="results/count[@type='formLemmaFound']"/></xsl:variable>
            <xsl:variable name="analysis_string">
                <xsl:choose>
                        <xsl:when test="//lemmas/@found = 'true'">Coverage Of </xsl:when>
                        <xsl:otherwise>Not Found In</xsl:otherwise>                
                </xsl:choose>
            </xsl:variable>
            <html>
                <head>
                    <link rel="stylesheet" type="text/css" href="../css/alpheios-vocab-anal.css"/>  
                    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"></script>
                    <script type="text/javascript" src="../script/alpheios-vocab.js"></script>
                </head>
                <body>
                    <h1>Alpheios Learned Vocabulary Analysis Results</h1>
                    <div class="results">
                        <div class="result">
                            <div class="label">Target Text:</div>
                            <ul>                                
                                <xsl:for-each select="results/docUrns/urn">
                                    <li><xsl:value-of select="@label"/></li>    
                                </xsl:for-each>                                            
                              </ul>                                                           
                        </div>
                        <div class="result">
                            <div class="label">Vocabulary Source:</div>
                            <ul>                                                         
                                    <xsl:for-each select="results/vocabUrns/urn">
                                        <li><xsl:value-of select="@label"/></li>    
                                    </xsl:for-each>                                                                            
                            </ul>
                        </div>                        
                        <div class="result"><span class="label">Number of <xsl:if test="results/@docType !='treebank'">possible </xsl:if> words in target text:</span><span><xsl:value-of select="$docCount"/></span></div>
                        <div class="result"><span class="label">Number of <xsl:if test="results/@vocabType='morphology'">possible </xsl:if> lemmas in vocabulary:</span><span><xsl:value-of select="$vocabCount"/></span></div>
                        <div class="result"><span class="label">Vocabulary <xsl:value-of select="$analysis_string"/> Target Text:</span><span><xsl:value-of select="format-number($formLemmaFoundCount div $docCount,'##.##%')"/></span></div>
                    </div>
                    <div class="detail">
                        <xsl:apply-templates select="results/lemmas"/>
                    </div>
                </body>
            </html>
        </xsl:template>
    
        <xsl:template match="lemmas">
            <table>
                <tr><th>Form</th><th>Lemma</th><th>Matched Form</th><th>Matched Sense</th><th>Refs</th></tr>
                    <xsl:for-each select="match">
                        <tr>
                            <td><xsl:value-of select="@form"/></td>
                            <td><xsl:value-of select="@lemma"/></td>
                            <td><xsl:value-of select="@matchForm"/></td>
                            <td>NA</td><!-- not yet implemented-->
                            <td>
                                <xsl:apply-templates select="."/>
                            </td>
                        </tr>
                    </xsl:for-each>                
            </table>
        </xsl:template>
    
        <xsl:template match="tei:ptr[not(starts-with(@type,'paging'))]">
            <div class="urn"><a href="{@target}" target="_blank"><xsl:value-of select="."/></a></div>
        </xsl:template>
    
</xsl:stylesheet>

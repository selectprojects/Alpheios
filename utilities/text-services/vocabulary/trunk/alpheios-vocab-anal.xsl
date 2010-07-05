<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    
        <xsl:template match="/">
            <xsl:variable name="docCount"><xsl:value-of select="results/count[@type='docForms']"/></xsl:variable>
            <xsl:variable name="vocabCount"><xsl:value-of select="results/count[@type='vocabLemmas']"/></xsl:variable>
            <xsl:variable name="formLemmaFoundCount"><xsl:value-of select="results/count[@type='formLemmaFound']"/></xsl:variable>
            <html>
                <head>
                    <link rel="stylesheet" type="text/css" href="../css/alpheios-vocab-anal.css"/>  
                    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"></script>
                    <script type="text/javascript" src="../script/alpheios-vocab.js"></script>
                </head>
                <body>
                    <h1>Alpheios Learned Vocabulary Analysis Results</h1>
                    <div class="results">
                        <div class="result"><span class="label">Target Text:</span><span><xsl:value-of select="results/@docUrn"/></span></div>
                        <div class="result"><span class="label">Vocabulary Source:</span><span><xsl:value-of select="results/@vocabUrn"/></span></div>
                        <div class="result"><span class="label">Number of <xsl:if test="results/@docType !='treebank'">possible </xsl:if> words in target text:</span><span><xsl:value-of select="$docCount"/></span></div>
                        <div class="result"><span class="label">Number of <xsl:if test="results/@vocabType='morphology'">possible </xsl:if> lemmas in target vocabulary:</span><span><xsl:value-of select="$vocabCount"/></span></div>
                        <div class="result"><span class="label">Vocabulary Coverage of Target Text:</span><span><xsl:value-of select="format-number($formLemmaFoundCount div $docCount,'##.##%')"/></span></div>
                    </div>
                    <div class="detail">
                        <xsl:apply-templates select="results/formsFound"/>
                    </div>
                </body>
            </html>
        </xsl:template>
    
        <xsl:template match="formsFound">
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

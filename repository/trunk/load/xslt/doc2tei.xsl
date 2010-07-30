<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"    
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    >
    <xsl:param name="lang"/>
    <xsl:param name="docId"/>    
    <xsl:param name="bookId"/>
    <xsl:param name="pageId"/>
    <xsl:output indent="yes" media-type="text/xml"/>
    <xsl:include href="file:///c:/work/xml_ctl_files/xslt/trunk/arabic-uni-util.xsl"/>
    <xsl:include href="tokenize.xsl"/>

      
    <xsl:template match="document">
        <TEI xmlns="http://www.tei-c.org/ns/1.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.tei-c.org/ns/1.0 http://www.tei-c.org/release/xml/tei/custom/schema/xsd/tei.xsd">
            <xsl:apply-templates/>
         </TEI>
    </xsl:template>
    
    <xsl:template match="head">                                        
            <teiHeader xmlns="http://www.tei-c.org/ns/1.0">
                <fileDesc>
                    <titleStmt><title xml:lang="{$lang}"><xsl:value-of select="title"/></title>    
                    <sponsor>Perseus Project, Tufts University</sponsor>
                    <principal>Gregory Crane</principal>
                     <funder n="org:AnnCPB">The Annenberg CPB/Project</funder>
                    </titleStmt>
                    <publicationStmt>
                        <publisher>Trustees of Tufts University</publisher>
                        <pubPlace>Medford, MA</pubPlace>
                        <authority>Perseus Project</authority>
                        <availability status="free">
                            <p>This text may be freely distributed, subject to the following
                                restrictions:</p>
                            <list>
                                <item>You credit Perseus, as follows, whenever you use the document:
                                    <quote>Text provided by Perseus Digital Library, with funding from The U.S. Department of Education.</quote>
                                </item>
                                <item>You leave this availability statement intact.</item>
                                <item>You use it for non-commercial purposes only.</item>
                                <item>You offer Perseus any modifications you make.</item>
                            </list>
                        </availability>
                    </publicationStmt>
                    <notesStmt><note anchored="yes" place="unspecified">Basic XML tagging by Alpheios Technical Services, LLC.</note></notesStmt>
                    <sourceDesc default="NO"><bibl default="NO" /></sourceDesc>                    
                </fileDesc>
            </teiHeader>     
    </xsl:template>
    
    <xsl:template match="body">
        <text xml:lang="{$lang}" xmlns="http://www.tei-c.org/ns/1.0">
            <body>
                <div1 type="book" n="{$bookId}" org="uniform" sample="complete">
                    <div2 type="page" n="{$pageId}">
                        <xsl:apply-templates select="para"/>
                    </div2>
                </div1>                        
            </body>
        </text>        
    </xsl:template>
       
    <xsl:template match="para">
        <xsl:variable name="id">
            <xsl:value-of select="position()"/>
        </xsl:variable>                
         <xsl:element namespace="http://www.tei-c.org/ns/1.0" name="p">
             <xsl:attribute name="rend"><xsl:value-of select="align/@type"/></xsl:attribute>                              
             <xsl:attribute name="n" select="$id"/>             
             <xsl:apply-templates>
                 <xsl:with-param name="a_id" select="$id"/>
             </xsl:apply-templates>
         </xsl:element>                      
    </xsl:template>                    
    
    <xsl:template match="text()">
        <xsl:param name="a_id"></xsl:param>
        <xsl:call-template name="text">
            <xsl:with-param name="a_text" select="."/>
            <xsl:with-param name="a_id" select="$a_id"/>
        </xsl:call-template>                                   
        
    </xsl:template>
    
    <xsl:template name="text">     
        <xsl:param name="a_id"/>
        <xsl:param name="a_text"/>
        <xsl:for-each select="tokenize(.,'\s+')">            
            <xsl:variable name="startPos" select="position()"/>
            <xsl:call-template name="wraptokens">
                <xsl:with-param name="a_parentId" select="$a_id"/>
                <xsl:with-param name="a_startPos" select="$startPos"/>
                <xsl:with-param name="a_text" select="current()"/>
                <xsl:with-param name="a_lang" select="$lang"/>
            </xsl:call-template>            
        </xsl:for-each>                
    </xsl:template>
    
    <xsl:template match="linebreak">
        <tei:lb/>
    </xsl:template>
    
   
</xsl:stylesheet>

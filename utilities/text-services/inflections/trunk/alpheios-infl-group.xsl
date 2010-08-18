<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:forms = "http://alpheios.net/namespaces/forms">
    <xsl:output media-type="text/xml" indent="yes"/>
    <xsl:param name="e_sort" select="'ending'"/>
    <xsl:param name="e_pofs" select="noun"/>
    <xsl:template match="//forms">        
        <inflections xml:lang="{@*[local-name() = lang]}">
            <xsl:choose>
                <xsl:when test="$e_sort='ending'">
                    <xsl:for-each-group select="//instance" 
                        group-by="string(forms:infl/forms:term/forms:suff/text())">
                        <xsl:element name="ending-set">
                            <xsl:element name="infl-ending"><xsl:copy-of select="current-grouping-key()"></xsl:copy-of></xsl:element>
                            <xsl:variable name="infls">
                                <xsl:call-template name="group-infls"/>                                                                              
                            </xsl:variable>                            
                                <xsl:for-each select="$infls/infl-ending-set">
                                    <xsl:copy-of select="."></xsl:copy-of>
                                </xsl:for-each>                            
                         <xsl:element name="count"><xsl:value-of select="count($infls/infl-ending-set/refs/urn)"/></xsl:element>                                                               
                     </xsl:element>
                     </xsl:for-each-group>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$e_pofs = 'verb'">
                            <xsl:for-each-group select="//forms:infl" group-by="string(forms:voice)">
                                <xsl:for-each-group select="current-group()" group-by="string(forms:mood)">
                                    <xsl:for-each-group select="current-group()" group-by="string(forms:tense)">
                                        <xsl:for-each-group select="current-group()" group-by="string(forms:pers)">                                            
                                                <xsl:for-each-group select="current-group()" group-by="string(forms:num)">
                                                    <xsl:element name="infl-ending-set">                                                        
                                                        <xsl:for-each 
                                                            select="current-group()//*[matches(local-name(),'^case|num|gend|voice|pers|tense|mood$')]">                                        
                                                            <xsl:attribute name="{local-name(.)}"><xsl:value-of select="current()"/></xsl:attribute>                                                                                  
                                                        </xsl:for-each>                
                                                        <xsl:variable name="endings">
                                                            <xsl:call-template name="group-endings"/>                                                                              
                                                        </xsl:variable>                            
                                                        <xsl:for-each select="$endings/infl-ending">
                                                            <xsl:copy-of select="."></xsl:copy-of>
                                                        </xsl:for-each>                            
                                                        <xsl:element name="count"><xsl:value-of select="count($endings/infl-ending/refs/urn)"/></xsl:element>                                                                                  
                                                    </xsl:element>                                
                                                </xsl:for-each-group>
                                        </xsl:for-each-group>
                                    </xsl:for-each-group>                    
                                </xsl:for-each-group>                               
                               </xsl:for-each-group>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each-group select="//forms:infl" group-by="string(forms:case)">
                                <xsl:for-each-group select="current-group()" group-by="string(forms:num)">
                                    <xsl:for-each-group select="current-group()" group-by="string(forms:gend)">                                                                               
                                        <xsl:element name="infl-ending-set">                               
                                            <xsl:for-each 
                                                select="current-group()//*[matches(local-name(),'^case|num|gend|voice|pers|tense|mood$')]">                                        
                                                <xsl:attribute name="{local-name(.)}"><xsl:value-of select="current()"/></xsl:attribute>                                                                                  
                                            </xsl:for-each>                
                                            <xsl:variable name="endings">
                                                <xsl:call-template name="group-endings"/>                                                                              
                                            </xsl:variable>                            
                                            <xsl:for-each select="$endings/infl-ending">
                                                <xsl:copy-of select="."></xsl:copy-of>
                                            </xsl:for-each>                            
                                            <xsl:element name="count"><xsl:value-of select="count($endings/infl-ending/refs/urn)"/></xsl:element>                                                               
                                        </xsl:element>
                                    </xsl:for-each-group>
                                </xsl:for-each-group>
                            </xsl:for-each-group>                                
                        </xsl:otherwise>
                    </xsl:choose>
                        
                </xsl:otherwise>
            </xsl:choose>
                    
        </inflections>
    </xsl:template>
    
    <xsl:template name="group-infls">
        <xsl:choose>
            <xsl:when test="$e_pofs = 'verb'">
                <xsl:for-each-group select="current-group()" group-by="string(forms:infl/forms:voice)">
                    <xsl:for-each-group select="current-group()" group-by="string(forms:infl/forms:mood)">
                        <xsl:for-each-group select="current-group()" group-by="string(forms:infl/forms:tense)">
                            <xsl:for-each-group select="current-group()" group-by="string(forms:infl/forms:pers)">                                            
                                <xsl:for-each-group select="current-group()" group-by="string(forms:infl/forms:num)">
                                    <xsl:element name="infl-ending-set">                               
                                        <xsl:attribute name="count" select="count(distinct-values(current-group()/forms:urn))"/>
                                        <xsl:for-each 
                                            select="current-group()//*[matches(local-name(),'^case|num|gend|voice|pers|tense|mood$')]">                                        
                                            <xsl:attribute name="{local-name(.)}"><xsl:value-of select="current()"/></xsl:attribute>                                            
                                        </xsl:for-each>
                                        <xsl:element name="refs">
                                            <xsl:for-each select="distinct-values(current-group()/forms:urn)">
                                                <xsl:element name="urn"><xsl:value-of select="."/></xsl:element>
                                            </xsl:for-each>                
                                        </xsl:element>                                                                                    
                                        </xsl:element>
                                </xsl:for-each-group>
                            </xsl:for-each-group>
                        </xsl:for-each-group>                    
                    </xsl:for-each-group>
                 </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each-group select="current-group()" group-by="string(forms:infl/forms:case)">
                    <xsl:for-each-group select="current-group()" group-by="string(forms:inf/forms:num)">
                        <xsl:for-each-group select="current-group()" group-by="string(forms:infl/forms:gend)">                                                                               
                            <xsl:element name="infl-ending-set">
                                <xsl:attribute name="count" select="count(distinct-values(current-group()/forms:urn))"/>
                                <xsl:for-each 
                                    select="current-group()//*[matches(local-name(),'^case|num|gend|voice|pers|tense|mood$')]">                                        
                                    <xsl:attribute name="{local-name(.)}"><xsl:value-of select="current()"/></xsl:attribute>
                                </xsl:for-each>
                                <xsl:element name="refs">
                                    <xsl:for-each select="distinct-values(current-group()/forms:urn)">
                                        <xsl:element name="urn"><xsl:value-of select="."/></xsl:element>
                                    </xsl:for-each>                
                                </xsl:element>                                                                    
                            </xsl:element>
                        </xsl:for-each-group>
                    </xsl:for-each-group>
                </xsl:for-each-group>                                
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template name="group-endings">
        <xsl:for-each-group select="current-group()" 
            group-by="string(forms:term/forms:suff/text())">
            <infl-ending>
                <xsl:attribute name="count" select="count(distinct-values(current-group()/../forms:urn))"/>
                <xsl:value-of select="current-grouping-key()"/>
                <xsl:element name="refs">
                    <xsl:for-each select="distinct-values(current-group()/preceding-sibling::forms:urn)">
                        <xsl:element name="urn"><xsl:value-of select="."/></xsl:element>
                    </xsl:for-each>                
                </xsl:element>
            </infl-ending>
        </xsl:for-each-group>                        
    </xsl:template>
</xsl:stylesheet>

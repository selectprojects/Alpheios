<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"    
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:m="http://mulberrytech.com/xslt/util"
        exclude-result-prefixes="xs m">
        
    <xsl:output xml:space="preserve"  indent="yes" method="xml" />      
    
    <xsl:template match="/">
        <xsl:apply-templates/>                    
    </xsl:template>
        
        <xsl:template match="body">
            <body>
                <xsl:apply-templates select="@*"/>
                <xsl:for-each-group select="m:bubble-up-breaks(.)/node()"
                    group-adjacent="not(self::pb[not(@type)] or self::pb[@type='primary'])">
                    <xsl:if test="current-grouping-key() and current-group()/node()">
                        <div0 type="page">
                            <xsl:apply-templates select="preceding-sibling::pb[not(@type) or @type='primary']/@*"/>
                            <xsl:apply-templates select="current-group()"/>
                        </div0>
                    </xsl:if>
                </xsl:for-each-group>
            </body>
        </xsl:template>
    
        <!--xsl:template match="p">
            <xsl:choose>
                <xsl:when test="not(ancestor::teiHeader)">
                    <milestone unit="para"/>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy copy-namespaces="no">
                        <xsl:apply-templates select="@*|node()"/>
                    </xsl:copy>
                </xsl:otherwise>
            </xsl:choose>
            </xsl:template-->
    
    <xsl:template match="@lang|@id">
        <xsl:choose>
            <xsl:when test=". = 'arabic'">
                <xsl:attribute name="{name(.)}">ara</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <!-- strip leading and trailing spaces from attribute values -->
                <xsl:attribute name="{name(.)}"><xsl:value-of select="normalize-space(.)"/></xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="@*">
        <!-- strip leading and trailing spaces from attribute values -->
        <xsl:attribute name="{name(.)}"><xsl:value-of select="normalize-space(.)"/></xsl:attribute>
    </xsl:template>
    
        <xsl:template match="node()">
            <xsl:copy copy-namespaces="no">
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:template>
        
    <xsl:template match="@TEIform|@xmlns" priority="3"/>
    
    <xsl:template match="@org" priority="3">
        <xsl:if test=". != 'uniform'"><xsl:apply-templates select="."/></xsl:if>
    </xsl:template>
    
    <xsl:template match="@default" priority="3">
        <xsl:if test=". != 'NO'"><xsl:apply-templates select="."/></xsl:if>
    </xsl:template>
    
    <xsl:template match="@sample" priority="3">
        <xsl:if test=". != 'complete'"><xsl:apply-templates select="."/></xsl:if>
    </xsl:template> 
    
    <xsl:template match="@part" priority="3">
        <xsl:if test=". != 'N'"><xsl:apply-templates select="."/></xsl:if>
    </xsl:template>        
        
        <!-- ============================================================= -->
        <!-- Function "bubble-up-breaks"
            where:
            $node is an element node, in whose nested content the
            elements named as $breaks are to be "bubbled up" as
            children (no longer descendants) of the node.
            
            The result is an element node with the same name and
            attributes as $node, with its children the children of
            the passed-in element node, except that any "break"
            element anywhere nested within the content is made an
            immediate child of the returned element.
            
            Two global variables parameterize this:
            
            $breaks is a list of element names, which are the "break"
            elements
            
            $excepts is a list of element names, in which any "break"
            elements are left as-is, typically because they have
            "break" element processing of their own.  -->
        <!-- ============================================================= -->
        <xsl:variable name="breaks" as="xs:string*" select="'pb'"/>
        <xsl:variable name="excepts" as="xs:string*"/>
    
    
        <xsl:function name="m:bubble-up-breaks" as="element()">
            <xsl:param name="node" as="element()"/>
            <xsl:element name="{name($node)}">
                <xsl:copy-of select="$node/@*"/>
                <xsl:for-each select="$node/node()">
                    <xsl:choose>
                        <xsl:when test="not(name() = $excepts) and
                            exists(descendant::*[name() = $breaks])">
                            <xsl:variable name="this" as="element()" select="."/>
                            <xsl:for-each-group
                                select="m:bubble-up-breaks(.)/node()"
                                group-adjacent="if (name() = $breaks and (not(@type) or @type='primary'))
                                then string(position())
                                else 'non-br'">
                                <xsl:choose>
                                    <xsl:when test="current-grouping-key() eq 'non-br'">
                                        <xsl:element name="{name($this)}">
                                            <xsl:copy-of select="$this/@*"/>
                                            <xsl:copy-of select="current-group()"/>
                                        </xsl:element>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="current-group()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each-group>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:element>
        </xsl:function>           
</xsl:stylesheet>

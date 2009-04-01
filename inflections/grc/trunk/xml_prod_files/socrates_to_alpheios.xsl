<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
    xmlns:xhtml="http://www.w3.org/1999/xhtml">
    <xsl:output encoding="UTF-8" method="xml"  media-type="text/html" indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="index"/>
    
  <xsl:variable name="paradigm-index">
      <paradigm id="verbpdgm1">
          <att name="tense" value="present"></att>
          <att name="voice" value="active"></att>
      </paradigm>
      <paradigm id="verbpdgm2">
          <att name="tense" value="present"></att>
          <att name="voice" value="mediopassive"></att>
      </paradigm>
      <paradigm id="verbpdgm3">
          <att name="tense" value="future"></att>
      </paradigm>
      <paradigm id="verbpdgm4">
          <att name="tense" value="future"></att>
      </paradigm>
      <paradigm id="verbpdgm5">
          <att name="tense" value="future"></att>
          <att name="voice" value="active"></att>
      </paradigm>
      <paradigm id="verbpdgm6">
          <att name="tense" value="aorist"></att>
          <att name="voice" value="active"></att>
      </paradigm>
      <paradigm id="verbpdgm7">
          <att name="tense" value="aorist"></att>
          <att name="voice" value="middle"></att>
      </paradigm>
      <paradigm id="verbpdgm8">
          <att name="tense" value="aorist"></att>
          <att name="voice" value="active"></att>
      </paradigm>
      <paradigm id="verbpdgm9">
          <att name="tense" value="aorist"></att>
          <att name="voice" value="middle"></att>
      </paradigm>
      <paradigm id="verbpdgm10">
          <att name="tense" value="aorist"></att>
          <att name="voice" value="passive"></att>
      </paradigm>
      <paradigm id="verbpdgm11">
          <att name="tense" value="perfect"></att>
          <att name="voice" value="active"></att>
      </paradigm>
      <paradigm id="verbpdgm12">
          <att name="tense" value="perfect"></att>
          <att name="voice" value="mediopassive"></att>
          <att name="mood" value="indicatve"></att>
      </paradigm>
      <paradigm id="verbpdgm13">
          <att name="tense" value="perfect"></att>
          <att name="voice" value="mediopassive"></att>
      </paradigm>
      <paradigm id="verbpdgm14">
          <att name="tense" value="perfect"></att>
          <att name="voice" value="mediopassive"></att>
      </paradigm>
      <paradigm id="verbpdgm15">
          <att name="tense" value="pluperfect"></att>
          <att name="voice" value="mediopassive"></att>
          <att name="mood" value="indicatve"></att>
      </paradigm>
      <paradigm id="verbpdgm16">
          <att name="tense" value="future perfect"></att>
          <att name="mood" value="indicatve"></att>
      </paradigm>
      <paradigm id="verbpdgm17">
          <att name="tense" value="perfect"></att>
      </paradigm>
      <paradigm id="verbpdgm18">
          <att name="tense" value="present"></att>
          <att name="voice" value="active"></att>
      </paradigm>
      <paradigm id="verbpdgm19">
          <att name="tense" value="present"></att>
          <att name="voice" value="active"></att>
      </paradigm>
      <paradigm id="verbpdgm20">
          <att name="tense" value="present"></att>
          <att name="voice" value="mediopassive"></att>
      </paradigm>
      <paradigm id="verbpdgm21">
          <att name="tense" value="present"></att>
          <att name="voice" value="mediopassive"></att>
      </paradigm>
  </xsl:variable>
  <xsl:variable name="attribute-lookup">
      <abbreviations>
          <item abbr="s">singular</item>
          <item abbr="pl">plural</item>
          <item abbr="d">dual</item>
          <item abbr="1">1st</item>
          <item abbr="2">2nd</item>
          <item abbr="3">3rd</item>
          <item abbr="perf">perfect</item>
          <item abbr="subj">subjunctive</item>
          <item abbr="ind">indicative</item>
          <item abbr="indic">indicative</item>
          <item abbr="opt">optative</item>
          <item abbr="inf">infinitive</item>
          <item abbr="part">participle</item>
          <item abbr="act">active</item>
      </abbreviations>
      <order-table>
          <order-item attname="case" order="1">nominative</order-item>
          <order-item attname="case" order="2">genitive</order-item>
          <order-item attname="case" order="3">dative</order-item>
          <order-item attname="case" order="4">accusative</order-item>
          <order-item attname="case" order="5">vocative</order-item>
          <order-item attname="gend" order="1">masculine</order-item>        
          <order-item attname="gend" order="2">feminine</order-item>
          <order-item attname="gend" order="3">neuter</order-item>
          <order-item attname="type" order="1">regular</order-item>
          <order-item attname="type" order="2">irregular</order-item>
          <order-item attname="num" order="1">singular</order-item>
          <order-item attname="num" order="2">dual</order-item>
          <order-item attname="num" order="3">plural</order-item>
          <order-item attname="pers" order="1">1st</order-item>
          <order-item attname="pers" order="2">2nd</order-item>
          <order-item attname="pers" order="3">3rd</order-item>
          <order-item attname="type" order="2">regular</order-item>
          <order-item attname="type" order="3">irregular</order-item>
          <order-item attname="num" order="1">singular</order-item>
          <order-item attname="num" order="2">dual</order-item>
          <order-item attname="num" order="3">plural</order-item>
          <order-item attname="tense" order="1">present</order-item>
          <order-item attname="tense" order="2">imperfect</order-item>
          <order-item attname="tense" order="3">future</order-item>
          <order-item attname="tense" order="4">aorist</order-item>
          <order-item attname="tense" order="5">perfect</order-item>
          <order-item attname="tense" order="6">pluperfect</order-item>
          <order-item attname="tense" order="7">future perfect</order-item>
          <order-item attname="mood" order="1">indicative</order-item>
          <order-item attname="mood" order="2">subjunctive</order-item>
          <order-item attname="mood" order="3">optative</order-item>
          <order-item attname="mood" order="4">imperative</order-item>
          <order-item attname="mood" order="5">infinitive</order-item>
          <order-item attname="mood" order="6">participle</order-item>
          <order-item attname="voice" order="1">active</order-item>
          <order-item attname="voice" order="2">middle</order-item>
          <order-item attname="voice" order="3">middle-passive</order-item>
          <order-item attname="voice" order="4">passive</order-item>
      </order-table>
  </xsl:variable>
    
    <xsl:template match="/">
        <infl-paradigms>
            <xsl:apply-templates select="//xhtml:table[preceding-sibling::*[1][self::xhtml:h2]]"/>
          </infl-paradigms>        
    </xsl:template>
    
    <!--- previous sibling a name = paradigm id -->
    <!-- next sibling tables are content tables -->
    <!-- if table has attribute frame="above", then it's a sub table -->
    <!-- cells: span greek or greekred are forms -->
    <!-- more than 1 span possible </div>per cell -->
    <!-- also look for a elements for links -->
    <!-- &nbsp; is an empty cell -->
    
    <xsl:template match="xhtml:table[preceding-sibling::*[1][self::xhtml:h2]]">    
        <xsl:variable name="header" select="preceding-sibling::xhtml:h2[1]"/>
        <xsl:variable name="id" select="$header/preceding-sibling::xhtml:a[1]/@name"/>
        <xsl:variable name="title">
            <xsl:call-template name="process_text">
                <xsl:with-param name="textitem" select="$header"/>            
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$index">
                <item><xsl:value-of select="$title"/>
                    <ptr target="{concat('#verb|type:paradigm|paradigm_id:',$id)}"/>
                </item>
            </xsl:when>
            <xsl:otherwise>
                <infl-paradigm id="{$id}">
                    <title><xsl:copy-of select="$title"/></title>
                    <xsl:call-template name="paradigm-child">
                        <xsl:with-param name="paradigm_id" select="$id"/>
                    </xsl:call-template>
                </infl-paradigm>        
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template name="process_text">
        <xsl:param name="textitem"/>
        <xsl:apply-templates select="$textitem"/>
    </xsl:template>
    
    <xsl:template match="xhtml:span">
        <xsl:if test="starts-with(@class,'greek')">
            <span xml:lang="grc"><xsl:copy-of select="text()"/></span>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="xhtml:a">
        <reflink xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{substring-after(@href,'#')}"><xsl:value-of select="text()"/></reflink>
    </xsl:template>
    
    <xsl:template name="paradigm-child">
        <xsl:param name="paradigm_id"/>
        <!-- check first row and columns for headers -->
        <!-- first row is headers if there are no greekred spans-->
        <xsl:element name="table">
            <!-- tables with frames above them are sub tables -->
            <xsl:if test="@frame='above'">
                <xsl:attribute name="role">sub</xsl:attribute>
            </xsl:if>
        
        <xsl:variable name="row1headers">
            <xsl:choose>
                <xsl:when test="count(xhtml:tr[1]/xhtml:td/xhtml:span/@class[. = 'greekred']) &gt; 0"></xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="xhtml:tr">
            <xsl:if test="count(xhtml:td) &gt; 1">
            <xsl:element name="row">
                <xsl:variable name="row_num" select="position()"/>
                <xsl:variable name="row-role">
                    <xsl:choose>
                        <xsl:when test="position()=1 and $row1headers='1'">label</xsl:when>
                        <xsl:otherwise>data</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:attribute name="role"><xsl:value-of select="$row-role"/></xsl:attribute>
                <!-- first and second columns are labels if there are no greek elements in them -->
                <xsl:variable name="col1label">
                    <xsl:choose>
                        <xsl:when test="xhtml:td[1]/xhtml:span[starts-with(@class,'greek')]=0">1</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="col2label">
                    <xsl:choose>
                        <xsl:when test="xhtml:td[2]/xhtml:span[starts-with(@class,'greek')]=0">1</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:for-each select="xhtml:td">
                    <xsl:variable name="col" select="position()"/>
                    <xsl:variable name="cell-role">
                        <xsl:choose>
                            <!-- row label trumps cell role -->
                            <xsl:when test="$row-role='label'">label</xsl:when>
                            <xsl:when test="position()=1 and $col1label">label</xsl:when>
                            <xsl:when test="position()=2 and $col2label">label</xsl:when>
                            <xsl:otherwise>data</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:element name="cell">
                        <xsl:attribute name="role"><xsl:value-of select="$cell-role"/></xsl:attribute>                      
                        <xsl:for-each select="$paradigm-index/paradigm[@id=$paradigm_id]/att">
                            <xsl:attribute name="{@name}"><xsl:value-of select="@value"/></xsl:attribute>
                        </xsl:for-each>
                        <xsl:if test="($col1label and $col2label and $col &gt; 2) or ($col1label and $col &gt; 1)">
                            <!-- get the last col 1 label text -->
                            <xsl:variable name="col1_label_text">
                                <xsl:call-template name="get-label-text">
                                    <xsl:with-param name="item" select="."/>
                                    <xsl:with-param name="row_num" select="$row_num"/>
                                    <xsl:with-param name="col_num" select="1"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:call-template name="find-attributes">
                                <xsl:with-param name="item" select="$col1_label_text"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$col2label and $col &gt; 2">
                            <xsl:variable name="col2_label_text">
                                <xsl:call-template name="get-label-text">
                                    <xsl:with-param name="item" select="."/>
                                    <xsl:with-param name="row_num" select="$row_num"/>
                                    <xsl:with-param name="col_num" select="2"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:call-template name="find-attributes">
                                <xsl:with-param name="item" select="$col2_label_text"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="$row1headers">
                            <xsl:call-template name="find-attributes">
                                <xsl:with-param name="item" select="../../xhtml:tr[1]/xhtml:td[$col]"></xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:call-template name="process_text">
                            <xsl:with-param name="textitem" select="."/>            
                        </xsl:call-template>
                    </xsl:element>            
                </xsl:for-each>
            </xsl:element>
            </xsl:if>
        </xsl:for-each>
        </xsl:element>
        <xsl:variable name="next" select="following-sibling::*[1]"/>
        <xsl:for-each select="$next[self::xhtml:table]">
            <xsl:call-template name="paradigm-child">
                <xsl:with-param name="paradigm_id" select="$paradigm_id"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
       
    <xsl:template name="get-label-text">
        <xsl:param name="item"/>
        <xsl:param name="row_num"/>
        <xsl:param name="col_num"/>
        <xsl:choose>
            <xsl:when test="$item/ancestor::xhtml:table/xhtml:tr[number($row_num)]/xhtml:td[number($col_num)]/text()">
                <xsl:value-of select="$item/ancestor::xhtml:table/xhtml:tr[number($row_num)]/xhtml:td[number($col_num)]/text()"/>
            </xsl:when>
            <xsl:when test="number($row_num) - 1 &gt; 1">
                <xsl:call-template name="get-label-text">
                    <xsl:with-param name="item" select="$item"/>
                    <xsl:with-param name="row_num" select="number($row_num)-1"/>
                    <xsl:with-param name="col_num" select="$col_num"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="find-attributes">
        <xsl:param name="item"/>
        <xsl:if test="$item">
            <xsl:variable name="stripped_value" select="translate($item,'.','')"/>
             <xsl:call-template name="attribute-tokens">
                 <xsl:with-param name="list" select="$stripped_value"/>
                 <xsl:with-param name="delimiter" select="' '"/>
             </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="attribute-tokens">
        <xsl:param name="list" />
        <xsl:param name="delimiter" />
        <xsl:variable name="newlist">
            <xsl:choose>
                <xsl:when test="contains($list, $delimiter)"><xsl:value-of select="normalize-space($list)" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="concat(normalize-space($list), $delimiter)"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="first" select="normalize-space(substring-before($newlist, $delimiter))" />
        <xsl:variable name="remaining" select="normalize-space(substring-after($newlist, $delimiter))" /> 
        <xsl:variable name="attvalue">
            <xsl:choose>
                <xsl:when test="contains($first,'.')"><xsl:value-of select="$attribute-lookup/abbreviations/item[@abbr = substring-before($first,'.')]/text()"/></xsl:when>
                <xsl:when test="$attribute-lookup/abbreviations/item[@abbr=$first]"><xsl:value-of select="$attribute-lookup/abbreviations/item[@abbr = $first]/text()"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$first"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="attname"><xsl:value-of select="$attribute-lookup/order-table/order-item[text() = $attvalue]/@attname"/></xsl:variable>
        <xsl:if test="$attname and $attvalue">
        <xsl:attribute name="{$attname}"><xsl:value-of select="$attvalue"/></xsl:attribute>
        </xsl:if>
        <!--xsl:comment>List: <xsl:value-of select="$list"/> First:<xsl:value-of select="$first"/> Remaining:<xsl:value-of select="$remaining"/> Attname: <xsl:value-of select="$attname"/> Attvalue: <xsl:value-of select="$attvalue"/></xsl:comment-->
        <xsl:if test="$remaining">
            <xsl:call-template name="attribute-tokens">
                <xsl:with-param name="list" select="$remaining" />
                <xsl:with-param name="delimiter"><xsl:value-of select="$delimiter"/></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="xhtml:style"/>
</xsl:stylesheet>

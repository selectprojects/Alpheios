<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:cts="http://chs.harvard.edu/xmlns/cts3"
    xmlns:dc="http://purl.org/dc/elements/1.1"
    xmlns:ti="http://chs.harvard.edu/xmlns/cts3/ti"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output
        encoding="UTF-8"
        indent="no"
        method="html"/>
    <xsl:template
        match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head><title>Alpheios Vocabulary Analysis</title>        
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js"></script>
                <script type="text/javascript" src="../script/alpheios-vocab-test.js"></script>
                <link rel="stylesheet" type="text/css" href="../css/alpheios-vocab-anal-form.css"/>
            </head>
            <body>
                <div><img src="http://alpheios.net/alpheios-texts/img/alpheios.png" alt="Alpheios Logo"/></div>
                <div>
                    <hr/>
                    <h1>Vocabulary Comparison</h1>
                    <form method="post" action="../xq/alpheios-vocab-anal.xq?">
                        <input type="hidden" name="format" value="xml"/>
                        <input type="hidden" name="excludepofs" value="1"/>
                        <input type="hidden" name="pofs" value="punctuation"/>  
                        <table>                
                            <tr><th class="rowhead">Vocabulary Source:</th><th>Author/Group</th><th>Work</th><th>Edition</th><th>Citation Range(s)<div class="hint">(comma-separated list or * for all)</div></th></tr>
                            <tr>
                                <td class="label"><label for="vocabUrnSelect">Select:</label></td>
                                <td>
                                    <select name="srcTgUrn1" class="selectTg srcTg">
                                        <xsl:for-each select="//ti:textgroup">
                                            <xsl:call-template name="option">
                                                <xsl:with-param name="a_opt" select="."/>
                                            </xsl:call-template>
                                        </xsl:for-each>
                                    </select>
                                </td>
                                <td>
                                    <select class="selectWk" name="srcWkUrn1" style="display:none;"></select>
                                </td>
                                <td>
                                    <select name="srcEdUrn1" class="selectEd" style="display:none;"></select>
                                    <div style="display:none;">
                                        <!-- for each textgroup, get options for works -->
                                        <xsl:for-each select="//ti:textgroup">
                                            <xsl:variable name="tg" select="translate(@projid,':','_')"/>
                                            <select id="{concat('wk_',$tg)}" disabled="disabled">
                                                <xsl:for-each select="ti:work[ti:edition[ti:online]]">
                                                    <xsl:call-template name="option">
                                                        <xsl:with-param name="a_opt" select="."/>
                                                    </xsl:call-template>
                                                 </xsl:for-each>
                                            </select>
                                            <!-- for each work, get options for editions -->
                                            <xsl:for-each select="ti:work[ti:edition[ti:online]]">
                                                <xsl:variable name="wk" select="translate(@projid,':','_')"/>
                                                <select id="{concat('ed_',$tg,'_',$wk)}" disabled="disabled">
                                                    <xsl:for-each select="ti:edition[ti:online]">
                                                         <xsl:call-template name="ed_option">
                                                               <xsl:with-param name="a_opt" select="."/>
                                                         </xsl:call-template>                                                        
                                                    </xsl:for-each>   
                                                </select>
                                            </xsl:for-each> <!-- end works -->  
                                        </xsl:for-each> <!-- end textgroups -->
                                    </div>
                                </td>
                                <td id="srcRangeCell1"></td>
                            </tr>
                            <tr>
                                <td class="label"><label for="doc">Or Enter Vocabulary <br/>(in TEI XML): (<a href="#" id="vocabfmtlink">?</a>)</label></td>                                                
                                <td colspan="4"><textarea id="vocabDoc" name="vocabDoc" maxlength="500" rows="5" cols="100"></textarea></td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <div class="vocabfmt hint">
                                        <p>Accepted vocabulary format is a valid xml document in the TEI 1.0 namespace (http://www.tei-c.org/ns/1.0) complying with the TEI dictionary schema 
                                            (<a href="http://www.tei-c.org/release/xml/tei/custom/schema/xsd/tei_dictionaries.xsd">http://www.tei-c.org/release/xml/tei/custom/schema/xsd/tei_dictionaries.xsd</a>)
                                            whose &lt;body&gt; element contains one or more &lt;entry&gt; elements for each vocabulary word. Each &lt;entry&gt; element should contain one &lt;form&gt; element for the lemma, as 
                                            identified by setting the @type attribute to 'lemma' and one &lt;form&gt; element for the form, identified by setting the @type attribute to 'inflection'.</p>
                                        <p>E.g.<br/>                                
                                            &lt;TEI xmnls="http://www.tei-c.org/ns/1.0"&gt;<br/>
                                            ...<br/>
                                            &lt;text&gt;<br/>
                                            &lt;body&gt;<br/>
                                            &lt;entry xml:lang="ara"&gt;<br/>
                                            &lt;form type="lemma" xml:lang="ara"&gt;عَبَّد&lt;/form&gt;<br/>
                                            &lt;form type="inflection" xml:lang="ara"&gt;نَعْبُدُ&lt;/form&gt;<br/>                                                    
                                            &lt;/entry&gt;<br/>
                                            &lt;/body&gt;<br/>
                                            &lt;/text&gt;<br/>
                                            &lt;/TEI&gt;<br/>                                                                
                                        </p>
                                        <p>The XML downloads of the Alpheios Tools User Vocabulary Lists are compliant can be used by copying their contents and pasting them here.</p>                            
                                    </div>
                                </td>                    
                            </tr>
                            <tr><td colspan="5"><hr/></td></tr>
                            <tr><th class="rowhead">Target Text:</th><th>Author/Group</th><th>Work</th><th>Edition</th><th>Citation Range(s)<div class="hint">(comma-separated list or * for all)</div></th></tr>
                            <tr>
                                <td class="label"><label for="docUrnSelect">Select:</label></td>
                                <td>
                                    <select name="targetTgUrn1" class="selectTg targetTg">
                                        <!-- hack to exclude alpheios vocabulary documents from the available target texts -->
                                        <xsl:for-each select="//ti:textgroup[ti:work/ti:edition[ti:online[not(contains(@docname,'alpheios-vocab'))]]]">
                                            <xsl:call-template name="option">
                                                <xsl:with-param name="a_opt" select="."/>
                                            </xsl:call-template>
                                        </xsl:for-each>
                                    </select>
                                </td>
                                <td>
                                    <select name="targetWkUrn1" style="display:none;" class="selectWk"></select>
                                </td>
                                <td>
                                    <select name="targetEdUrn1" style="display:none;" class="selectEd"></select>
                                </td>
                                <td id="targetRangeCell1"></td>
                                </tr>
                                    <tr>
                                        <td class="label"><label for="doc">Or Enter Text: (<a href="#" id="textfmtlink">?</a>)</label><br/> 
                                            <select name="lang">
                                                <option value="ara">Arabic</option>
                                                <option value="grc">Greek</option>
                                                <option value="lat">Latin</option>
                                            </select></td>                                                
                                         <td colspan="4"><textarea id="doc" name="doc" maxlength="500" rows="5" cols="100"></textarea><p class="textfmt hint">Enter text in either Unicode or Buckwalter Transliteration</p></td>
                                    </tr>                
                                    <tr class="hidden">
                                        <td class="label"><label>Remove/Replace  Before Comparison:</label></td>
                                        <td colspan="4"><label><input type="checkbox" name="toDrop" value="tanwin"></input>tanwin</label>
                                            <label><input type="checkbox" name="toDrop" value="hamza"></input>hamza</label>
                                            <label><input type="checkbox" name="toDrop" value="harakat"></input>harakat</label>
                                            <label><input type="checkbox" name="toDrop" value="shadda"></input>shadda</label>
                                            <label><input type="checkbox" name="toDrop" value="sukun"></input>sukun</label>
                                            <label><input type="checkbox" name="toDrop" value="alef"></input>alef</label>
                                            <a id="showkeylink" href="#">(show/hide  key)</a>
                                        </td></tr>
                                    <tr><td colspan="4">
                                        <div class="dropkey">
                                            <table>
                                                <tr><td>tanwin</td><td>Drop nunation/tanwin &amp; tatweel (\u064B <span lang="ara" class="drop">&#x064B;</span> \u064C <span lang="ara" class="drop">&#x064C;</span> 
                                                    \u064D <span lang="ara" class="drop">&#x064D;</span> \u0640 <span lang="ara" class="drop">&#x0640;</span>)</td></tr>
                                                <tr><td>hamza</td><td>Replace alef with madda above, alef with hamza above/below with alef (\u0622 <span lang="ara" class="drop">&#x0622;</span> 
                                                    \u0623 <span lang="ara" class="drop">&#x0623;</span>  \u0625 <span lang="ara" class="drop">&#x0625;</span> 
                                                    \u0627 with \u0627<span lang="ara" class="drop">&#x0627;</span>)</td></tr>
                                                <tr><td>harakat</td><td>Drop harakat - fatha, damma, kasra, superscript alef, alef wasla
                                                    (\u064E <span lang="ara" class="drop">&#x064E;</span> \u064F <span lang="ara" class="drop">&#x064F;</span> 
                                                    \u0650 <span lang="ara" class="drop">&#x0650;</span> \u0670 <span lang="ara" class="drop">&#x0670;</span> \u0671 <span lang="ara" class="drop">&#x0671;</span>)</td></tr>
                                                <tr><td>shadda</td><td>Drop shadda (\u0651 <span lang="ara" class="drop">&#x0651;</span>)</td></tr>
                                                <tr><td>sukun</td><td>Drop sukun (\u0652 <span lang="ara" class="drop">&#x0652;</span>)</td></tr>
                                                <tr><td>alef</td><td>Drop alef (\u0627 <span lang="ara" class="drop">&#x0627;</span>)</td></tr>                        
                                            </table>                
                                        </div>                        
                                    </td>
                                    </tr>
                                    <tr>                         
                                        <td> </td>
                                        <td colspan="4" class="show"><label class="checkbox"><input type="checkbox" name="missed"></input>Reverse Analysis (Words in Target Text Not Found in Vocabulary Source)</label></td>
                                    </tr>
                                    <tr><th colspan="5">Show:</th></tr>
                                    <tr>                                        
                                        <td colspan="5" class="show"><label class="checkbox"><input type="checkbox" name="details" checked="checked"></input>Words from source vocabulary present in target text</label></td>
                                    </tr>                
                                    <tr>                    
                                        <td colspan="5" class="show"><label class="checkbox"><input type="checkbox" class="xmlFormat"></input>XML Output</label></td>                    
                                    </tr>
                                    <tr><td colspan="5" class="submit"><input type="submit" value="submit"/></td></tr>
                        </table>
                    </form>            
                </div>
                <hr/>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="option">
        <xsl:param name="a_opt"/>
        <option value="{translate($a_opt/@projid,':','_')}" xmlns="http://www.w3.org/1999/xhtml">
                <xsl:choose>
                    <xsl:when test="$a_opt/ti:groupname">
                        <xsl:value-of
                            select="$a_opt/ti:groupname[1]"/>
                    </xsl:when>
                    <xsl:when test="$a_opt/ti:title">
                        <xsl:value-of
                            select="$a_opt/ti:title[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$a_opt/@projid"/>
                    </xsl:otherwise>
                </xsl:choose>
        </option>
    </xsl:template>
    
    <xsl:template name="ed_option">
        <xsl:param name="a_opt"/>
        <xsl:variable name="citelevel" select="count(ti:online/ti:citationMapping//ti:citation)"/>
        <option value="{concat($citelevel,'|',
            translate($a_opt/@projid,':','_'))}" xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:value-of
                        select="$a_opt/ti:label"/>
                    <xsl:apply-templates select="ti:online/ti:citationMapping"/>
        </option>
    </xsl:template>
    
    <xsl:template match="ti:citationMapping">
        ( <xsl:for-each select=".//ti:citation">
                <xsl:if test="position() > 1"><xsl:text>,</xsl:text></xsl:if>
                <xsl:value-of select="@label"/>
            </xsl:for-each> )
    </xsl:template>
    
    <!-- Default: ignore unrecognized nodes and attributes -->
    <xsl:template
        match="@*|node()"
        priority="-1">
        <xsl:copy>
            <xsl:apply-templates
                select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>

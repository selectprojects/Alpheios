<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <!--
    Copyright 2009 Cantus Foundation
    http://alpheios.net

    This file is part of Alpheios.

    Alpheios is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Alpheios is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
  -->

  <!-- Arabic utility routines -->

  <!--
   Arabic letters in Buckwalter transliteration and in Unicode
   Buckwalter's suggested XML-compatible alternatives for
     U+0623 (ALEF WITH HAMZA ABOVE) = O
     U+0624 (WAW WITH HAMZA ABOVE)  = W
     U+0625 (ALEF WITH HAMZA BELOW) = I
   are used for transliteration.
   Both alternatives are recognized for Unicode production.
  -->
  <xsl:variable name="s_ara-buckwalter"
    >'|O&gt;W&amp;I&lt;}AbptvjHxd*rzs$SDTZEg_fqklmnhwYyFNKaui~o`{PJVG</xsl:variable>
  <xsl:variable name="s_ara-unicode"
    >&#x0621;&#x0622;&#x0623;&#x0623;&#x0624;&#x0624;&#x0625;&#x0625;&#x0626;&#x0627;&#x0628;&#x0629;&#x062A;&#x062B;&#x062C;&#x062D;&#x062E;&#x062F;&#x0630;&#x0631;&#x0632;&#x0633;&#x0634;&#x0635;&#x0636;&#x0637;&#x0638;&#x0639;&#x063A;&#x0640;&#x0641;&#x0642;&#x0643;&#x0644;&#x0645;&#x0646;&#x0647;&#x0648;&#x0649;&#x064A;&#x064B;&#x064C;&#x064D;&#x064E;&#x064F;&#x0650;&#x0651;&#x0652;&#x0670;&#x0671;&#x067E;&#x0686;&#x06A4;&#x06AF;</xsl:variable>

  <!--
    Translate Buckwalter transliteration to Unicode
    Parameters:
      $a_in         string to translate

    Output:
      translated string
  -->
  <xsl:template name="ara-buckwalter-to-uni">
    <xsl:param name="a_in"/>
    <xsl:value-of
      select="translate($a_in, $s_ara-buckwalter, $s_ara-unicode)"/>
  </xsl:template>

  <!--
    Translate Unicode to Buckwalter transliteration
    Parameters:
      $a_in         string to translate

    Output:
      translated string
  -->
  <xsl:template name="ara-uni-to-buckwalter">
    <xsl:param name="a_in"/>
    <xsl:value-of
      select="translate($a_in, $s_ara-unicode, $s_ara-buckwalter)"/>
  </xsl:template>

</xsl:stylesheet>

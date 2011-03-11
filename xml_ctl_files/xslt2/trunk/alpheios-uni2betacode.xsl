<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

<!--
  Copyright 2008-2009 Cantus Foundation
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

  <xsl:output method="text"/>
  <xsl:include href="uni2betacode.xsl"/>

  <xsl:param name="e_in"/>
  <xsl:param name="e_upper" select="false()"/>

  <xsl:template match="/">
    <xsl:call-template name="uni-to-beta">
      <xsl:with-param name="a_in" select="$e_in"/>
      <xsl:with-param name="a_upper" select="$e_upper"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>

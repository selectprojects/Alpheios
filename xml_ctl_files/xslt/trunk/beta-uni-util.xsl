<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common">

  <!-- Upper/lower tables.  Note: J is not a valid betacode base character. -->
  <xsl:variable name="beta-uppers">ABCDEFGHIKLMNOPQRSTUVWXYZ</xsl:variable>
  <xsl:variable name="beta-lowers">abcdefghiklmnopqrstuvwxyz</xsl:variable>

  <!-- diacritics in betacode and combining unicode -->
  <xsl:variable name="beta-diacritics">()+/\=|_^</xsl:variable>
  <xsl:variable name="uni-diacritics"
    >&#x0314;&#x0313;&#x0308;&#x0301;&#x0300;&#x0342;&#x0345;&#x0304;&#x0306;</xsl:variable>

  <!-- keys for lookup table -->
  <xsl:key name="beta-uni-lookup" match="beta-uni-table/entry" use="beta"/>
  <xsl:key name="unic-beta-lookup" match="beta-uni-table/entry" use="unic"/>

  <!--
    Table mapping betacode sequences to Unicode
    Betacode sequences have the form
      <letter><diacritics>
    where
      - <letter> is one of the base Greek characters as
        represented in betacode
      - <diacritics> is a string in canonical order:
        * = capitalize
        ( = dasia/rough breathing
        ) = psili/smooth breathing
        + = diaeresis
        / = acute accent
        \ = grave accent
        = = perispomeni
        | = ypogegrammeni
        _ = macron [non-standard, Perseus]
        ^ = breve [non-standard, Perseus]

    Each entry in the table contains a betacode sequence
    plus the corresponding precomposed Unicode sequence (<unic> element)
    and decomposed Unicode sequence (<unid> element>.
    But for entries for which the <beta> content contains only diacritics,
    <unic> holds the non-combining form, while <unid> holds the combining form.

    To get around tree fragment restrictions in XSLT 1.0, the actual variable
    uses exsl:node-set().
  -->
  <xsl:variable name="raw-table">
    <beta-uni-table>
      <entry>
        <beta>a*(/|</beta>
        <unic>ᾍ</unic>
        <unid>ᾍ</unid>
      </entry>
      <entry>
        <beta>a*(/</beta>
        <unic>Ἅ</unic>
        <unid>Ἅ</unid>
      </entry>
      <entry>
        <beta>a*(\|</beta>
        <unic>ᾋ</unic>
        <unid>ᾋ</unid>
      </entry>
      <entry>
        <beta>a*(\</beta>
        <unic>Ἃ</unic>
        <unid>Ἃ</unid>
      </entry>
      <entry>
        <beta>a*(=|</beta>
        <unic>ᾏ</unic>
        <unid>ᾏ</unid>
      </entry>
      <entry>
        <beta>a*(=</beta>
        <unic>Ἇ</unic>
        <unid>Ἇ</unid>
      </entry>
      <entry>
        <beta>a*(|</beta>
        <unic>ᾉ</unic>
        <unid>ᾉ</unid>
      </entry>
      <entry>
        <beta>a*(</beta>
        <unic>Ἁ</unic>
        <unid>Ἁ</unid>
      </entry>
      <entry>
        <beta>a*)/|</beta>
        <unic>ᾌ</unic>
        <unid>ᾌ</unid>
      </entry>
      <entry>
        <beta>a*)/</beta>
        <unic>Ἄ</unic>
        <unid>Ἄ</unid>
      </entry>
      <entry>
        <beta>a*)\|</beta>
        <unic>ᾊ</unic>
        <unid>ᾊ</unid>
      </entry>
      <entry>
        <beta>a*)\</beta>
        <unic>Ἂ</unic>
        <unid>Ἂ</unid>
      </entry>
      <entry>
        <beta>a*)=|</beta>
        <unic>ᾎ</unic>
        <unid>ᾎ</unid>
      </entry>
      <entry>
        <beta>a*)=</beta>
        <unic>Ἆ</unic>
        <unid>Ἆ</unid>
      </entry>
      <entry>
        <beta>a*)|</beta>
        <unic>ᾈ</unic>
        <unid>ᾈ</unid>
      </entry>
      <entry>
        <beta>a*)</beta>
        <unic>Ἀ</unic>
        <unid>Ἀ</unid>
      </entry>
      <entry>
        <beta>a*/</beta>
        <unic>Ά</unic>
        <unid>Ά</unid>
      </entry>
      <entry>
        <beta>a*\</beta>
        <unic>Ὰ</unic>
        <unid>Ὰ</unid>
      </entry>
      <entry>
        <beta>a*|</beta>
        <unic>ᾼ</unic>
        <unid>ᾼ</unid>
      </entry>
      <entry>
        <beta>a*_</beta>
        <unic>Ᾱ</unic>
        <unid>Ᾱ</unid>
      </entry>
      <entry>
        <beta>a*^</beta>
        <unic>Ᾰ</unic>
        <unid>Ᾰ</unid>
      </entry>
      <entry>
        <beta>a*</beta>
        <unic>Α</unic>
        <unid>Α</unid>
      </entry>
      <entry>
        <beta>a(/|</beta>
        <unic>ᾅ</unic>
        <unid>ᾅ</unid>
      </entry>
      <entry>
        <beta>a(/</beta>
        <unic>ἅ</unic>
        <unid>ἅ</unid>
      </entry>
      <entry>
        <beta>a(\|</beta>
        <unic>ᾃ</unic>
        <unid>ᾃ</unid>
      </entry>
      <entry>
        <beta>a(\</beta>
        <unic>ἃ</unic>
        <unid>ἃ</unid>
      </entry>
      <entry>
        <beta>a(=|</beta>
        <unic>ᾇ</unic>
        <unid>ᾇ</unid>
      </entry>
      <entry>
        <beta>a(=</beta>
        <unic>ἇ</unic>
        <unid>ἇ</unid>
      </entry>
      <entry>
        <beta>a(|</beta>
        <unic>ᾁ</unic>
        <unid>ᾁ</unid>
      </entry>
      <entry>
        <beta>a(</beta>
        <unic>ἁ</unic>
        <unid>ἁ</unid>
      </entry>
      <entry>
        <beta>a)/|</beta>
        <unic>ᾄ</unic>
        <unid>ᾄ</unid>
      </entry>
      <entry>
        <beta>a)/</beta>
        <unic>ἄ</unic>
        <unid>ἄ</unid>
      </entry>
      <entry>
        <beta>a)\|</beta>
        <unic>ᾂ</unic>
        <unid>ᾂ</unid>
      </entry>
      <entry>
        <beta>a)\</beta>
        <unic>ἂ</unic>
        <unid>ἂ</unid>
      </entry>
      <entry>
        <beta>a)=|</beta>
        <unic>ᾆ</unic>
        <unid>ᾆ</unid>
      </entry>
      <entry>
        <beta>a)=</beta>
        <unic>ἆ</unic>
        <unid>ἆ</unid>
      </entry>
      <entry>
        <beta>a)|</beta>
        <unic>ᾀ</unic>
        <unid>ᾀ</unid>
      </entry>
      <entry>
        <beta>a)</beta>
        <unic>ἀ</unic>
        <unid>ἀ</unid>
      </entry>
      <entry>
        <beta>a/|</beta>
        <unic>ᾴ</unic>
        <unid>ᾴ</unid>
      </entry>
      <entry>
        <beta>a/</beta>
        <unic>ά</unic>
        <unid>ά</unid>
      </entry>
      <entry>
        <beta>a\|</beta>
        <unic>ᾲ</unic>
        <unid>ᾲ</unid>
      </entry>
      <entry>
        <beta>a\</beta>
        <unic>ὰ</unic>
        <unid>ὰ</unid>
      </entry>
      <entry>
        <beta>a=|</beta>
        <unic>ᾷ</unic>
        <unid>ᾷ</unid>
      </entry>
      <entry>
        <beta>a=</beta>
        <unic>ᾶ</unic>
        <unid>ᾶ</unid>
      </entry>
      <entry>
        <beta>a|</beta>
        <unic>ᾳ</unic>
        <unid>ᾳ</unid>
      </entry>
      <entry>
        <beta>a_</beta>
        <unic>ᾱ</unic>
        <unid>ᾱ</unid>
      </entry>
      <entry>
        <beta>a^</beta>
        <unic>ᾰ</unic>
        <unid>ᾰ</unid>
      </entry>
      <entry>
        <beta>a</beta>
        <unic>α</unic>
        <unid>α</unid>
      </entry>
      <entry>
        <beta>b*</beta>
        <unic>Β</unic>
        <unid>Β</unid>
      </entry>
      <entry>
        <beta>b</beta>
        <unic>β</unic>
        <unid>β</unid>
      </entry>
      <entry>
        <beta>c*</beta>
        <unic>Ξ</unic>
        <unid>Ξ</unid>
      </entry>
      <entry>
        <beta>c</beta>
        <unic>ξ</unic>
        <unid>ξ</unid>
      </entry>
      <entry>
        <beta>d*</beta>
        <unic>Δ</unic>
        <unid>Δ</unid>
      </entry>
      <entry>
        <beta>d</beta>
        <unic>δ</unic>
        <unid>δ</unid>
      </entry>
      <entry>
        <beta>e*(/</beta>
        <unic>Ἕ</unic>
        <unid>Ἕ</unid>
      </entry>
      <entry>
        <beta>e*(\</beta>
        <unic>Ἓ</unic>
        <unid>Ἓ</unid>
      </entry>
      <entry>
        <beta>e*(</beta>
        <unic>Ἑ</unic>
        <unid>Ἑ</unid>
      </entry>
      <entry>
        <beta>e*)/</beta>
        <unic>Ἔ</unic>
        <unid>Ἔ</unid>
      </entry>
      <entry>
        <beta>e*)\</beta>
        <unic>Ἒ</unic>
        <unid>Ἒ</unid>
      </entry>
      <entry>
        <beta>e*)</beta>
        <unic>Ἐ</unic>
        <unid>Ἐ</unid>
      </entry>
      <entry>
        <beta>e*/</beta>
        <unic>Έ</unic>
        <unid>Έ</unid>
      </entry>
      <entry>
        <beta>e*\</beta>
        <unic>Ὲ</unic>
        <unid>Ὲ</unid>
      </entry>
      <entry>
        <beta>e*</beta>
        <unic>Ε</unic>
        <unid>Ε</unid>
      </entry>
      <entry>
        <beta>e(/</beta>
        <unic>ἕ</unic>
        <unid>ἕ</unid>
      </entry>
      <entry>
        <beta>e(\</beta>
        <unic>ἓ</unic>
        <unid>ἓ</unid>
      </entry>
      <entry>
        <beta>e(</beta>
        <unic>ἑ</unic>
        <unid>ἑ</unid>
      </entry>
      <entry>
        <beta>e)/</beta>
        <unic>ἔ</unic>
        <unid>ἔ</unid>
      </entry>
      <entry>
        <beta>e)\</beta>
        <unic>ἒ</unic>
        <unid>ἒ</unid>
      </entry>
      <entry>
        <beta>e)</beta>
        <unic>ἐ</unic>
        <unid>ἐ</unid>
      </entry>
      <entry>
        <beta>e/</beta>
        <unic>έ</unic>
        <unid>έ</unid>
      </entry>
      <entry>
        <beta>e\</beta>
        <unic>ὲ</unic>
        <unid>ὲ</unid>
      </entry>
      <entry>
        <beta>e</beta>
        <unic>ε</unic>
        <unid>ε</unid>
      </entry>
      <entry>
        <beta>f*</beta>
        <unic>Φ</unic>
        <unid>Φ</unid>
      </entry>
      <entry>
        <beta>f</beta>
        <unic>φ</unic>
        <unid>φ</unid>
      </entry>
      <entry>
        <beta>g*</beta>
        <unic>Γ</unic>
        <unid>Γ</unid>
      </entry>
      <entry>
        <beta>g</beta>
        <unic>γ</unic>
        <unid>γ</unid>
      </entry>
      <entry>
        <beta>h*(/|</beta>
        <unic>ᾝ</unic>
        <unid>ᾝ</unid>
      </entry>
      <entry>
        <beta>h*(/</beta>
        <unic>Ἥ</unic>
        <unid>Ἥ</unid>
      </entry>
      <entry>
        <beta>h*(\|</beta>
        <unic>ᾛ</unic>
        <unid>ᾛ</unid>
      </entry>
      <entry>
        <beta>h*(\</beta>
        <unic>Ἣ</unic>
        <unid>Ἣ</unid>
      </entry>
      <entry>
        <beta>h*(=|</beta>
        <unic>ᾟ</unic>
        <unid>ᾟ</unid>
      </entry>
      <entry>
        <beta>h*(=</beta>
        <unic>Ἧ</unic>
        <unid>Ἧ</unid>
      </entry>
      <entry>
        <beta>h*(|</beta>
        <unic>ᾙ</unic>
        <unid>ᾙ</unid>
      </entry>
      <entry>
        <beta>h*(</beta>
        <unic>Ἡ</unic>
        <unid>Ἡ</unid>
      </entry>
      <entry>
        <beta>h*)/|</beta>
        <unic>ᾜ</unic>
        <unid>ᾜ</unid>
      </entry>
      <entry>
        <beta>h*)/</beta>
        <unic>Ἤ</unic>
        <unid>Ἤ</unid>
      </entry>
      <entry>
        <beta>h*)\|</beta>
        <unic>ᾚ</unic>
        <unid>ᾚ</unid>
      </entry>
      <entry>
        <beta>h*)\</beta>
        <unic>Ἢ</unic>
        <unid>Ἢ</unid>
      </entry>
      <entry>
        <beta>h*)=|</beta>
        <unic>ᾞ</unic>
        <unid>ᾞ</unid>
      </entry>
      <entry>
        <beta>h*)=</beta>
        <unic>Ἦ</unic>
        <unid>Ἦ</unid>
      </entry>
      <entry>
        <beta>h*)|</beta>
        <unic>ᾘ</unic>
        <unid>ᾘ</unid>
      </entry>
      <entry>
        <beta>h*)</beta>
        <unic>Ἠ</unic>
        <unid>Ἠ</unid>
      </entry>
      <entry>
        <beta>h*/</beta>
        <unic>Ή</unic>
        <unid>Ή</unid>
      </entry>
      <entry>
        <beta>h*\</beta>
        <unic>Ὴ</unic>
        <unid>Ὴ</unid>
      </entry>
      <entry>
        <beta>h*|</beta>
        <unic>ῌ</unic>
        <unid>ῌ</unid>
      </entry>
      <entry>
        <beta>h*</beta>
        <unic>Η</unic>
        <unid>Η</unid>
      </entry>
      <entry>
        <beta>h(/|</beta>
        <unic>ᾕ</unic>
        <unid>ᾕ</unid>
      </entry>
      <entry>
        <beta>h(/</beta>
        <unic>ἥ</unic>
        <unid>ἥ</unid>
      </entry>
      <entry>
        <beta>h(\|</beta>
        <unic>ᾓ</unic>
        <unid>ᾓ</unid>
      </entry>
      <entry>
        <beta>h(\</beta>
        <unic>ἣ</unic>
        <unid>ἣ</unid>
      </entry>
      <entry>
        <beta>h(=|</beta>
        <unic>ᾗ</unic>
        <unid>ᾗ</unid>
      </entry>
      <entry>
        <beta>h(=</beta>
        <unic>ἧ</unic>
        <unid>ἧ</unid>
      </entry>
      <entry>
        <beta>h(|</beta>
        <unic>ᾑ</unic>
        <unid>ᾑ</unid>
      </entry>
      <entry>
        <beta>h(</beta>
        <unic>ἡ</unic>
        <unid>ἡ</unid>
      </entry>
      <entry>
        <beta>h)/|</beta>
        <unic>ᾔ</unic>
        <unid>ᾔ</unid>
      </entry>
      <entry>
        <beta>h)/</beta>
        <unic>ἤ</unic>
        <unid>ἤ</unid>
      </entry>
      <entry>
        <beta>h)\|</beta>
        <unic>ᾒ</unic>
        <unid>ᾒ</unid>
      </entry>
      <entry>
        <beta>h)\</beta>
        <unic>ἢ</unic>
        <unid>ἢ</unid>
      </entry>
      <entry>
        <beta>h)=|</beta>
        <unic>ᾖ</unic>
        <unid>ᾖ</unid>
      </entry>
      <entry>
        <beta>h)=</beta>
        <unic>ἦ</unic>
        <unid>ἦ</unid>
      </entry>
      <entry>
        <beta>h)|</beta>
        <unic>ᾐ</unic>
        <unid>ᾐ</unid>
      </entry>
      <entry>
        <beta>h)</beta>
        <unic>ἠ</unic>
        <unid>ἠ</unid>
      </entry>
      <entry>
        <beta>h/|</beta>
        <unic>ῄ</unic>
        <unid>ῄ</unid>
      </entry>
      <entry>
        <beta>h/</beta>
        <unic>ή</unic>
        <unid>ή</unid>
      </entry>
      <entry>
        <beta>h\|</beta>
        <unic>ῂ</unic>
        <unid>ῂ</unid>
      </entry>
      <entry>
        <beta>h\</beta>
        <unic>ὴ</unic>
        <unid>ὴ</unid>
      </entry>
      <entry>
        <beta>h=|</beta>
        <unic>ῇ</unic>
        <unid>ῇ</unid>
      </entry>
      <entry>
        <beta>h=</beta>
        <unic>ῆ</unic>
        <unid>ῆ</unid>
      </entry>
      <entry>
        <beta>h|</beta>
        <unic>ῃ</unic>
        <unid>ῃ</unid>
      </entry>
      <entry>
        <beta>h</beta>
        <unic>η</unic>
        <unid>η</unid>
      </entry>
      <entry>
        <beta>i*(/</beta>
        <unic>Ἵ</unic>
        <unid>Ἵ</unid>
      </entry>
      <entry>
        <beta>i*(\</beta>
        <unic>Ἳ</unic>
        <unid>Ἳ</unid>
      </entry>
      <entry>
        <beta>i*(=</beta>
        <unic>Ἷ</unic>
        <unid>Ἷ</unid>
      </entry>
      <entry>
        <beta>i*(</beta>
        <unic>Ἱ</unic>
        <unid>Ἱ</unid>
      </entry>
      <entry>
        <beta>i*)/</beta>
        <unic>Ἴ</unic>
        <unid>Ἴ</unid>
      </entry>
      <entry>
        <beta>i*)\</beta>
        <unic>Ἲ</unic>
        <unid>Ἲ</unid>
      </entry>
      <entry>
        <beta>i*)=</beta>
        <unic>Ἶ</unic>
        <unid>Ἶ</unid>
      </entry>
      <entry>
        <beta>i*)</beta>
        <unic>Ἰ</unic>
        <unid>Ἰ</unid>
      </entry>
      <entry>
        <beta>i*+</beta>
        <unic>Ϊ</unic>
        <unid>Ϊ</unid>
      </entry>
      <entry>
        <beta>i*/</beta>
        <unic>Ί</unic>
        <unid>Ί</unid>
      </entry>
      <entry>
        <beta>i*\</beta>
        <unic>Ὶ</unic>
        <unid>Ὶ</unid>
      </entry>
      <entry>
        <beta>i*_</beta>
        <unic>Ῑ</unic>
        <unid>Ῑ</unid>
      </entry>
      <entry>
        <beta>i*^</beta>
        <unic>Ῐ</unic>
        <unid>Ῐ</unid>
      </entry>
      <entry>
        <beta>i*</beta>
        <unic>Ι</unic>
        <unid>Ι</unid>
      </entry>
      <entry>
        <beta>i(/</beta>
        <unic>ἵ</unic>
        <unid>ἵ</unid>
      </entry>
      <entry>
        <beta>i(\</beta>
        <unic>ἳ</unic>
        <unid>ἳ</unid>
      </entry>
      <entry>
        <beta>i(=</beta>
        <unic>ἷ</unic>
        <unid>ἷ</unid>
      </entry>
      <entry>
        <beta>i(</beta>
        <unic>ἱ</unic>
        <unid>ἱ</unid>
      </entry>
      <entry>
        <beta>i)/</beta>
        <unic>ἴ</unic>
        <unid>ἴ</unid>
      </entry>
      <entry>
        <beta>i)\</beta>
        <unic>ἲ</unic>
        <unid>ἲ</unid>
      </entry>
      <entry>
        <beta>i)=</beta>
        <unic>ἶ</unic>
        <unid>ἶ</unid>
      </entry>
      <entry>
        <beta>i)</beta>
        <unic>ἰ</unic>
        <unid>ἰ</unid>
      </entry>
      <entry>
        <beta>i+/</beta>
        <unic>ΐ</unic>
        <unid>ΐ</unid>
      </entry>
      <entry>
        <beta>i+\</beta>
        <unic>ῒ</unic>
        <unid>ῒ</unid>
      </entry>
      <entry>
        <beta>i+=</beta>
        <unic>ῗ</unic>
        <unid>ῗ</unid>
      </entry>
      <entry>
        <beta>i+</beta>
        <unic>ϊ</unic>
        <unid>ϊ</unid>
      </entry>
      <entry>
        <beta>i/</beta>
        <unic>ί</unic>
        <unid>ί</unid>
      </entry>
      <entry>
        <beta>i\</beta>
        <unic>ὶ</unic>
        <unid>ὶ</unid>
      </entry>
      <entry>
        <beta>i=</beta>
        <unic>ῖ</unic>
        <unid>ῖ</unid>
      </entry>
      <entry>
        <beta>i_</beta>
        <unic>ῑ</unic>
        <unid>ῑ</unid>
      </entry>
      <entry>
        <beta>i^</beta>
        <unic>ῐ</unic>
        <unid>ῐ</unid>
      </entry>
      <entry>
        <beta>i</beta>
        <unic>ι</unic>
        <unid>ι</unid>
      </entry>
      <entry>
        <beta>k*</beta>
        <unic>Κ</unic>
        <unid>Κ</unid>
      </entry>
      <entry>
        <beta>k</beta>
        <unic>κ</unic>
        <unid>κ</unid>
      </entry>
      <entry>
        <beta>l*</beta>
        <unic>Λ</unic>
        <unid>Λ</unid>
      </entry>
      <entry>
        <beta>l</beta>
        <unic>λ</unic>
        <unid>λ</unid>
      </entry>
      <entry>
        <beta>m*</beta>
        <unic>Μ</unic>
        <unid>Μ</unid>
      </entry>
      <entry>
        <beta>m</beta>
        <unic>μ</unic>
        <unid>μ</unid>
      </entry>
      <entry>
        <beta>n*</beta>
        <unic>Ν</unic>
        <unid>Ν</unid>
      </entry>
      <entry>
        <beta>n</beta>
        <unic>ν</unic>
        <unid>ν</unid>
      </entry>
      <entry>
        <beta>o*(/</beta>
        <unic>Ὅ</unic>
        <unid>Ὅ</unid>
      </entry>
      <entry>
        <beta>o*(\</beta>
        <unic>Ὃ</unic>
        <unid>Ὃ</unid>
      </entry>
      <entry>
        <beta>o*(</beta>
        <unic>Ὁ</unic>
        <unid>Ὁ</unid>
      </entry>
      <entry>
        <beta>o*)/</beta>
        <unic>Ὄ</unic>
        <unid>Ὄ</unid>
      </entry>
      <entry>
        <beta>o*)\</beta>
        <unic>Ὂ</unic>
        <unid>Ὂ</unid>
      </entry>
      <entry>
        <beta>o*)</beta>
        <unic>Ὀ</unic>
        <unid>Ὀ</unid>
      </entry>
      <entry>
        <beta>o*/</beta>
        <unic>Ό</unic>
        <unid>Ό</unid>
      </entry>
      <entry>
        <beta>o*\</beta>
        <unic>Ὸ</unic>
        <unid>Ὸ</unid>
      </entry>
      <entry>
        <beta>o*</beta>
        <unic>Ο</unic>
        <unid>Ο</unid>
      </entry>
      <entry>
        <beta>o(/</beta>
        <unic>ὅ</unic>
        <unid>ὅ</unid>
      </entry>
      <entry>
        <beta>o(\</beta>
        <unic>ὃ</unic>
        <unid>ὃ</unid>
      </entry>
      <entry>
        <beta>o(</beta>
        <unic>ὁ</unic>
        <unid>ὁ</unid>
      </entry>
      <entry>
        <beta>o)/</beta>
        <unic>ὄ</unic>
        <unid>ὄ</unid>
      </entry>
      <entry>
        <beta>o)\</beta>
        <unic>ὂ</unic>
        <unid>ὂ</unid>
      </entry>
      <entry>
        <beta>o)</beta>
        <unic>ὀ</unic>
        <unid>ὀ</unid>
      </entry>
      <entry>
        <beta>o/</beta>
        <unic>ό</unic>
        <unid>ό</unid>
      </entry>
      <entry>
        <beta>o\</beta>
        <unic>ὸ</unic>
        <unid>ὸ</unid>
      </entry>
      <entry>
        <beta>o</beta>
        <unic>ο</unic>
        <unid>ο</unid>
      </entry>
      <entry>
        <beta>p*</beta>
        <unic>Π</unic>
        <unid>Π</unid>
      </entry>
      <entry>
        <beta>p</beta>
        <unic>π</unic>
        <unid>π</unid>
      </entry>
      <entry>
        <beta>q*</beta>
        <unic>Θ</unic>
        <unid>Θ</unid>
      </entry>
      <entry>
        <beta>q</beta>
        <unic>θ</unic>
        <unid>θ</unid>
      </entry>
      <entry>
        <beta>r*(</beta>
        <unic>Ῥ</unic>
        <unid>Ῥ</unid>
      </entry>
      <entry>
        <beta>r*</beta>
        <unic>Ρ</unic>
        <unid>Ρ</unid>
      </entry>
      <entry>
        <beta>r(</beta>
        <unic>ῥ</unic>
        <unid>ῥ</unid>
      </entry>
      <entry>
        <beta>r)</beta>
        <unic>ῤ</unic>
        <unid>ῤ</unid>
      </entry>
      <entry>
        <beta>r</beta>
        <unic>ρ</unic>
        <unid>ρ</unid>
      </entry>
      <entry>
        <beta>s*</beta>
        <unic>Σ</unic>
        <unid>Σ</unid>
      </entry>
      <entry>
        <beta>s</beta>
        <unic>σ</unic>
        <unid>σ</unid>
      </entry>
      <entry>
        <beta>t*</beta>
        <unic>Τ</unic>
        <unid>Τ</unid>
      </entry>
      <entry>
        <beta>t</beta>
        <unic>τ</unic>
        <unid>τ</unid>
      </entry>
      <entry>
        <beta>u*(/</beta>
        <unic>Ὕ</unic>
        <unid>Ὕ</unid>
      </entry>
      <entry>
        <beta>u*(\</beta>
        <unic>Ὓ</unic>
        <unid>Ὓ</unid>
      </entry>
      <entry>
        <beta>u*(=</beta>
        <unic>Ὗ</unic>
        <unid>Ὗ</unid>
      </entry>
      <entry>
        <beta>u*(</beta>
        <unic>Ὑ</unic>
        <unid>Ὑ</unid>
      </entry>
      <entry>
        <beta>u*+</beta>
        <unic>Ϋ</unic>
        <unid>Ϋ</unid>
      </entry>
      <entry>
        <beta>u*/</beta>
        <unic>Ύ</unic>
        <unid>Ύ</unid>
      </entry>
      <entry>
        <beta>u*\</beta>
        <unic>Ὺ</unic>
        <unid>Ὺ</unid>
      </entry>
      <entry>
        <beta>u*_</beta>
        <unic>Ῡ</unic>
        <unid>Ῡ</unid>
      </entry>
      <entry>
        <beta>u*^</beta>
        <unic>Ῠ</unic>
        <unid>Ῠ</unid>
      </entry>
      <entry>
        <beta>u*</beta>
        <unic>Υ</unic>
        <unid>Υ</unid>
      </entry>
      <entry>
        <beta>u(/</beta>
        <unic>ὕ</unic>
        <unid>ὕ</unid>
      </entry>
      <entry>
        <beta>u(\</beta>
        <unic>ὓ</unic>
        <unid>ὓ</unid>
      </entry>
      <entry>
        <beta>u(=</beta>
        <unic>ὗ</unic>
        <unid>ὗ</unid>
      </entry>
      <entry>
        <beta>u(</beta>
        <unic>ὑ</unic>
        <unid>ὑ</unid>
      </entry>
      <entry>
        <beta>u)/</beta>
        <unic>ὔ</unic>
        <unid>ὔ</unid>
      </entry>
      <entry>
        <beta>u)\</beta>
        <unic>ὒ</unic>
        <unid>ὒ</unid>
      </entry>
      <entry>
        <beta>u)=</beta>
        <unic>ὖ</unic>
        <unid>ὖ</unid>
      </entry>
      <entry>
        <beta>u)</beta>
        <unic>ὐ</unic>
        <unid>ὐ</unid>
      </entry>
      <entry>
        <beta>u+/</beta>
        <unic>ΰ</unic>
        <unid>ΰ</unid>
      </entry>
      <entry>
        <beta>u+\</beta>
        <unic>ῢ</unic>
        <unid>ῢ</unid>
      </entry>
      <entry>
        <beta>u+=</beta>
        <unic>ῧ</unic>
        <unid>ῧ</unid>
      </entry>
      <entry>
        <beta>u+</beta>
        <unic>ϋ</unic>
        <unid>ϋ</unid>
      </entry>
      <entry>
        <beta>u/</beta>
        <unic>ύ</unic>
        <unid>ύ</unid>
      </entry>
      <entry>
        <beta>u\</beta>
        <unic>ὺ</unic>
        <unid>ὺ</unid>
      </entry>
      <entry>
        <beta>u=</beta>
        <unic>ῦ</unic>
        <unid>ῦ</unid>
      </entry>
      <entry>
        <beta>u_</beta>
        <unic>ῡ</unic>
        <unid>ῡ</unid>
      </entry>
      <entry>
        <beta>u^</beta>
        <unic>ῠ</unic>
        <unid>ῠ</unid>
      </entry>
      <entry>
        <beta>u</beta>
        <unic>υ</unic>
        <unid>υ</unid>
      </entry>
      <entry>
        <beta>v*</beta>
        <unic>Ϝ</unic>
        <unid>Ϝ</unid>
      </entry>
      <entry>
        <beta>v</beta>
        <unic>ϝ</unic>
        <unid>ϝ</unid>
      </entry>
      <entry>
        <beta>w*(/|</beta>
        <unic>ᾭ</unic>
        <unid>ᾭ</unid>
      </entry>
      <entry>
        <beta>w*(/</beta>
        <unic>Ὥ</unic>
        <unid>Ὥ</unid>
      </entry>
      <entry>
        <beta>w*(\|</beta>
        <unic>ᾫ</unic>
        <unid>ᾫ</unid>
      </entry>
      <entry>
        <beta>w*(\</beta>
        <unic>Ὣ</unic>
        <unid>Ὣ</unid>
      </entry>
      <entry>
        <beta>w*(=|</beta>
        <unic>ᾯ</unic>
        <unid>ᾯ</unid>
      </entry>
      <entry>
        <beta>w*(=</beta>
        <unic>Ὧ</unic>
        <unid>Ὧ</unid>
      </entry>
      <entry>
        <beta>w*(|</beta>
        <unic>ᾩ</unic>
        <unid>ᾩ</unid>
      </entry>
      <entry>
        <beta>w*(</beta>
        <unic>Ὡ</unic>
        <unid>Ὡ</unid>
      </entry>
      <entry>
        <beta>w*)/|</beta>
        <unic>ᾬ</unic>
        <unid>ᾬ</unid>
      </entry>
      <entry>
        <beta>w*)/</beta>
        <unic>Ὤ</unic>
        <unid>Ὤ</unid>
      </entry>
      <entry>
        <beta>w*)\|</beta>
        <unic>ᾪ</unic>
        <unid>ᾪ</unid>
      </entry>
      <entry>
        <beta>w*)\</beta>
        <unic>Ὢ</unic>
        <unid>Ὢ</unid>
      </entry>
      <entry>
        <beta>w*)=|</beta>
        <unic>ᾮ</unic>
        <unid>ᾮ</unid>
      </entry>
      <entry>
        <beta>w*)=</beta>
        <unic>Ὦ</unic>
        <unid>Ὦ</unid>
      </entry>
      <entry>
        <beta>w*)|</beta>
        <unic>ᾨ</unic>
        <unid>ᾨ</unid>
      </entry>
      <entry>
        <beta>w*)</beta>
        <unic>Ὠ</unic>
        <unid>Ὠ</unid>
      </entry>
      <entry>
        <beta>w*/</beta>
        <unic>Ώ</unic>
        <unid>Ώ</unid>
      </entry>
      <entry>
        <beta>w*\</beta>
        <unic>Ὼ</unic>
        <unid>Ὼ</unid>
      </entry>
      <entry>
        <beta>w*|</beta>
        <unic>ῼ</unic>
        <unid>ῼ</unid>
      </entry>
      <entry>
        <beta>w*</beta>
        <unic>Ω</unic>
        <unid>Ω</unid>
      </entry>
      <entry>
        <beta>w(/|</beta>
        <unic>ᾥ</unic>
        <unid>ᾥ</unid>
      </entry>
      <entry>
        <beta>w(/</beta>
        <unic>ὥ</unic>
        <unid>ὥ</unid>
      </entry>
      <entry>
        <beta>w(\|</beta>
        <unic>ᾣ</unic>
        <unid>ᾣ</unid>
      </entry>
      <entry>
        <beta>w(\</beta>
        <unic>ὣ</unic>
        <unid>ὣ</unid>
      </entry>
      <entry>
        <beta>w(=|</beta>
        <unic>ᾧ</unic>
        <unid>ᾧ</unid>
      </entry>
      <entry>
        <beta>w(=</beta>
        <unic>ὧ</unic>
        <unid>ὧ</unid>
      </entry>
      <entry>
        <beta>w(|</beta>
        <unic>ᾡ</unic>
        <unid>ᾡ</unid>
      </entry>
      <entry>
        <beta>w(</beta>
        <unic>ὡ</unic>
        <unid>ὡ</unid>
      </entry>
      <entry>
        <beta>w)/|</beta>
        <unic>ᾤ</unic>
        <unid>ᾤ</unid>
      </entry>
      <entry>
        <beta>w)/</beta>
        <unic>ὤ</unic>
        <unid>ὤ</unid>
      </entry>
      <entry>
        <beta>w)\|</beta>
        <unic>ᾢ</unic>
        <unid>ᾢ</unid>
      </entry>
      <entry>
        <beta>w)\</beta>
        <unic>ὢ</unic>
        <unid>ὢ</unid>
      </entry>
      <entry>
        <beta>w)=|</beta>
        <unic>ᾦ</unic>
        <unid>ᾦ</unid>
      </entry>
      <entry>
        <beta>w)=</beta>
        <unic>ὦ</unic>
        <unid>ὦ</unid>
      </entry>
      <entry>
        <beta>w)|</beta>
        <unic>ᾠ</unic>
        <unid>ᾠ</unid>
      </entry>
      <entry>
        <beta>w)</beta>
        <unic>ὠ</unic>
        <unid>ὠ</unid>
      </entry>
      <entry>
        <beta>w/|</beta>
        <unic>ῴ</unic>
        <unid>ῴ</unid>
      </entry>
      <entry>
        <beta>w/</beta>
        <unic>ώ</unic>
        <unid>ώ</unid>
      </entry>
      <entry>
        <beta>w\|</beta>
        <unic>ῲ</unic>
        <unid>ῲ</unid>
      </entry>
      <entry>
        <beta>w\</beta>
        <unic>ὼ</unic>
        <unid>ὼ</unid>
      </entry>
      <entry>
        <beta>w=|</beta>
        <unic>ῷ</unic>
        <unid>ῷ</unid>
      </entry>
      <entry>
        <beta>w=</beta>
        <unic>ῶ</unic>
        <unid>ῶ</unid>
      </entry>
      <entry>
        <beta>w|</beta>
        <unic>ῳ</unic>
        <unid>ῳ</unid>
      </entry>
      <entry>
        <beta>w</beta>
        <unic>ω</unic>
        <unid>ω</unid>
      </entry>
      <entry>
        <beta>x*</beta>
        <unic>Χ</unic>
        <unid>Χ</unid>
      </entry>
      <entry>
        <beta>x</beta>
        <unic>χ</unic>
        <unid>χ</unid>
      </entry>
      <entry>
        <beta>y*</beta>
        <unic>Ψ</unic>
        <unid>Ψ</unid>
      </entry>
      <entry>
        <beta>y</beta>
        <unic>ψ</unic>
        <unid>ψ</unid>
      </entry>
      <entry>
        <beta>z*</beta>
        <unic>Ζ</unic>
        <unid>Ζ</unid>
      </entry>
      <entry>
        <beta>z</beta>
        <unic>ζ</unic>
        <unid>ζ</unid>
      </entry>
      <!-- entries for diacritics only -->
      <!--
 here <unic> holds non-combining form, <unid> holds combining form 
-->
      <entry>
        <beta>(/|</beta>
        <unic>῞ͅ</unic>
        <unid>̔́ͅ</unid>
      </entry>
      <entry>
        <beta>(/</beta>
        <unic>῞</unic>
        <unid>̔́</unid>
      </entry>
      <entry>
        <beta>(\|</beta>
        <unic>῝ͅ</unic>
        <unid>̔̀ͅ</unid>
      </entry>
      <entry>
        <beta>(\</beta>
        <unic>῝</unic>
        <unid>̔̀</unid>
      </entry>
      <entry>
        <beta>(=|</beta>
        <unic>῟ͅ</unic>
        <unid>̔͂ͅ</unid>
      </entry>
      <entry>
        <beta>(=</beta>
        <unic>῟</unic>
        <unid>̔͂</unid>
      </entry>
      <entry>
        <beta>(|</beta>
        <unic>ʽͅ</unic>
        <unid>̔ͅ</unid>
      </entry>
      <entry>
        <beta>(</beta>
        <unic>ʽ</unic>
        <unid>̔</unid>
      </entry>
      <entry>
        <beta>)/|</beta>
        <unic>῎ͅ</unic>
        <unid>̓́ͅ</unid>
      </entry>
      <entry>
        <beta>)/</beta>
        <unic>῎</unic>
        <unid>̓́</unid>
      </entry>
      <entry>
        <beta>)\|</beta>
        <unic>῍ͅ</unic>
        <unid>̓̀ͅ</unid>
      </entry>
      <entry>
        <beta>)\</beta>
        <unic>῍</unic>
        <unid>̓̀</unid>
      </entry>
      <entry>
        <beta>)=|</beta>
        <unic>῏ͅ</unic>
        <unid>̓͂ͅ</unid>
      </entry>
      <entry>
        <beta>)=</beta>
        <unic>῏</unic>
        <unid>̓͂</unid>
      </entry>
      <entry>
        <beta>)|</beta>
        <unic>ʼͅ</unic>
        <unid>̓ͅ</unid>
      </entry>
      <entry>
        <beta>)</beta>
        <unic>ʼ</unic>
        <unid>̓</unid>
      </entry>
      <entry>
        <beta>+/</beta>
        <unic>΅</unic>
        <unid>̈́</unid>
      </entry>
      <entry>
        <beta>+\</beta>
        <unic>῭</unic>
        <unid>̈̀</unid>
      </entry>
      <entry>
        <beta>+=</beta>
        <unic>῁</unic>
        <unid>̈͂</unid>
      </entry>
      <entry>
        <beta>+</beta>
        <unic>¨</unic>
        <unid>̈</unid>
      </entry>
      <entry>
        <beta>/|</beta>
        <unic>´ͅ</unic>
        <unid>́ͅ</unid>
      </entry>
      <entry>
        <beta>/</beta>
        <unic>´</unic>
        <unid>́</unid>
      </entry>
      <entry>
        <beta>\|</beta>
        <unic>`ͅ</unic>
        <unid>̀ͅ</unid>
      </entry>
      <entry>
        <beta>\</beta>
        <unic>`</unic>
        <unid>̀</unid>
      </entry>
      <entry>
        <beta>=|</beta>
        <unic>῀ͅ</unic>
        <unid>͂ͅ</unid>
      </entry>
      <entry>
        <beta>=</beta>
        <unic>῀</unic>
        <unid>͂</unid>
      </entry>
      <entry>
        <beta>|</beta>
        <unic>ι</unic>
        <unid>ͅ</unid>
      </entry>
      <entry>
        <beta>_</beta>
        <unic>¯</unic>
        <unid>̄</unid>
      </entry>
      <entry>
        <beta>^</beta>
        <unic>˘</unic>
        <unid>̆</unid>
      </entry>
    </beta-uni-table>
  </xsl:variable>
  <xsl:variable name="beta-uni-table"
                select="exsl:node-set($raw-table)/beta-uni-table"/>

  <!--
    Insert betacode diacritic character in sorted order in string
    Parameters:
      $string       existing string
      $char         character to be inserted

    Output:
      updated string with character inserted in canonical order
  -->
  <xsl:template name="insert-diacritic">
    <xsl:param name="string"/>
    <xsl:param name="char"/>

    <xsl:choose>
      <!-- if empty string, use char -->
      <xsl:when test="string-length($string) = 0">
        <xsl:value-of select="$char"/>
      </xsl:when>

      <xsl:otherwise>
        <!-- find order of char and head of string -->
        <xsl:variable name="head" select="substring($string, 1, 1)"/>
        <xsl:variable name="charOrder">
          <xsl:call-template name="beta-order">
            <xsl:with-param name="beta" select="$char"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="headOrder">
          <xsl:call-template name="beta-order">
            <xsl:with-param name="beta" select="$head"/>
          </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
          <!-- if new char is greater than head, insert it in remainder -->
          <xsl:when test="number($charOrder) > number($headOrder)">
            <xsl:variable name="tail">
              <xsl:call-template name="insert-diacritic">
                <xsl:with-param name="string" select="substring($string, 2)"/>
                <xsl:with-param name="char" select="$char"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="concat($head, $tail)"/>
          </xsl:when>

          <!-- if same as head, discard it (don't want duplicates) -->
          <xsl:when test="number($charOrder) = number($headOrder)">
            <xsl:value-of select="$string"/>
          </xsl:when>

          <!-- if new char comes before head -->
          <xsl:otherwise>
            <xsl:value-of select="concat($char, $string)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Define canonical order of betacode diacritics
    Parameter:
      $beta        betacode diacritic character

    Output:
      numerical order of character in canonical ordering
  -->
  <xsl:template name="beta-order">
    <xsl:param name="beta"/>
    <xsl:choose>
      <!-- capitalization -->
      <xsl:when test="$beta = '*'">0</xsl:when>
      <!-- dasia -->
      <xsl:when test="$beta = '('">1</xsl:when>
      <!-- psili -->
      <xsl:when test="$beta = ')'">2</xsl:when>
      <!-- diaeresis -->
      <xsl:when test="$beta = '+'">3</xsl:when>
      <!-- acute -->
      <xsl:when test="$beta = '/'">4</xsl:when>
      <!-- grave -->
      <xsl:when test="$beta = '\'">5</xsl:when>
      <!-- perispomeni -->
      <xsl:when test="$beta = '='">6</xsl:when>
      <!-- ypogegrammeni -->
      <xsl:when test="$beta = '|'">7</xsl:when>
      <!-- macron -->
      <xsl:when test="$beta = '_'">8</xsl:when>
      <!-- breve -->
      <xsl:when test="$beta = '^'">9</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
    Convert betacode to unicode
    Parameters:
    $key          combined character plus diacritics
    $precomposed  whether to put out precomposed or decomposed Unicode
  -->
  <xsl:template match="beta-uni-table" mode="b2u">
    <xsl:param name="key"/>
    <xsl:param name="precomposed"/>

    <xsl:variable name="keylen" select="string-length($key)"/>

    <!-- if key exists -->
    <xsl:if test="$keylen > 0">
      <!-- try to find key in table -->
      <xsl:variable name="value">
        <xsl:choose>
          <xsl:when test="$precomposed">
            <xsl:value-of select="key('beta-uni-lookup', $key)/unic/text()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="key('beta-uni-lookup', $key)/unid/text()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <!-- if key found, use value -->
        <xsl:when test="string-length($value) > 0">
          <xsl:value-of select="$value"/>
        </xsl:when>

        <!-- if key not found and contains multiple chars -->
        <xsl:when test="$keylen > 1">
          <!-- lookup key with last char removed -->
          <xsl:apply-templates select="$beta-uni-table" mode="b2u">
            <xsl:with-param name="key" select="substring($key, 1, $keylen - 1)"/>
            <xsl:with-param name="precomposed" select="$precomposed"/>
          </xsl:apply-templates>
          <!-- convert last char -->
          <!-- precomposed=false means make sure it's a combining form -->
          <xsl:apply-templates select="$beta-uni-table" mode="b2u">
            <xsl:with-param name="key" select="substring($key, $keylen)"/>
            <xsl:with-param name="precomposed" select="false()"/>
          </xsl:apply-templates>
        </xsl:when>
      </xsl:choose>

      <!-- otherwise, ignore it (probably an errant *) -->
    </xsl:if>
  </xsl:template>

  <!--
    Convert unicode to betacode
    Parameters:
    $key          Unicode character to look up
  -->
  <xsl:template match="beta-uni-table" mode="u2b">
    <xsl:param name="key"/>
    <xsl:value-of select="key('unic-beta-lookup', $key)/beta/text()"/>
  </xsl:template>

</xsl:stylesheet>

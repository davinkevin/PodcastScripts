<?xml version="1.0"?>

<xsl:stylesheet version="2.0" 
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
      xmlns:atom="http://www.w3.org/2005/Atom"
      xmlns:fn="http://www.w3.org/2005/xpath-functions"
      xmlns:media="http://search.yahoo.com/mrss/" >

  <xsl:output method="xml" indent="yes" encoding="UTF-8" />
  
  <xsl:param name="title" required="yes"/>
  <xsl:param name="serverlocation" required="yes"/>

  <xsl:variable name="httpname">
    <xsl:value-of select="fn:replace(fn:concat('Canal+ - ',$title),' ','%20')" />
  </xsl:variable>

  <xsl:variable name="httphome">
    <xsl:value-of select="fn:concat($serverlocation, '/', $httpname, '/')" />
  </xsl:variable>  

  <xsl:template match="/">
    <rss>
      <channel>
        <title>Canal+ - <xsl:value-of select="$title"/></title>
        <description></description>
        <pubDate><xsl:value-of select="format-dateTime(current-dateTime(),'[FNn,*-3], [D01] [MNn,*-3] [Y0001] [H01]:[m01]:[s01] [Z]','en','AD','US')" /></pubDate>
        <image>
            <url><xsl:value-of select="$httphome"/>folder.jpg</url>
            <title>Canal+ - <xsl:value-of select="$title"/></title>
            <link><xsl:value-of select="$httphome"/></link>
        </image>
      
        <xsl:apply-templates select=".//VIDEO" >
          <xsl:sort select="concat(substring(.//INFOS/PUBLICATION/DATE, 7, 4),substring(.//INFOS/PUBLICATION/DATE, 4, 2),substring(.//INFOS/PUBLICATION/DATE, 1, 2))  " order="descending" data-type="text"/>
        </xsl:apply-templates>

      </channel>
    </rss>
  </xsl:template>

  <xsl:template match="VIDEO">
    <item>
      <title><xsl:value-of select="./INFOS/TITRAGE/TITRE" /></title>
      <xsl:choose>
        <xsl:when test=".//MEDIA/VIDEOS/HD[text() != '']">
          <link><xsl:value-of select=".//MEDIA/VIDEOS/HD"/></link>
          <guid><xsl:value-of select=".//MEDIA/VIDEOS/HD"/></guid>
        </xsl:when>
        <xsl:when test=".//MEDIA/VIDEOS/HAUT_DEBIT[text() != '']">
          <link><xsl:value-of select=".//MEDIA/VIDEOS/HAUT_DEBIT"/></link>
          <guid><xsl:value-of select=".//MEDIA/VIDEOS/HAUT_DEBIT"/></guid>
        </xsl:when>
        <xsl:otherwise>
          <link><xsl:value-of select=".//MEDIA/VIDEOS/BAS_DEBIT"/></link>
          <guid><xsl:value-of select=".//MEDIA/VIDEOS/BAS_DEBIT"/></guid>
        </xsl:otherwise>
       </xsl:choose>
       <xsl:choose>
        <xsl:when test=".//MEDIA/IMAGES/GRAND[text() != '']">
          <media:thumbnail >
            <xsl:attribute name="url">
              <xsl:value-of select=".//MEDIA/IMAGES/GRAND"/>
            </xsl:attribute>
          </media:thumbnail>
        </xsl:when>
        <xsl:when test=".//MEDIA/IMAGES/PETIT[text() != '']">
          <media:thumbnail >
            <xsl:attribute name="url">
              <xsl:value-of select=".//MEDIA/IMAGES/PETIT"/>
            </xsl:attribute>
          </media:thumbnail>
        </xsl:when>
        <xsl:otherwise />
       </xsl:choose>
      <description><xsl:value-of select=".//INFOS/DESCRIPTION"/></description>
      <pubDate>
      <xsl:variable name="currentPubdate">
        <xsl:value-of select="fn:concat(substring(.//INFOS/PUBLICATION/DATE, 7, 4), '-', substring(.//INFOS/PUBLICATION/DATE, 4, 2), '-', substring(.//INFOS/PUBLICATION/DATE, 1, 2))"/>T<xsl:value-of select=".//INFOS/PUBLICATION/HEURE"/>
      </xsl:variable>  
       <xsl:value-of select="format-dateTime($currentPubdate,'[FNn,*-3], [D01] [MNn,*-3] [Y0001] [H01]:[m01]:[s01] [Z]','en','AD','US')" />
       <!-- <xsl:value-of select="$currentPubdate" /> -->
      </pubDate>
    </item>
  </xsl:template>


</xsl:stylesheet>
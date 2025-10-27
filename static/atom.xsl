<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:atom="http://www.w3.org/2005/Atom"
    version="1.0">
    <xsl:output method="xml" />
    <xsl:template match="/">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="lang"><xsl:value-of select="/atom:feed/@xml:lang" /></xsl:attribute>
            <head>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width" />
                <title><xsl:value-of select="/atom:feed/atom:title" /> (Feed)</title>
                <link rel="stylesheet" href="atom.css"></link>
            </head>
            <body>
                <h1><xsl:value-of select="/atom:feed/atom:title" /> (Feed)</h1>
                <p>
                    Esse é um feed <a target="_blank" href="https://pt.wikipedia.org/wiki/Atom">Atom</a>.
                    Caso queira saber mais, recomendo a leitura do texto <a target="_blank" href="https://blog.dunossauro.com/posts/descentralizacao-de-consumo-na-internet/">Descentralização de consumo na internet</a>, ou o vídeo <a target="_blank" href="https://www.youtube.com/watch?v=IE8coapVoSk">Tô cansado de internet. E você?</a>.
                </p>
                <p>
                    Para adicioná-lo ao seu <a target="_blank" href="https://pt.wikipedia.org/wiki/Agregador_de_not%C3%ADcias">agregador de notícias</a>, copie e cole o enderço a baixo.
                </p>
                <p>
                    <label for="address">Endereço desse Feed:</label>
                    <input>
                        <xsl:attribute name="type">url</xsl:attribute>
                        <xsl:attribute name="id">address</xsl:attribute>
                        <xsl:attribute name="spellcheck">false</xsl:attribute>
                        <xsl:attribute name="readonly">true</xsl:attribute>
                        <xsl:attribute name="value"><xsl:value-of select="/atom:feed/atom:link[@rel='self']/@href" /></xsl:attribute>
                    </input>
                </p>
                <h2>Notícias nesse Feed:</h2>
                <ul>
                    <xsl:for-each select="/atom:feed/atom:entry">
                        <li>
                            [<xsl:value-of select="concat(substring(./atom:updated, 9, 2), '/', substring(./atom:updated, 6, 2), '/', substring(./atom:updated, 1, 4))" />]
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="link" />
                                </xsl:attribute>
                                <xsl:value-of select="./atom:title" />
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>

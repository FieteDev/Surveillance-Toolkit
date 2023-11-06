<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/2000/svg" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">
    <xsl:output
        method="xml"
        version="1.0"
        encoding="UTF-8"
        doctype-public="-//W3C//DTD SVG 1.1//EN"
        doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"
        indent="yes"
        cdata-section-elements="style"
    />
    <xsl:include href="Tools.xslt"/>
    <xsl:template match="/">
        <svg version="1.1" viewBox="0 0 21000 29700">
            <style type="text/css">
                <![CDATA[
                    text { font-family: Noto Serif, serif; }
                ]]>
            </style>
            <symbol id="flag" viewBox="0 0 1580 1080">
                <rect width="1580" height="1080" fill="#FFF"/>
                <rect x="40" y="40" width="1500" height="1000" fill="#039"/>
                <polygon fill="#FC0" points="956.6666666666666,195.76930984963155 989.3214029051373,296.2702539815731 903.8301935391581,234.15725460657893 1009.5031397941751,234.1572546065789 924.0119304281959,296.2702539815731"/>
                <polygon fill="#FC0" points="1078.6751345948128,317.7777777777777 1111.3298708332836,418.27872190971925 1025.8386614673043,356.1657225347251 1131.5116077223213,356.16572253472503 1046.020398356342,418.27872190971925"/>
                <polygon fill="#FC0" points="1123.3333333333333,484.44444444444446 1155.988069571804,584.945388576386 1070.4968602058248,522.8323892013918 1176.1698064608418,522.8323892013918 1090.6785970948627,584.945388576386"/>
                <polygon fill="#FC0" points="1078.6751345948128,651.111111111111 1111.3298708332836,751.6120552430525 1025.8386614673043,689.4990558680583 1131.5116077223213,689.4990558680583 1046.020398356342,751.6120552430525"/>
                <polygon fill="#FC0" points="956.6666666666666,773.1195790392574 989.3214029051373,873.6205231711989 903.8301935391581,811.5075237962047 1009.5031397941751,811.5075237962047 924.0119304281959,873.6205231711989"/>
                <polygon fill="#FC0" points="790,817.7777777777777 822.6547362384707,918.2787219097193 737.1635268724915,856.1657225347251 842.8364731275085,856.1657225347251 757.3452637615293,918.2787219097193"/>
                <polygon fill="#FC0" points="623.3333333333333,773.1195790392572 655.988069571804,873.6205231711988 570.4968602058248,811.5075237962046 676.1698064608418,811.5075237962046 590.6785970948625,873.6205231711988"/>
                <polygon fill="#FC0" points="501.32486540518727,651.1111111111112 533.979601643658,751.6120552430527 448.4883922776787,689.4990558680586 554.1613385326958,689.4990558680586 468.67012916671655,751.6120552430527"/>
                <polygon fill="#FC0" points="456.6666666666667,484.44444444444457 489.3214029051374,584.9453885763861 403.83019353915813,522.832389201392 509.50313979417524,522.832389201392 424.01193042819597,584.9453885763861"/>
                <polygon fill="#FC0" points="501.3248654051872,317.7777777777778 533.9796016436579,418.27872190971937 448.48839227767866,356.1657225347252 554.1613385326957,356.16572253472515 468.6701291667165,418.27872190971937"/>
                <polygon fill="#FC0" points="623.3333333333333,195.76930984963172 655.988069571804,296.27025398157326 570.4968602058248,234.1572546065791 676.1698064608418,234.15725460657907 590.6785970948625,296.27025398157326"/>
                <polygon fill="#FC0" points="789.9999999999999,151.1111111111112 822.6547362384706,251.6120552430527 737.1635268724914,189.49905586805858 842.8364731275084,189.49905586805855 757.3452637615292,251.61205524305274"/>
            </symbol>
            <symbol id="cc" viewBox="5.5 -3.5 64 64">
                <circle fill="#FFF" cx="37.785" cy="28.501" r="28.836"/>
                <path d="M37.441-3.5c8.951,0,16.572,3.125,22.857,9.372c3.008,3.009,5.295,6.448,6.857,10.314   c1.561,3.867,2.344,7.971,2.344,12.314c0,4.381-0.773,8.486-2.314,12.313c-1.543,3.828-3.82,7.21-6.828,10.143   c-3.123,3.085-6.666,5.448-10.629,7.086c-3.961,1.638-8.057,2.457-12.285,2.457s-8.276-0.808-12.143-2.429   c-3.866-1.618-7.333-3.961-10.4-7.027c-3.067-3.066-5.4-6.524-7-10.372S5.5,32.767,5.5,28.5c0-4.229,0.809-8.295,2.428-12.2   c1.619-3.905,3.972-7.4,7.057-10.486C21.08-0.394,28.565-3.5,37.441-3.5z M37.557,2.272c-7.314,0-13.467,2.553-18.458,7.657   c-2.515,2.553-4.448,5.419-5.8,8.6c-1.354,3.181-2.029,6.505-2.029,9.972c0,3.429,0.675,6.734,2.029,9.913   c1.353,3.183,3.285,6.021,5.8,8.516c2.514,2.496,5.351,4.399,8.515,5.715c3.161,1.314,6.476,1.971,9.943,1.971   c3.428,0,6.75-0.665,9.973-1.999c3.219-1.335,6.121-3.257,8.713-5.771c4.99-4.876,7.484-10.99,7.484-18.344   c0-3.543-0.648-6.895-1.943-10.057c-1.293-3.162-3.18-5.98-5.654-8.458C50.984,4.844,44.795,2.272,37.557,2.272z M37.156,23.187   l-4.287,2.229c-0.458-0.951-1.019-1.619-1.685-2c-0.667-0.38-1.286-0.571-1.858-0.571c-2.856,0-4.286,1.885-4.286,5.657   c0,1.714,0.362,3.084,1.085,4.113c0.724,1.029,1.791,1.544,3.201,1.544c1.867,0,3.181-0.915,3.944-2.743l3.942,2   c-0.838,1.563-2,2.791-3.486,3.686c-1.484,0.896-3.123,1.343-4.914,1.343c-2.857,0-5.163-0.875-6.915-2.629   c-1.752-1.752-2.628-4.19-2.628-7.313c0-3.048,0.886-5.466,2.657-7.257c1.771-1.79,4.009-2.686,6.715-2.686   C32.604,18.558,35.441,20.101,37.156,23.187z M55.613,23.187l-4.229,2.229c-0.457-0.951-1.02-1.619-1.686-2   c-0.668-0.38-1.307-0.571-1.914-0.571c-2.857,0-4.287,1.885-4.287,5.657c0,1.714,0.363,3.084,1.086,4.113   c0.723,1.029,1.789,1.544,3.201,1.544c1.865,0,3.18-0.915,3.941-2.743l4,2c-0.875,1.563-2.057,2.791-3.541,3.686   c-1.486,0.896-3.105,1.343-4.857,1.343c-2.896,0-5.209-0.875-6.941-2.629c-1.736-1.752-2.602-4.19-2.602-7.313   c0-3.048,0.885-5.466,2.658-7.257c1.77-1.79,4.008-2.686,6.713-2.686C51.117,18.558,53.938,20.101,55.613,23.187z"/>
            </symbol>
            <symbol id="by" viewBox="5.5 -3.5 64 64">
                <circle fill="#FFF" cx="37.637" cy="28.806" r="28.276"/>
                <path d="M37.443-3.5c8.988,0,16.57,3.085,22.742,9.257C66.393,11.967,69.5,19.548,69.5,28.5c0,8.991-3.049,16.476-9.145,22.456    C53.879,57.319,46.242,60.5,37.443,60.5c-8.649,0-16.153-3.144-22.514-9.43C8.644,44.784,5.5,37.262,5.5,28.5    c0-8.761,3.144-16.342,9.429-22.742C21.101-0.415,28.604-3.5,37.443-3.5z M37.557,2.272c-7.276,0-13.428,2.553-18.457,7.657    c-5.22,5.334-7.829,11.525-7.829,18.572c0,7.086,2.59,13.22,7.77,18.398c5.181,5.182,11.352,7.771,18.514,7.771    c7.123,0,13.334-2.607,18.629-7.828c5.029-4.838,7.543-10.952,7.543-18.343c0-7.276-2.553-13.465-7.656-18.571    C50.967,4.824,44.795,2.272,37.557,2.272z M46.129,20.557v13.085h-3.656v15.542h-9.944V33.643h-3.656V20.557    c0-0.572,0.2-1.057,0.599-1.457c0.401-0.399,0.887-0.6,1.457-0.6h13.144c0.533,0,1.01,0.2,1.428,0.6    C45.918,19.5,46.129,19.986,46.129,20.557z M33.042,12.329c0-3.008,1.485-4.514,4.458-4.514s4.457,1.504,4.457,4.514    c0,2.971-1.486,4.457-4.457,4.457S33.042,15.3,33.042,12.329z"/>
            </symbol>
            <xsl:if test="root/data[@name='translated_by']/value">
                <text x="19300" y="24300" font-size="400px" font-style="italic" text-anchor="end">
                    <xsl:value-of select="root/data[@name='translated_by']/value"/>
                </text>
            </xsl:if> 
            <rect fill="white" stroke="black" x="1700" y="24500" width="17600" height="3500"/>
            <text x="2200" y="25300" font-size="500px" font-weight="bold">
                <xsl:value-of select="root/data[@name='neoipc_project']/value"/>
            </text>
            <text x="2200" y="25900" font-size="400px" fill="#0083C1">https://neoipc.org</text>
            <use xlink:href="#flag" x="2080" y="26600" width="1580" height="1080"/>
            <text x="3800" y="27000" font-size="350px">
                <xsl:call-template name="split_long_text">
                    <xsl:with-param name="text" select="root/data[@name='funding_statement']/value/text()"/>
                    <xsl:with-param name="maxLen" select="96"/>
                    <xsl:with-param name="x" select="3800"/>
                    <xsl:with-param name="first_dy" select="0"/>
                    <xsl:with-param name="further_dy" select="420"/>
                </xsl:call-template>
            </text>
            <text x="17300" y="28600" font-size="370px" text-anchor="end">
                <tspan><xsl:value-of select="root/data[@name='licensed_under']/value"/> CC BY 4.0</tspan>
                <tspan x="17300" dy="390">)</tspan>
                <tspan dx="195" fill="#0083C1">
                    <xsl:choose>
                        <xsl:when test="root/data[@name='license_url']/value">
                            <xsl:value-of select="root/data[@name='license_url']/value"/>
                        </xsl:when>
                        <xsl:otherwise>https://creativecommons.org/licenses/by/4.0/</xsl:otherwise>
                    </xsl:choose>
                </tspan>
                <tspan dx="190">(</tspan>
            </text>
            <image xlink:href="img/cc.xlarge.png" x="17500" y="28250" width="800" height="800" />
            <image xlink:href="img/by.xlarge.png" x="18500" y="28250" width="800" height="800" />
        </svg>
    </xsl:template>
</xsl:stylesheet>

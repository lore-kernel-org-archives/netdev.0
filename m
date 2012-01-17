From: "Naveen B N (nbn)" <nbn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Receive Ip packets to user space which have to
	be protected by IPsec
Date: Tue, 17 Jan 2012 19:31:28 +0530
Message-ID: <A2354B6A9F807641B21EEABD666ECEEA02699511@XMB-BGL-416.cisco.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2461520513108356607=="
To: <ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <ipsec-tools-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel>,
	<mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipsec-tools-devel>
List-Post: <mailto:ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel>,
	<mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: ipsec-tools-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============2461520513108356607==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01CCD520.826F3853"

This is a multi-part message in MIME format.

------_=_NextPart_001_01CCD520.826F3853
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

Hi All=20

Are there method to get IP packet With tunneled ip address( basically
subscriber Ip)=20

which have to be protected with Ipsec , where there is no

route added to the tunneled IP address , but the outer=20

Ip address have  routes added.

=20

If there is no route added the packet will be dropped at the routing=20

 phase itself and may not reach the Interface, so that it can be
captured=20

 using pf_packet.

=20

Any guidance will be appreciated.

=20

Thanks and Regards

Naveen


------_=_NextPart_001_01CCD520.826F3853
Content-Type: text/html;
	charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" =
xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" =
xmlns=3D"http://www.w3.org/TR/REC-html40"><head><meta =
http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii"><meta name=3DGenerator content=3D"Microsoft Word 12 =
(filtered medium)"><style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri","sans-serif";
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]--></head><body lang=3DEN-US link=3Dblue =
vlink=3Dpurple><div class=3DWordSection1><p class=3DMsoNormal>Hi All =
<o:p></o:p></p><p class=3DMsoNormal>Are there method to get IP packet =
With tunneled ip address( basically subscriber Ip) <o:p></o:p></p><p =
class=3DMsoNormal>which have to be protected with Ipsec , where there is =
no<o:p></o:p></p><p class=3DMsoNormal>route added to the tunneled IP =
address , but the outer <o:p></o:p></p><p class=3DMsoNormal>Ip address =
have &nbsp;routes added.<o:p></o:p></p><p =
class=3DMsoNormal><o:p>&nbsp;</o:p></p><p class=3DMsoNormal> If there is =
no route added the packet will be dropped at the routing =
<o:p></o:p></p><p class=3DMsoNormal>&nbsp;phase itself and may not reach =
the Interface, so that it can be captured <o:p></o:p></p><p =
class=3DMsoNormal>&nbsp;using pf_packet.<o:p></o:p></p><p =
class=3DMsoNormal><o:p>&nbsp;</o:p></p><p class=3DMsoNormal>Any guidance =
will be appreciated.<o:p></o:p></p><p =
class=3DMsoNormal><o:p>&nbsp;</o:p></p><p class=3DMsoNormal>Thanks and =
Regards<o:p></o:p></p><p =
class=3DMsoNormal>Naveen<o:p></o:p></p></div></body></html>
------_=_NextPart_001_01CCD520.826F3853--


--===============2461520513108356607==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Keep Your Developer Skills Current with LearnDevNow!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-d2d
--===============2461520513108356607==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============2461520513108356607==--

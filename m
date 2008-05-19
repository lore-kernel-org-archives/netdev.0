From: "Hennerich, Michael" <Michael.Hennerich-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/01] smsc911x: fix MAC
	addresssetting after reset
Date: Mon, 19 May 2008 14:15:25 +0100
Message-ID: <8A42379416420646B9BFAC9682273B6D018860B3@limkexm3.ad.analog.com>
References: <8A42379416420646B9BFAC9682273B6D01786F29@limkexm3.ad.analog.com>
	<OF577965B4.463E76D4-ON8025744E.0041E1EE-8025744E.0044F4BC@smsc.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1278347994=="
Cc: bgat-uPd5UNENI//N9NzbbXoYwQ@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, bahadir.balban-5wv7dgnIgG8@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ian.Saturley-sdUf+H5yV5I@public.gmane.org,
        uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: <Steve.Glendinning-sdUf+H5yV5I@public.gmane.org>,
        "Hennerich, Michael" <Michael.Hennerich-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <OF577965B4.463E76D4-ON8025744E.0041E1EE-8025744E.0044F4BC-sdUf+H5yV5I@public.gmane.org>
List-Unsubscribe: <http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============1278347994==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C8B9B2.6732CCAE"

This is a multi-part message in MIME format.

------_=_NextPart_001_01C8B9B2.6732CCAE
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Steve,

=20

I'd love to see this one merged.

=20

-Michael

=20

________________________________

From: Steve.Glendinning-sdUf+H5yV5I@public.gmane.org [mailto:Steve.Glendinning-sdUf+H5yV5I@public.gmane.org]=20
Sent: Montag, 19. Mai 2008 14:33
To: Hennerich, Michael
Cc: bahadir.balban-5wv7dgnIgG8@public.gmane.org; bgat-uPd5UNENI//N9NzbbXoYwQ@public.gmane.org; Enrik Berkhan;
hennerich-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org; Ian.Saturley-sdUf+H5yV5I@public.gmane.org;
uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org; catalin.marinas-5wv7dgnIgG8@public.gmane.org;
netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Subject: RE: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC
addresssetting after reset

=20


Hi Michael,=20

I've been maintaining the smsc911x driver out-of-tree, I'll send my
latest full patch following this email.  Bill Gatliff already fixed the
same MAC address issue, and I've added support for the new LAN9210 and
LAN9211 devices.=20

(adding netdev to cc) I'd still like to see this driver replace smc911x
in mainline, how does everyone else feel?=20

Regards,=20
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning-sdUf+H5yV5I@public.gmane.org





"Hennerich, Michael" <Michael.Hennerich-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>=20

16/05/2008 11:58=20

To

"Enrik Berkhan" <Enrik.Berkhan-JJi787mZWgc@public.gmane.org>, Steve Glendinning/SMSC@SMSC=20

cc

<hennerich-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>, Ian Saturley/SMSC@SMSC,
<uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>, <bahadir.balban-5wv7dgnIgG8@public.gmane.org>,
<bgat-uPd5UNENI//N9NzbbXoYwQ@public.gmane.org>=20

Subject

RE: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC addresssetting
after reset

=20

=20

=20




Hi Steve,

I received a patch to address the MAC address soft reset issue,
discussed before.

Is there a newer driver with this and maybe other fixes?

Some time ago I thought this driver is going to be mainlined.
Are you still panning to get it merged, - replace smc911x.c.

-Michael

>-----Original Message-----
>From: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
[mailto:uclinux-dist-
>devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org] On Behalf Of Enrik Berkhan
>Sent: Donnerstag, 15. Mai 2008 19:08
>To: uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
>Subject: [Uclinux-dist-devel] [PATCH 01/01] smsc911x: fix MAC
>addresssetting after reset
>
>The SMSC911X driver soft-resets the chip on open(). This makes the
>chip forget and re-load its MAC address from its EEPROM, if avail-
>able.
>
>If the MAC address has been set externally (e. g. by the bootloader
>or via command line), this setting is lost. This patch fixes the
>problem by always setting the saved MAC address after soft reset.
>
>Signed-Off-By: Enrik Berkhan <Enrik.Berkhan-JJi787mZWgc@public.gmane.org>
>---
> drivers/net/smsc911x.c |    4 ++++
> 1 file changed, 4 insertions(+)
>
>Index: drivers/net/smsc911x.c
>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>--- drivers/net/smsc911x.c.orig                 2008-05-15
18:49:30.000000000
+0200
>+++ drivers/net/smsc911x.c                 2008-05-15
18:51:28.000000000 +0200
>@@ -1182,6 +1182,10 @@ static int smsc911x_open(struct net_devi
>                                   udelay(10);
>                  }
>
>+                 /* Set MAC again in case it has been set from
non-EEPROM source
>+                  * (config or even bootloader) */
>+                 smsc911x_set_mac_address(pdata, dev->dev_addr);
>+
>                  if (unlikely(timeout =3D=3D 0)) {
>                                   SMSC_WARNING("Timed out waiting for
EEPROM "
>                                                         "busy bit to
clear");
>_______________________________________________
>Uclinux-dist-devel mailing list
>Uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
>http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel


------_=_NextPart_001_01C8B9B2.6732CCAE
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" =
xmlns:o=3D"urn:schemas-microsoft-com:office:office" =
xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:st1=3D"urn:schemas-microsoft-com:office:smarttags" =
xmlns=3D"http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<meta name=3DGenerator content=3D"Microsoft Word 11 (filtered medium)">
<!--[if !mso]>
<style>
v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style>
<![endif]--><o:SmartTagType
 namespaceuri=3D"urn:schemas-microsoft-com:office:smarttags" =
name=3D"PersonName"/>
<!--[if !mso]>
<style>
st1\:*{behavior:url(#default#ieooui) }
</style>
<![endif]-->
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;}
@font-face
	{font-family:sans-serif;
	panose-1:0 0 0 0 0 0 0 0 0 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	margin-bottom:.0001pt;
	font-size:12.0pt;
	font-family:"Times New Roman";}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;}
p
	{mso-margin-top-alt:auto;
	margin-right:0cm;
	mso-margin-bottom-alt:auto;
	margin-left:0cm;
	font-size:12.0pt;
	font-family:"Times New Roman";}
tt
	{font-family:"Courier New";}
span.EmailStyle19
	{mso-style-type:personal-reply;
	font-family:Arial;
	color:navy;}
@page Section1
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext=3D"edit">
  <o:idmap v:ext=3D"edit" data=3D"1" />
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=3DEN-US link=3Dblue vlink=3Dpurple>

<div class=3DSection1>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'>Steve,<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'>I&#8217;d love to see this one =
merged.<o:p></o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'>-Michael<o:p></o:p></span></font></p=
>

<p class=3DMsoNormal><font size=3D2 color=3Dnavy face=3DArial><span =
style=3D'font-size:
10.0pt;font-family:Arial;color:navy'><o:p>&nbsp;</o:p></span></font></p>

<div style=3D'border:none;border-left:solid blue 1.5pt;padding:0cm 0cm =
0cm 4.0pt'>

<div>

<div class=3DMsoNormal align=3Dcenter style=3D'text-align:center'><font =
size=3D3
face=3D"Times New Roman"><span style=3D'font-size:12.0pt'>

<hr size=3D2 width=3D"100%" align=3Dcenter tabindex=3D-1>

</span></font></div>

<p class=3DMsoNormal><b><font size=3D2 face=3DTahoma><span =
style=3D'font-size:10.0pt;
font-family:Tahoma;font-weight:bold'>From:</span></font></b><font =
size=3D2
face=3DTahoma><span style=3D'font-size:10.0pt;font-family:Tahoma'> =
<st1:PersonName
w:st=3D"on">Steve.Glendinning-sdUf+H5yV5I@public.gmane.org</st1:PersonName> =
[mailto:<st1:PersonName
w:st=3D"on">Steve.Glendinning-sdUf+H5yV5I@public.gmane.org</st1:PersonName>] <br>
<b><span style=3D'font-weight:bold'>Sent:</span></b> Montag, 19. Mai =
2008 14:33<br>
<b><span style=3D'font-weight:bold'>To:</span></b> Hennerich, =
Michael<br>
<b><span style=3D'font-weight:bold'>Cc:</span></b> =
bahadir.balban-5wv7dgnIgG8@public.gmane.org; <st1:PersonName
w:st=3D"on">bgat-uPd5UNENI//N9NzbbXoYwQ@public.gmane.org</st1:PersonName>; Enrik Berkhan;
hennerich-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org; Ian.Saturley-sdUf+H5yV5I@public.gmane.org; =
uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org;
catalin.marinas-5wv7dgnIgG8@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org<br>
<b><span style=3D'font-weight:bold'>Subject:</span></b> RE: =
[Uclinux-dist-devel]
[PATCH 01/01] smsc911x: fix MAC addresssetting after =
reset</span></font><o:p></o:p></p>

</div>

<p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span =
style=3D'font-size:
12.0pt'><o:p>&nbsp;</o:p></span></font></p>

<p class=3DMsoNormal style=3D'margin-bottom:12.0pt'><font size=3D3
face=3D"Times New Roman"><span style=3D'font-size:12.0pt'><br>
</span></font><font size=3D2 face=3Dsans-serif><span =
style=3D'font-size:10.0pt;
font-family:sans-serif'>Hi Michael,</span></font> <br>
<br>
<font size=3D2 face=3Dsans-serif><span =
style=3D'font-size:10.0pt;font-family:sans-serif'>I've
been maintaining the smsc911x driver out-of-tree, I'll send my latest =
full
patch following this email. &nbsp;Bill Gatliff already fixed the same =
MAC
address issue, and I've added support for the new LAN9210 and LAN9211 =
devices.</span></font>
<br>
<br>
<font size=3D2 face=3Dsans-serif><span =
style=3D'font-size:10.0pt;font-family:sans-serif'>(adding
netdev to cc) I'd still like to see this driver replace smc911x in =
mainline,
how does everyone else feel?</span></font> <br>
<br>
<font size=3D2 face=3Dsans-serif><span =
style=3D'font-size:10.0pt;font-family:sans-serif'>Regards,</span></font>
<br>
<font size=3D2 face=3Dsans-serif><span =
style=3D'font-size:10.0pt;font-family:sans-serif'>--<br>
Steve Glendinning<br>
SMSC GmbH<br>
m: +44 777 933 9124<br>
e: steve.glendinning-sdUf+H5yV5I@public.gmane.org<br>
<br>
</span></font><br>
<br>
<o:p></o:p></p>

<table class=3DMsoNormalTable border=3D0 cellpadding=3D0 width=3D"100%"
 style=3D'width:100.0%'>
 <tr>
  <td width=3D"40%" valign=3Dtop style=3D'width:40.0%;padding:.75pt =
.75pt .75pt .75pt'>
  <p class=3DMsoNormal><b><font size=3D1 face=3Dsans-serif><span =
style=3D'font-size:
  7.5pt;font-family:sans-serif;font-weight:bold'>&quot;Hennerich, =
Michael&quot;
  &lt;Michael.Hennerich-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org&gt;</span></font></b><font size=3D1
  face=3Dsans-serif><span =
style=3D'font-size:7.5pt;font-family:sans-serif'> =
</span></font><o:p></o:p></p>
  <p><font size=3D1 face=3Dsans-serif><span =
style=3D'font-size:7.5pt;font-family:
  sans-serif'>16/05/2008 11:58</span></font> <o:p></o:p></p>
  </td>
  <td width=3D"59%" valign=3Dtop style=3D'width:59.0%;padding:.75pt =
.75pt .75pt .75pt'>
  <table class=3DMsoNormalTable border=3D0 cellpadding=3D0 =
width=3D"100%"
   style=3D'width:100.0%'>
   <tr>
    <td valign=3Dtop style=3D'padding:.75pt .75pt .75pt .75pt'>
    <p class=3DMsoNormal align=3Dright style=3D'text-align:right'><font =
size=3D1
    face=3Dsans-serif><span =
style=3D'font-size:7.5pt;font-family:sans-serif'>To</span></font><o:p></o=
:p></p>
    </td>
    <td valign=3Dtop style=3D'padding:.75pt .75pt .75pt .75pt'>
    <p class=3DMsoNormal><font size=3D1 face=3Dsans-serif><span =
style=3D'font-size:
    7.5pt;font-family:sans-serif'>&quot;Enrik Berkhan&quot;
    &lt;Enrik.Berkhan-JJi787mZWgc@public.gmane.org&gt;, Steve =
Glendinning/SMSC@SMSC</span></font> <o:p></o:p></p>
    </td>
   </tr>
   <tr>
    <td valign=3Dtop style=3D'padding:.75pt .75pt .75pt .75pt'>
    <p class=3DMsoNormal align=3Dright style=3D'text-align:right'><font =
size=3D1
    face=3Dsans-serif><span =
style=3D'font-size:7.5pt;font-family:sans-serif'>cc</span></font><o:p></o=
:p></p>
    </td>
    <td valign=3Dtop style=3D'padding:.75pt .75pt .75pt .75pt'>
    <p class=3DMsoNormal><font size=3D1 face=3Dsans-serif><span =
style=3D'font-size:
    =
7.5pt;font-family:sans-serif'>&lt;hennerich-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org&gt;, =
Ian
    Saturley/SMSC@SMSC, &lt;uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org&gt;,
    &lt;bahadir.balban-5wv7dgnIgG8@public.gmane.org&gt;, &lt;<st1:PersonName =
w:st=3D"on">bgat-uPd5UNENI//N9NzbbXoYwQ@public.gmane.org</st1:PersonName>&gt;</span></font>
    <o:p></o:p></p>
    </td>
   </tr>
   <tr>
    <td valign=3Dtop style=3D'padding:.75pt .75pt .75pt .75pt'>
    <p class=3DMsoNormal align=3Dright style=3D'text-align:right'><font =
size=3D1
    face=3Dsans-serif><span =
style=3D'font-size:7.5pt;font-family:sans-serif'>Subject</span></font><o:=
p></o:p></p>
    </td>
    <td valign=3Dtop style=3D'padding:.75pt .75pt .75pt .75pt'>
    <p class=3DMsoNormal><font size=3D1 face=3Dsans-serif><span =
style=3D'font-size:
    7.5pt;font-family:sans-serif'>RE: [Uclinux-dist-devel] [PATCH 01/01]
    smsc911x: fix MAC addresssetting after =
reset</span></font><o:p></o:p></p>
    </td>
   </tr>
  </table>
  <p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span
  style=3D'font-size:12.0pt'><o:p>&nbsp;</o:p></span></font></p>
  <table class=3DMsoNormalTable border=3D0 cellpadding=3D0>
   <tr>
    <td valign=3Dtop style=3D'padding:.75pt .75pt .75pt .75pt'>
    <p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span
    style=3D'font-size:12.0pt'><o:p>&nbsp;</o:p></span></font></p>
    </td>
    <td valign=3Dtop style=3D'padding:.75pt .75pt .75pt .75pt'>
    <p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span
    style=3D'font-size:12.0pt'><o:p>&nbsp;</o:p></span></font></p>
    </td>
   </tr>
  </table>
  <p class=3DMsoNormal><font size=3D3 face=3D"Times New Roman"><span
  style=3D'font-size:12.0pt'><o:p></o:p></span></font></p>
  </td>
 </tr>
</table>

<p class=3DMsoNormal style=3D'margin-bottom:12.0pt'><font size=3D3
face=3D"Times New Roman"><span style=3D'font-size:12.0pt'><br>
<br>
<br>
</span></font><tt><font size=3D2 face=3D"Courier New"><span =
style=3D'font-size:10.0pt'>Hi
Steve,</span></font></tt><font size=3D2 face=3D"Courier New"><span
style=3D'font-size:10.0pt;font-family:"Courier New"'><br>
<br>
<tt><font face=3D"Courier New">I received a patch to address the MAC =
address soft
reset issue,</font></tt><br>
<tt><font face=3D"Courier New">discussed before.</font></tt><br>
<br>
<tt><font face=3D"Courier New">Is there a newer driver with this and =
maybe other
fixes?</font></tt><br>
<br>
<tt><font face=3D"Courier New">Some time ago I thought this driver is =
going to be
mainlined.</font></tt><br>
<tt><font face=3D"Courier New">Are you still panning to get it merged, - =
replace
smc911x.c.</font></tt><br>
<br>
<tt><font face=3D"Courier New">-Michael</font></tt><br>
<br>
<tt><font face=3D"Courier New">&gt;-----Original =
Message-----</font></tt><br>
<tt><font face=3D"Courier New">&gt;From: =
uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org</font></tt><br>
<tt><font face=3D"Courier New">[mailto:uclinux-dist-</font></tt><br>
<tt><font face=3D"Courier New">&gt;devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org] =
On Behalf
Of Enrik Berkhan</font></tt><br>
<tt><font face=3D"Courier New">&gt;Sent: Donnerstag, 15. Mai 2008 =
19:08</font></tt><br>
<tt><font face=3D"Courier New">&gt;To: =
uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org</font></tt><br>
<tt><font face=3D"Courier New">&gt;Subject: [Uclinux-dist-devel] [PATCH =
01/01]
smsc911x: fix MAC</font></tt><br>
<tt><font face=3D"Courier New">&gt;addresssetting after =
reset</font></tt><br>
<tt><font face=3D"Courier New">&gt;</font></tt><br>
<tt><font face=3D"Courier New">&gt;The SMSC911X driver soft-resets the =
chip on
open(). This makes the</font></tt><br>
<tt><font face=3D"Courier New">&gt;chip forget and re-load its MAC =
address from
its EEPROM, if avail-</font></tt><br>
<tt><font face=3D"Courier New">&gt;able.</font></tt><br>
<tt><font face=3D"Courier New">&gt;</font></tt><br>
<tt><font face=3D"Courier New">&gt;If the MAC address has been set =
externally (e.
g. by the bootloader</font></tt><br>
<tt><font face=3D"Courier New">&gt;or via command line), this setting is =
lost.
This patch fixes the</font></tt><br>
<tt><font face=3D"Courier New">&gt;problem by always setting the saved =
MAC
address after soft reset.</font></tt><br>
<tt><font face=3D"Courier New">&gt;</font></tt><br>
<tt><font face=3D"Courier New">&gt;Signed-Off-By: Enrik Berkhan
&lt;Enrik.Berkhan-JJi787mZWgc@public.gmane.org&gt;</font></tt><br>
<tt><font face=3D"Courier New">&gt;---</font></tt><br>
<tt><font face=3D"Courier New">&gt; drivers/net/smsc911x.c | &nbsp; =
&nbsp;4 ++++</font></tt><br>
<tt><font face=3D"Courier New">&gt; 1 file changed, 4 =
insertions(+)</font></tt><br>
<tt><font face=3D"Courier New">&gt;</font></tt><br>
<tt><font face=3D"Courier New">&gt;Index: =
drivers/net/smsc911x.c</font></tt><br>
<tt><font face=3D"Courier =
New">&gt;=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</font></tt><=
br>
<tt><font face=3D"Courier New">&gt;--- drivers/net/smsc911x.c.orig =
&nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 2008-05-15 =
18:49:30.000000000</font></tt><br>
<tt><font face=3D"Courier New">+0200</font></tt><br>
<tt><font face=3D"Courier New">&gt;+++ drivers/net/smsc911x.c &nbsp; =
&nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 2008-05-15 18:51:28.000000000 =
+0200</font></tt><br>
<tt><font face=3D"Courier New">&gt;@@ -1182,6 +1182,10 @@ static int
smsc911x_open(struct net_devi</font></tt><br>
<tt><font face=3D"Courier New">&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
udelay(10);</font></tt><br>
<tt><font face=3D"Courier New">&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
&nbsp; &nbsp; &nbsp;}</font></tt><br>
<tt><font face=3D"Courier New">&gt;</font></tt><br>
<tt><font face=3D"Courier New">&gt;+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
&nbsp; &nbsp; /* Set MAC again in case it has been set from non-EEPROM =
source</font></tt><br>
<tt><font face=3D"Courier New">&gt;+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
&nbsp; &nbsp; &nbsp;* (config or even bootloader) */</font></tt><br>
<tt><font face=3D"Courier New">&gt;+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
&nbsp; &nbsp; smsc911x_set_mac_address(pdata, =
dev-&gt;dev_addr);</font></tt><br>
<tt><font face=3D"Courier New">&gt;+</font></tt><br>
<tt><font face=3D"Courier New">&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
&nbsp; &nbsp; &nbsp;if (unlikely(timeout =3D=3D 0)) {</font></tt><br>
<tt><font face=3D"Courier New">&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
SMSC_WARNING(&quot;Timed out waiting for EEPROM &quot;</font></tt><br>
<tt><font face=3D"Courier New">&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; =
&nbsp;
&quot;busy bit to clear&quot;);</font></tt><br>
<tt><font face=3D"Courier =
New">&gt;_______________________________________________</font></tt><br>
<tt><font face=3D"Courier New">&gt;Uclinux-dist-devel mailing =
list</font></tt><br>
<tt><font face=3D"Courier =
New">&gt;Uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org</font></tt><br>
<tt><font face=3D"Courier =
New">&gt;http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel<=
/font></tt></span></font><o:p></o:p></p>

</div>

</div>

</body>

</html>

------_=_NextPart_001_01C8B9B2.6732CCAE--

--===============1278347994==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Uclinux-dist-devel mailing list
Uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel
--===============1278347994==--

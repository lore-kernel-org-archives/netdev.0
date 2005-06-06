From: "Abramson, Aharon" <aharon.abramson@intel.com>
Subject: constructing struct sk_buff objects from a pre-allocated buffer
Date: Mon, 6 Jun 2005 14:14:31 +0300
Message-ID: <DEAAFCD4E80C2B4EAD5C63B523AE07ED026FF574@hasmsx402.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C56A88.E972F0D2"
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C56A88.E972F0D2
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello, all.
I'm developing a network device driver. This device may deliver multiple
frames in single pre-allocated receive buffer. How do I construct struct
sk_buff objects for these frames, since alloc_skb allocates the object's
data by itself?
=20
Thanks,
Aharon Abramson
=20

------_=_NextPart_001_01C56A88.E972F0D2
Content-Type: text/html;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.2800.1499" name=3DGENERATOR></HEAD>
<BODY>
<DIV><SPAN class=3D530190011-06062005><FONT face=3DArial size=3D2>Hello, =

all.</FONT></SPAN></DIV>
<DIV><SPAN class=3D530190011-06062005><FONT face=3DArial size=3D2>I'm =
developing a=20
network device driver. This device may deliver multiple frames in single =

pre-allocated receive buffer. How do I construct struct sk_buff objects =
for=20
these frames, since alloc_skb allocates the object's data by=20
itself?</FONT></SPAN></DIV>
<DIV>&nbsp;</DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3D"Script MT Bold" =
color=3D#808000=20
size=3D2><STRONG>Thanks,</STRONG></FONT></DIV>
<DIV dir=3Dltr align=3Dleft><FONT face=3D"Script MT Bold" =
color=3D#808000=20
size=3D2><STRONG>Aharon Abramson</STRONG></FONT></DIV>
<DIV>&nbsp;</DIV></BODY></HTML>

------_=_NextPart_001_01C56A88.E972F0D2--

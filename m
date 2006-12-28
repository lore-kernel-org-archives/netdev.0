From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: one vs. two drivers for an iWARP-capable
 Ethernet NIC
Date: Thu, 28 Dec 2006 16:24:09 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77010FB433@nekter>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="===============1350876625=="
Cc: netdev@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>,
	rdreier@cisco.com
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============1350876625==
Content-class: urn:content-classes:message
Content-Type: multipart/alternative;
 boundary="----_=_NextPart_001_01C72AC6.8549B3C7"
Content-Transfer-Encoding: 7bit

This is a multi-part message in MIME format.

------_=_NextPart_001_01C72AC6.8549B3C7
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: quoted-printable

Jeff/Roland/all,
What is the preferred submission driver model for an iWARP-capable
Ethernet NIC - two separate drivers (Ethernet and OpenFabrics) that
interact with each other, or a single driver that supports both
OpenFabrics and Ethernet interfaces?
For our hardware we can go either way, although in case of separate
drivers the interface between the two would get somewhat artificial...
=20
Thanks, Leonid

------_=_NextPart_001_01C72AC6.8549B3C7
Content-Type: text/html;
 charset=us-ascii
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Dus-ascii">
<META content=3D"MSHTML 6.00.5730.11" name=3DGENERATOR></HEAD>
<BODY>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D328335505-28122006>Jeff/Roland/all,</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D328335505-28122006>What =
is the=20
preferred submission driver model for an iWARP-capable Ethernet NIC =
-&nbsp;two=20
separate drivers (Ethernet and OpenFabrics) that interact with each =
other, or a=20
single driver that supports both&nbsp;OpenFabrics and&nbsp;Ethernet=20
interfaces?</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN class=3D328335505-28122006>For=20
our&nbsp;hardware we can go either way, although in case =
of&nbsp;separate=20
drivers the interface between the two&nbsp;would&nbsp;get&nbsp;somewhat=20
artificial...</SPAN></FONT></DIV>
<DIV><FONT face=3DArial size=3D2><SPAN=20
class=3D328335505-28122006></SPAN></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2><SPAN =
class=3D328335505-28122006>Thanks,=20
Leonid</SPAN></FONT></DIV></BODY></HTML>

------_=_NextPart_001_01C72AC6.8549B3C7--

--===============1350876625==
MIME-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1350876625==--

From: "Joshua Schichtel" <joshua.schichtel@foonet.net>
Subject: sis900 driver problem (redhat kernels)
Date: Wed, 30 Jul 2003 17:44:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000a01c356fc$efb6ae60$6400a8c0@k6m1g2>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0007_01C356C2.42EB58F0"
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0007_01C356C2.42EB58F0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

We have several machines with on board sis900 nic.   Under heavy =
utilization it just quits working.. no traffic passes at all.
To fix it we have to do service network restart (redhat) and it works or =
ifconfig eth0 down and up works.
We tried several redhat 8 kernels 2.4.18, 2.4.20 with various patch =
levels and all have the same problem. =20
Haven't tried 2.4.21 yet but i looked at the source and there isn't   =
any significant changes=20
this is reproducable so i'd be happy to test any patches :-)
If you need any information from the machines themselves let me know and =
i will reply back.

-Joshua Schichtel joshua.schichtel@foonet.net
Creative Internet Techniques
------=_NextPart_000_0007_01C356C2.42EB58F0
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1170" name=3DGENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT face=3DArial size=3D2>We have several machines with on board =
sis900=20
nic.&nbsp;&nbsp; Under heavy utilization it just quits working.. no =
traffic=20
passes at all.<BR>To fix it we have to do service network restart =
(redhat) and=20
it works or ifconfig eth0 down and up works.<BR>We tried several redhat =
8=20
kernels 2.4.18, 2.4.20 with various patch levels and all have the same=20
problem.&nbsp; <BR>Haven't tried 2.4.21 yet but i looked at the source =
and there=20
isn't&nbsp;&nbsp; any significant changes <BR>this is reproducable so =
i'd be=20
happy to test any patches :-)<BR>If you need any information from the =
machines=20
themselves let me know and i will reply back.</FONT></DIV>
<DIV><FONT face=3DArial size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>-Joshua Schichtel <A=20
href=3D"mailto:joshua.schichtel@foonet.net">joshua.schichtel@foonet.net</=
A></FONT></DIV>
<DIV><FONT face=3DArial size=3D2>Creative Internet=20
Techniques</FONT></DIV></BODY></HTML>

------=_NextPart_000_0007_01C356C2.42EB58F0--

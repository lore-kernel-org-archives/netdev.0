From: =?gb2312?q?minnie=20wu?= <minniewkitty@yahoo.com.cn>
Subject: How to improve small packet performance?
Date: Wed, 13 Aug 2003 09:37:52 +0800 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813013752.37510.qmail@web15204.mail.bjs.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-1847026593-1060738672=:36840"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0-1847026593-1060738672=:36840
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id h7D1dDFl021510

Hi, all!
     I tried e100-napi, but it's performance is still worse than eepro100=
-napi. It seems that napi cannot meet my needs. Any ideas?
=20
jchapman wrote:
=20
>Try the latest e100 development driver from sf.net/projects/e1000. Make =
>sure you compile it with NAPI enabled.

>- jc

minnie wu wrote:

> Hi, all!
>      I'm working on e100/eepro100, kernel version 2.4.20. I used NAPI, =
>but  the 64 byte small packet dual throughout is only 28M/s. How to >imp=
rove small  packet performance further?

   =20
   =20



---------------------------------
Do You Yahoo!?
=CA=EE=C6=DA=B4=F3=C6=AC=C6=EB=BE=DB=D1=C5=BB=A2=CD=A8 =CD=F8=C2=E7=C9=E3=
=CF=F1=CD=B7+=D1=C5=BB=A2=CD=A8=B5=F7=C6=B5=CA=D5=D2=F4=BB=FA=B5=C8=C4=E3=
=C0=B4=C4=C3
--0-1847026593-1060738672=:36840
Content-Type: text/html; charset=gb2312
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id h7D1dDFl021510

<DIV>Hi, all!</DIV>
<DIV>&nbsp;&nbsp;&nbsp;&nbsp; I tried e100-napi, but it's performance is =
still worse than eepro100-napi. It seems that napi cannot meet my needs. =
Any ideas?</DIV>
<DIV>&nbsp;</DIV>
<DIV>jchapman wrote:</DIV>
<DIV>&nbsp;</DIV>
<DIV>&gt;Try the latest e100 development driver from sf.net/projects/e100=
0. Make &gt;sure you compile it with NAPI enabled.<BR><BR>&gt;- jc<BR><BR=
>minnie wu wrote:<BR><BR>&gt; Hi, all!<BR>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; I'm working on e100/eepro100, kernel version 2.4.20. I used NAPI, &gt=
;but&nbsp; the 64 byte&nbsp;small packet dual throughout is only 28M/s. H=
ow to &gt;improve small&nbsp; packet performance further?<BR><BR>&nbsp;&n=
bsp;&nbsp; </DIV>
<DIV>&nbsp;&nbsp;&nbsp; </DIV><p><br><hr size=3D1><b>Do You Yahoo!?</b><b=
r>
<a href=3D"http://cn.rd.yahoo.com/mail_cn/tag/?http://cn.promo.yahoo.com/=
minisite/messenger1/" target=3Dblank>=CA=EE=C6=DA=B4=F3=C6=AC=C6=EB=BE=DB=
=D1=C5=BB=A2=CD=A8 =CD=F8=C2=E7=C9=E3=CF=F1=CD=B7+=D1=C5=BB=A2=CD=A8=B5=F7=
=C6=B5=CA=D5=D2=F4=BB=FA=B5=C8=C4=E3=C0=B4=C4=C3</a>
--0-1847026593-1060738672=:36840--

From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6inetNetToMediaTable
Date: Thu, 15 Jan 2004 10:18:44 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFE052816E.2064C677-ON88256E1C.0063EDA2@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE48FDFF06B328f9e8a93df938690918c07BBE48FDFF06B32"
Cc: mashirle@us.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE48FDFF06B328f9e8a93df938690918c07BBE48FDFF06B32
Content-type: text/plain; charset=ISO-2022-JP
Content-transfer-encoding: quoted-printable






Thanks. This is a bug fix for the update value (last change) to be a
TimeStamp according to new IP MIBs. There is no confirm value in the ne=
w IP
MIBs inetNetTomedia Entry, I don't know what's the confirm for, I still=

keep it, but change it to TimeStamp. Is there any application using the=
se
values right now? If you agree we can fix any applications reference th=
ese
values.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B
<yoshfuji@linux-ipv6.org>@cerberus.hongo.wide.ad.jp> on 01/15/2004 01:0=
4:11
AM

Sent by:    "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>


To:    mashirle@us.ltcfwd.linux.ibm.com
cc:    davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Shir=
ley
       Ma/Beaverton/IBM@IBMUS
Subject:    Re: [PATCH] IPv6 MIB:ipv6inetNetToMediaTable


In article <200401141621.26317.mashirle@us.ibm.com> (at Wed, 14 Jan 200=
4
16:21:26 -0800), Shirley Ma <mashirle@us.ibm.com> says:

> This patch is against 2.6.1 kernel.

Wrong. Do not change interface.

--yoshfuji

=

--0__=07BBE48FDFF06B328f9e8a93df938690918c07BBE48FDFF06B32
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Thanks. This is a bug fix for the update value (last change) to be a=
 TimeStamp according to new IP MIBs. There is no confirm value in the n=
ew IP MIBs inetNetTomedia Entry, I don't know what's the confirm for, I=
 still keep it, but change it to TimeStamp. Is there any application us=
ing these values right now? If you agree we can fix any applications re=
ference these values. <br>
<br>
Thanks<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone: (503) 578-7638<br>
FAX:      (503) 578-3228<br>
<br>
<br>

<p><font size=3D"2" color=3D"#800080">Sent by:	&quot;Hideaki YOSHIFUJI&=
quot; &lt;yoshfuji@cerberus.hongo.wide.ad.jp&gt;</font>
<p><font size=3D"2" color=3D"#800080">To:	</font><font size=3D"2">mashi=
rle@us.ltcfwd.linux.ibm.com</font><br>
<font size=3D"2" color=3D"#800080">cc:	</font><font size=3D"2">davem@re=
dhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, Shirley Ma/Beaverto=
n/IBM@IBMUS</font><font size=3D"2" color=3D"#800080"> </font><br>
<font size=3D"2" color=3D"#800080">Subject:	</font><font size=3D"2">Re:=
 [PATCH] IPv6 MIB:ipv6inetNetToMediaTable</font><br>
<br>
<br>
<font face=3D"Courier New">In article &lt;200401141621.26317.mashirle@u=
s.ibm.com&gt; (at Wed, 14 Jan 2004 16:21:26 -0800), Shirley Ma &lt;mash=
irle@us.ibm.com&gt; says:<br>
<br>
&gt; This patch is against 2.6.1 kernel.<br>
<br>
Wrong. Do not change interface.<br>
<br>
--yoshfuji<br>
</font><br>
<br>
</body></html>=

--0__=07BBE48FDFF06B328f9e8a93df938690918c07BBE48FDFF06B32--

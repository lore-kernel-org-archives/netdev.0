From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Thu, 15 Jan 2004 11:30:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF6C177E72.62FA8BF9-ON87256E1C.006A8953@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE48FDFF90FC38f9e8a93df938690918c08BBE48FDFF90FC3"
Cc: mashirle@us.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE48FDFF90FC38f9e8a93df938690918c08BBE48FDFF90FC3
Content-type: text/plain; charset=ISO-2022-JP
Content-transfer-encoding: quoted-printable






Hi, Yoshifuji,

This rule would mean that any new kernel development *could* break
something somewhere else? ;-)

I don't see any application uses these values for now, so I change them=
.
It's good for kernel to provide the real MIBs information. If later on,=

some applications start to use these values, they can get the correct
numbers without converting. Unless you can give me an broken example. :=
-)

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



YOSHIFUJI Hideaki / =1B$B5HF#1QL@=1B(B
<yoshfuji@linux-ipv6.org>@cerberus.hongo.wide.ad.jp> on 01/15/2004 11:1=
9:50
AM

Sent by:    "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>


To:    Shirley Ma/Beaverton/IBM@IBMUS
cc:    mashirle@us.ltcfwd.linux.ibm.com, davem@redhat.com,
       kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.or=
g
Subject:    Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable


In article <OFC6D64AE0.CEE7DA5F-ON87256E1C.0068A56A@us.ibm.com> (at Thu=
, 15
Jan 2004 11:09:47 -0800), Shirley Ma <xma@us.ibm.com> says:

> But if no applications use this value, and nothing is boken. It's not=

> harmful to change the kernel to provide MIBs in as-is format.

Shirley, nobody can prove that nothing will be broken. :-)

--yoshfuji

=

--0__=08BBE48FDFF90FC38f9e8a93df938690918c08BBE48FDFF90FC3
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline
Content-transfer-encoding: quoted-printable

<html><body>
<p>Hi, Yoshifuji,<br>
<br>
This rule would mean that any new kernel development *could* break some=
thing somewhere else? ;-) <br>
<br>
I don't see any application uses these values for now, so I change them=
. It's good for kernel to provide the real MIBs information. If later o=
n, some applications start to use these values, they can get the correc=
t numbers without converting. Unless you can give me an broken example.=
 :-)<br>
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
<p><font size=3D"2" color=3D"#800080">To:	</font><font size=3D"2">Shirl=
ey Ma/Beaverton/IBM@IBMUS</font><br>
<font size=3D"2" color=3D"#800080">cc:	</font><font size=3D"2">mashirle=
@us.ltcfwd.linux.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru, netde=
v@oss.sgi.com, yoshfuji@linux-ipv6.org</font><font size=3D"2" color=3D"=
#800080"> </font><br>
<font size=3D"2" color=3D"#800080">Subject:	</font><font size=3D"2">Re:=
 [PATCH] IPv6 MIB:ipv6DefaultRouterTable</font><br>
<br>
<br>
<font face=3D"Courier New">In article &lt;OFC6D64AE0.CEE7DA5F-ON87256E1=
C.0068A56A@us.ibm.com&gt; (at Thu, 15 Jan 2004 11:09:47 -0800), Shirley=
 Ma &lt;xma@us.ibm.com&gt; says:<br>
<br>
&gt; But if no applications use this value, and nothing is boken. It's =
not<br>
&gt; harmful to change the kernel to provide MIBs in as-is format.<br>
<br>
Shirley, nobody can prove that nothing will be broken. :-)<br>
<br>
--yoshfuji<br>
</font><br>
<br>
</body></html>=

--0__=08BBE48FDFF90FC38f9e8a93df938690918c08BBE48FDFF90FC3--

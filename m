From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Thu, 15 Jan 2004 11:09:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFC6D64AE0.CEE7DA5F-ON87256E1C.0068A56A@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE48FDFFB23FA8f9e8a93df938690918c08BBE48FDFFB23FA"
Cc: mashirle@us.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE48FDFFB23FA8f9e8a93df938690918c08BBE48FDFFB23FA
Content-type: text/plain; charset=ISO-2022-JP





Agree.

But if no applications use this value, and nothing is boken. It's not
harmful to change the kernel to provide MIBs in as-is format.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



YOSHIFUJI Hideaki / 吉藤英明
<yoshfuji@linux-ipv6.org>@cerberus.hongo.wide.ad.jp> on 01/15/2004 10:36:22
AM

Sent by:    "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>


To:    Shirley Ma/Beaverton/IBM@IBMUS
cc:    mashirle@us.ltcfwd.linux.ibm.com, davem@redhat.com,
       kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Subject:    Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable


In article <OF87A9D639.F6A8D26B-ON88256E1C.0064AD99@us.ibm.com> (at Thu, 15
Jan 2004 10:26:21 -0800), Shirley Ma <xma@us.ibm.com> says:

> This is a bug fix for ipDefaultRouter Table. According to the new IP
MIBs,
> the DefaultRouterLifeTime(expire) entry in this table is unsigned 32. It
> measures the remaining length of time in seconds. If it's expire, the
value
> should be 0.

Kernel does not have to provide MIB in as-is format.

--yoshfuji


--0__=08BBE48FDFFB23FA8f9e8a93df938690918c08BBE48FDFFB23FA
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline

<html><body>
<p>Agree. <br>
<br>
But if no applications use this value, and nothing is boken. It's not harmful to change the kernel to provide MIBs in as-is format. <br>
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

<p><font size="2" color="#800080">Sent by:	&quot;Hideaki YOSHIFUJI&quot; &lt;yoshfuji@cerberus.hongo.wide.ad.jp&gt;</font>
<p><font size="2" color="#800080">To:	</font><font size="2">Shirley Ma/Beaverton/IBM@IBMUS</font><br>
<font size="2" color="#800080">cc:	</font><font size="2">mashirle@us.ltcfwd.linux.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org</font><font size="2" color="#800080"> </font><br>
<font size="2" color="#800080">Subject:	</font><font size="2">Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable</font><br>
<br>
<br>
<font face="Courier New">In article &lt;OF87A9D639.F6A8D26B-ON88256E1C.0064AD99@us.ibm.com&gt; (at Thu, 15 Jan 2004 10:26:21 -0800), Shirley Ma &lt;xma@us.ibm.com&gt; says:<br>
<br>
&gt; This is a bug fix for ipDefaultRouter Table. According to the new IP MIBs,<br>
&gt; the DefaultRouterLifeTime(expire) entry in this table is unsigned 32. It<br>
&gt; measures the remaining length of time in seconds. If it's expire, the value<br>
&gt; should be 0.<br>
<br>
Kernel does not have to provide MIB in as-is format.<br>
<br>
--yoshfuji<br>
</font><br>
<br>
</body></html>
--0__=08BBE48FDFFB23FA8f9e8a93df938690918c08BBE48FDFFB23FA--

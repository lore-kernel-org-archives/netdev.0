From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6inetNetToMediaTable
Date: Thu, 15 Jan 2004 11:13:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF557FE48C.1C982CED-ON87256E1C.006976E9@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE48FDFFAF0798f9e8a93df938690918c08BBE48FDFFAF079"
Cc: mashirle@us.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE48FDFFAF0798f9e8a93df938690918c08BBE48FDFFAF079
Content-type: text/plain; charset=ISO-2022-JP





Why shouldn't the kernel provide the real MIBs information? Is it breaking
any application if I make the right changes?

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



YOSHIFUJI Hideaki / 吉藤英明
<yoshfuji@linux-ipv6.org>@cerberus.hongo.wide.ad.jp> on 01/15/2004 10:41:18
AM

Sent by:    "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>


To:    Shirley Ma/Beaverton/IBM@IBMUS
cc:    mashirle@us.ltcfwd.linux.ibm.com, davem@redhat.com,
       kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Subject:    Re: [PATCH] IPv6 MIB:ipv6inetNetToMediaTable


In article <OFE052816E.2064C677-ON88256E1C.0063EDA2@us.ibm.com> (at Thu, 15
Jan 2004 10:18:44 -0800), Shirley Ma <xma@us.ibm.com> says:

> Thanks. This is a bug fix for the update value (last change) to be a
> TimeStamp according to new IP MIBs. There is no confirm value in the new
IP
> MIBs inetNetTomedia Entry, I don't know what's the confirm for, I still
> keep it, but change it to TimeStamp. Is there any application using these
> values right now? If you agree we can fix any applications reference
these
> values.

ditto. application should obtain real MIB information using
information provided by kernel.
(If information is not enough, let kernel provide additional
information.)

--yoshfuji


--0__=08BBE48FDFFAF0798f9e8a93df938690918c08BBE48FDFFAF079
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline

<html><body>
<p>Why shouldn't the kernel provide the real MIBs information? Is it breaking any application if I make the right changes?<br>
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
<font size="2" color="#800080">Subject:	</font><font size="2">Re: [PATCH] IPv6 MIB:ipv6inetNetToMediaTable</font><br>
<br>
<br>
<font face="Courier New">In article &lt;OFE052816E.2064C677-ON88256E1C.0063EDA2@us.ibm.com&gt; (at Thu, 15 Jan 2004 10:18:44 -0800), Shirley Ma &lt;xma@us.ibm.com&gt; says:<br>
<br>
&gt; Thanks. This is a bug fix for the update value (last change) to be a<br>
&gt; TimeStamp according to new IP MIBs. There is no confirm value in the new IP<br>
&gt; MIBs inetNetTomedia Entry, I don't know what's the confirm for, I still<br>
&gt; keep it, but change it to TimeStamp. Is there any application using these<br>
&gt; values right now? If you agree we can fix any applications reference these<br>
&gt; values.<br>
<br>
ditto. application should obtain real MIB information using<br>
information provided by kernel.<br>
(If information is not enough, let kernel provide additional <br>
information.)<br>
<br>
--yoshfuji<br>
</font><br>
<br>
</body></html>
--0__=08BBE48FDFFAF0798f9e8a93df938690918c08BBE48FDFFAF079--

From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Thu, 15 Jan 2004 11:59:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF0184DFA4.569DFD66-ON87256E1C.006DBAE8@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE48FDFFE3C788f9e8a93df938690918c08BBE48FDFFE3C78"
Cc: davem@redhat.com, mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE48FDFFE3C788f9e8a93df938690918c08BBE48FDFFE3C78
Content-type: text/plain; charset=ISO-2022-JP





OK, I agree with both of you. Then this patch is not needed. Yoshifuji, you
can sleep in peace. ;-)

Thank you all!
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>@oss.sgi.com on
01/15/2004 11:53:41 AM

Sent by:    netdev-bounce@oss.sgi.com


To:    davem@redhat.com
cc:    Shirley Ma/Beaverton/IBM@IBMUS, mashirle@us.ltcfwd.linux.ibm.com,
       kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Subject:    Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable


In article <20040115113840.4b7eb5d8.davem@redhat.com> (at Thu, 15 Jan 2004
11:38:40 -0800), "David S. Miller" <davem@redhat.com> says:

> We can create new files to present information in new ways and formats,
> but I totally prefer using netlink based information gathering over
making
> new procfs files.

Although this discussion is about rtnetlink message,
problem will be solved if we provide jiffies for neigbours
IMHO.

--yoshfuji @ let me sleep...



--0__=08BBE48FDFFE3C788f9e8a93df938690918c08BBE48FDFFE3C78
Content-type: text/html; charset=ISO-2022-JP
Content-Disposition: inline

<html><body>
<p>OK, I agree with both of you. Then this patch is not needed. Yoshifuji, you can sleep in peace. ;-)<br>
<br>
Thank you all!<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone: (503) 578-7638<br>
FAX:      (503) 578-3228<br>
<br>
<br>

<p><font size="2" color="#800080">Sent by:	netdev-bounce@oss.sgi.com</font>
<p><font size="2" color="#800080">To:	</font><font size="2">davem@redhat.com</font><br>
<font size="2" color="#800080">cc:	</font><font size="2">Shirley Ma/Beaverton/IBM@IBMUS, mashirle@us.ltcfwd.linux.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org</font><font size="2" color="#800080"> </font><br>
<font size="2" color="#800080">Subject:	</font><font size="2">Re: [PATCH] IPv6 MIB:ipv6DefaultRouterTable</font><br>
<br>
<br>
<font face="Courier New">In article &lt;20040115113840.4b7eb5d8.davem@redhat.com&gt; (at Thu, 15 Jan 2004 11:38:40 -0800), &quot;David S. Miller&quot; &lt;davem@redhat.com&gt; says:<br>
<br>
&gt; We can create new files to present information in new ways and formats,<br>
&gt; but I totally prefer using netlink based information gathering over making<br>
&gt; new procfs files.<br>
<br>
Although this discussion is about rtnetlink message,<br>
problem will be solved if we provide jiffies for neigbours <br>
IMHO.<br>
<br>
--yoshfuji @ let me sleep...<br>
<br>
</font><br>
<br>
</body></html>
--0__=08BBE48FDFFE3C788f9e8a93df938690918c08BBE48FDFFE3C78--

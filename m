From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPV6: note on shared socket options
Date: Wed, 4 Feb 2004 21:02:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFABB4DC54.4883B0FD-ON87256E31.0015A354-88256E31.0015F150@us.ibm.com>
References: <20040205.110955.10680487.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE4A2DF8625C48f9e8a93df938690918c08BBE4A2DF8625C4"
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040205.110955.10680487.yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE4A2DF8625C48f9e8a93df938690918c08BBE4A2DF8625C4
Content-type: text/plain; charset=US-ASCII





I see what you mean now; I agree. I'm not sure all of the other
socket options for each of v4 and v6 appear in a single file,
either; they definitely aren't all grouped so you can tell they come
from the same numeric namespace. So, picking new numbers
requires some detective work, but every little bit helps. :-)

                        +-DLS
--0__=08BBE4A2DF8625C48f9e8a93df938690918c08BBE4A2DF8625C4
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>I see what you mean now; I agree. I'm not sure all of the other<br>
socket options for each of v4 and v6 appear in a single file,<br>
either; they definitely aren't all grouped so you can tell they come<br>
from the same numeric namespace. So, picking new numbers<br>
requires some detective work, but every little bit helps. :-)<br>
<br>
				+-DLS<br>
</body></html>
--0__=08BBE4A2DF8625C48f9e8a93df938690918c08BBE4A2DF8625C4--

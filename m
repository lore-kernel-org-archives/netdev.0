From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 MIB:ipv6RouterAdvert netlink notification
Date: Sat, 17 Jan 2004 04:17:25 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040117.041725.120019170.yoshfuji@linux-ipv6.org>
References: <OFDFE3736C.20FD7F98-ON87256E1D.00662F80@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, mashirle@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: xma@us.ibm.com
In-Reply-To: <OFDFE3736C.20FD7F98-ON87256E1D.00662F80@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFDFE3736C.20FD7F98-ON87256E1D.00662F80@us.ibm.com> (at Fri, 16 Jan 2004 10:38:49 -0800), Shirley Ma <xma@us.ibm.com> says:

> But the patch is still needed for the Router, so it should be put in
> ndisc_router_discovery() when it's determined as a router. Are you OK with
> that?

I don't understand why it is needed.
radvd is respoinsible for those information.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

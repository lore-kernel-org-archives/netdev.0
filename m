From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: connecting ipv6 nodes throu' ipv4 network ....
Date: Thu, 20 Feb 2003 20:53:03 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030220.205303.112795862.yoshfuji@linux-ipv6.org>
References: <20030220114636.21895.qmail@webmail29.rediffmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ipv6_san@rediffmail.com
In-Reply-To: <20030220114636.21895.qmail@webmail29.rediffmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030220114636.21895.qmail@webmail29.rediffmail.com> (at 20 Feb 2003 11:46:36 -0000), "santosh kumar gowda" <ipv6_san@rediffmail.com> says:

> 8: epmac1: <BROADCAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
>     inet6 3ffe:1234::2/128 scope global
:
>     inet6 3ffe:1234::1/128 scope global

use /64 instead.

--yoshfuji

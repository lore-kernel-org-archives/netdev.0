From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
Subject: Re: Neighbor cache
Date: Fri, 03 May 2002 09:54:02 +0900
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020503095402W.yoshfuji@wide.ad.jp>
References: <Mutt.LNX.4.44.0204250152190.11349-100000@blackbird.intercode.com.au>
	<000001c1f22c$4a894f00$4e6015ac@VAIO>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: xiaoning@docomolabs-usa.com
In-Reply-To: <000001c1f22c$4a894f00$4e6015ac@VAIO>
List-Id: netdev.vger.kernel.org

In article <000001c1f22c$4a894f00$4e6015ac@VAIO> (at Thu, 2 May 2002 15:54:16 -0700), "Xiaoning He" <xiaoning@docomolabs-usa.com> says:

> 
> Could you please let me know in the IPv6 kernel, where the Neighbor
> cache is maintained and which file contains them?

net/core/neighbour.c

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

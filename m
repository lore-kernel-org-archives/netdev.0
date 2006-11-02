From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 0/6] IPv6: IPv6 tunnel fixes
Date: Thu, 02 Nov 2006 22:01:07 +0900 (JST)
Message-ID: <20061102.220107.119433076.yoshfuji@linux-ipv6.org>
References: <4549D609.8060202@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:2315 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1752132AbWKBM6T
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 07:58:19 -0500
To: vnuorval@tcs.hut.fi
In-Reply-To: <4549D609.8060202@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4549D609.8060202@tcs.hut.fi> (at Thu, 02 Nov 2006 13:27:05 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> the following incremental patches contain several fixes to ip6_tunnel.c.
> They are in chronological order, so the most critical one is
> unfortunately last. Many thanks to Tero Kauppinen for reporting that one!

I ack all patches except for the last one.

Note: they are in the branch of
        git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix/

--yoshfuji

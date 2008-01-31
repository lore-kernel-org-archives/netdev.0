From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 6/6][NETNS]: Udp sockets per-net lookup.
Date: Fri, 01 Feb 2008 00:40:07 +1100 (EST)
Message-ID: <20080201.004007.110177979.yoshfuji@linux-ipv6.org>
References: <47A1C216.9000303@openvz.org>
	<20080201.001138.95019632.yoshfuji@wide.ad.jp>
	<20080131.052007.165146562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:39727 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724AbYAaNjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:39:40 -0500
In-Reply-To: <20080131.052007.165146562.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080131.052007.165146562.davem@davemloft.net> (at Thu, 31 Jan 2008 05:20:07 -0800 (PST)), David Miller <davem@davemloft.net> says:

> The networking devices are even per-namespace already,
> so you can even say that each namespace is even
> physically different.

Ah, okay, we are splitting "weak" domains...

--yoshfuji

From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/6] IPv6: Fix SIOCCHGTUNNEL bug in IPv6 tunnels
Date: Thu, 02 Nov 2006 22:02:32 +0900 (JST)
Message-ID: <20061102.220232.18232409.yoshfuji@linux-ipv6.org>
References: <4549D69B.20903@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:3595 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1752190AbWKBM7n
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 07:59:43 -0500
To: vnuorval@tcs.hut.fi
In-Reply-To: <4549D69B.20903@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4549D69B.20903@tcs.hut.fi> (at Thu, 02 Nov 2006 13:29:31 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> >From f9812eb0349f44f6374910ce38524f0c6f7ce8f4 Mon Sep 17 00:00:00 2001
> From: Ville Nuorvala <vnuorval@tcs.hut.fi>
> Date: Thu, 2 Nov 2006 12:40:38 +0200
> Subject: [PATCH 1/6] IPv6: Fix SIOCCHGTUNNEL bug in IPv6 tunnels
> 
> A logic bug in tunnel lookup could result in duplicate tunnels
> when changing an existing device.
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji

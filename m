From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6 mcast: Do not join device multicast for
 interface-local multicasts.
Date: Mon, 11 Feb 2013 00:22:34 -0500 (EST)
Message-ID: <20130211.002234.826976152851108644.davem@davemloft.net>
References: <51165D66.5090200@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717Ab3BKFWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 00:22:45 -0500
In-Reply-To: <51165D66.5090200@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sat, 09 Feb 2013 23:29:58 +0900

> RFC4291 (IPv6 addressing architecture) says that interface-Local scope
> spans only a single interface on a node.  We should not join L2 device
> multicast list for addresses in interface-local (or smaller) scope.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.

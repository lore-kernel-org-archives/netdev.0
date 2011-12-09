From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/13] Implement dumping udp sockets via sock_diag
 netlink
Date: Fri, 09 Dec 2011 14:19:28 -0500 (EST)
Message-ID: <20111209.141928.36764342375636543.davem@davemloft.net>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44677 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab1LITTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 14:19:33 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 09 Dec 2011 20:20:49 +0400

> This is an extension of inet_diag module and the new udp_diag one. Plus
> the patch for iproute's ss to dump udp sockets via netlink (applies on top
> of previous patch for new NETLINK_SOCK_DIAG API [1]).

I like it :-)  All applied, thanks!

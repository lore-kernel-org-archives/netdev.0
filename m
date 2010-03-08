From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6] netfilter: Remove stale declaration for ip6_masked_addrcmp().
Date: Mon, 08 Mar 2010 13:17:50 +0100
Message-ID: <4B94EAEE.1040906@trash.net>
References: <201003070918.o279IfCk029612@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45717 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861Ab0CHMRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 07:17:51 -0500
In-Reply-To: <201003070918.o279IfCk029612@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki wrote:
> Commit f2ffd9ee... ("[NETFILTER]: Move ip6_masked_addrcmp to
> include/net/ipv6.h") replaced ip6_masked_addrcmp() with
> ipv6_masked_addr_cmp().  Function definition went away.
> 
> Let's remove its declaration as well in header file.

Applied, thanks.

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] br_netfilter: use skb_set_noref()
Date: Tue, 01 Jun 2010 11:56:14 +0200
Message-ID: <4C04D93E.7050905@trash.net>
References: <1275340993.2478.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44799 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718Ab0FAJ4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 05:56:16 -0400
In-Reply-To: <1275340993.2478.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Avoid dirtying bridge_parent_rtable refcount, using new dst noref
> infrastructure.

Applied, thanks Eric.

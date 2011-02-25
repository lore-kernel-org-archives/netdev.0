From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sch_choke: add choke_skb_cb
Date: Thu, 24 Feb 2011 22:14:43 -0800 (PST)
Message-ID: <20110224.221443.193711743.davem@davemloft.net>
References: <1298605541.2659.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57637
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752024Ab1BYGOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 01:14:07 -0500
In-Reply-To: <1298605541.2659.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 25 Feb 2011 04:45:41 +0100

> Better document choke skb->cb[] use, like we did in netem and sfb
> 
> This adds a compile time check to make sure we dont exhaust skb->cb[]
> space.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Patrick McHardy <kaber@trash.net>

Applied.

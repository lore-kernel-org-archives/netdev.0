From: David Miller <davem@davemloft.net>
Subject: Re: net_device leak after "bridge: allow creating bridge devices
 with netlink"?
Date: Mon, 22 Aug 2011 16:48:02 -0700 (PDT)
Message-ID: <20110822.164802.1342475338744097238.davem@davemloft.net>
References: <1314017401.2307.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110822085532.2ff4479c@nehalam.ftrdhcpuser.net>
	<1314029159.2307.99.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, JBeulich@novell.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814Ab1HVXsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 19:48:06 -0400
In-Reply-To: <1314029159.2307.99.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Aug 2011 18:05:59 +0200

> [PATCH] bridge: fix a possible net_device leak
> 
> Jan Beulich reported a possible net_device leak in bridge code after
> commit bb900b27a2f4 (bridge: allow creating bridge devices with netlink)
> 
> Reported-by: Jan Beulich <JBeulich@novell.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Eric.

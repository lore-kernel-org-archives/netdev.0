From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bridge: depends on INET
Date: Thu, 04 Mar 2010 00:42:47 -0800 (PST)
Message-ID: <20100304.004247.10224846.davem@davemloft.net>
References: <4B8D4607.8070603@xenotime.net>
	<20100303.012359.66790294.davem@davemloft.net>
	<20100304031847.GA22683@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36200
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754583Ab0CDIm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:42:28 -0500
In-Reply-To: <20100304031847.GA22683@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 4 Mar 2010 04:18:47 +0100

> I suspect Randy went by the MAINTAINERS entry - you might want to add netdev 
> as a second 'L:' line:
> 
>  ETHERNET BRIDGE
>  M:      Stephen Hemminger <shemminger@linux-foundation.org>
>  L:      bridge@lists.linux-foundation.org
>  W:      http://www.linux-foundation.org/en/Net:Bridge
>  S:      Maintained
>  F:      include/linux/netfilter_bridge/
>  F:      net/bridge/
> 
> To make it really clear that netdev must be Cc:-ed for those patches.

Thanks for pointing that out, I've made this addition.

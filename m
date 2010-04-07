From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Tue, 06 Apr 2010 19:52:04 -0700 (PDT)
Message-ID: <20100406.195204.165441511.davem@davemloft.net>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
	<1270502993.9013.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.linn@xilinx.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, grant.likely@secretlab.ca,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	michal.simek@petalogix.com, jtyner@cs.ucr.edu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47036
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752478Ab0DGCwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 22:52:01 -0400
In-Reply-To: <1270502993.9013.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Apr 2010 23:29:53 +0200

> So, I ask, cant you use netdev_alloc_skb_ip_align() in this driver ?

Thanks to everyone for getting this patch into shape.

I applied version 4 of the patch to net-next-2.6, thanks!

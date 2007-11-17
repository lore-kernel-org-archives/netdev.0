From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] CAN: New PF_CAN protocol family for 2.6.25, update
Date: Fri, 16 Nov 2007 16:10:23 -0800 (PST)
Message-ID: <20071116.161023.03295712.davem@davemloft.net>
References: <20071116150245.28784.0@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net,
	shemminger@linux-foundation.org, joe@perches.com, sam@ravnborg.org,
	tglx@linutronix.de, oliver@hartkopp.net
To: urs.thuermann@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53755
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756531AbXKQAK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 19:10:29 -0500
In-Reply-To: <20071116150245.28784.0@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Urs Thuermann <urs.thuermann@gmx.de>
Date: Fri, 16 Nov 2007 16:02:45 +0100

> this patch series adds the PF_CAN protocol family for the
> Controller Area Network.  Since our last post we have changed:
> 
> * Remove vcan_open() and vcan_stop().
> * return NETDEV_TX_OK instead of 0.
> * Add can_ prefix to some global vars.
> * Remove all debug code completely.
> * Cleanup of timer code.
> 
> This patch series applies against net-2.6.25 and is derived from Subversion
> revision r560 of http://svn.berlios.de/svnroot/repos/socketcan.
> It can be found in the directory
> http://svn.berlios.de/svnroot/repos/socketcan/trunk/patch-series/<version>.

I've applied all 7 patches to net-2.6.25, thanks a lot!

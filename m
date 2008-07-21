From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 13:32:02 -0700 (PDT)
Message-ID: <20080721.133202.32461331.davem@davemloft.net>
References: <20080720.104411.81744468.davem@davemloft.net>
	<20080720105941.77061d6a@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37456
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750733AbYGUUcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:32:02 -0400
In-Reply-To: <20080720105941.77061d6a@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Sun, 20 Jul 2008 10:59:41 -0700

> net: Print the module name as part of the watchdog message
> 
> As suggested by Dave:
> 
> This patch adds a function to get the driver name from a struct net_device,
> and consequently uses this in the watchdog timeout handler to print as 
> part of the message. 
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

Applied, thanks ARjan.

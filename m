From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] etherdevice.h: Add is_unicast_ether_addr
 function
Date: Thu, 13 Jan 2011 12:35:38 -0800 (PST)
Message-ID: <20110113.123538.21305451.davem@davemloft.net>
References: <1294907081.4114.35.camel@Joe-Laptop>
	<1294908916.3570.21.camel@edumazet-laptop>
	<4D2F2A92.7020909@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, joe@perches.com, tklauser@distanz.ch,
	netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42668
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933541Ab1AMUfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 15:35:05 -0500
In-Reply-To: <4D2F2A92.7020909@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Thu, 13 Jan 2011 11:38:42 -0500

> So, I like Tobias' reworked patches.  I can take them into the Tilera tree,
> but I'd prefer David Miller take them into the net tree if he is agreeable,
> since it now includes changes to generic networking code.  If you take the
> latter approach you can include my:

I'll take them into my networking tree, which is where all network
device changes ought to go in the first place.

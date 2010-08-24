From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bcm63xx_enet: use netdev stats
Date: Tue, 24 Aug 2010 12:24:13 -0700 (PDT)
Message-ID: <20100824.122413.183031870.davem@davemloft.net>
References: <1282665195.2477.261.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mbizon@freebox.fr, ffainelli@freebox.fr
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42628
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752937Ab0HXTXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 15:23:55 -0400
In-Reply-To: <1282665195.2477.261.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Aug 2010 17:53:15 +0200

> Use integrated net_device stats instead of a private one
> 
> Get rid of bcm_enet_get_stats()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: Setting RSS hash result to skb->rxhash field
Date: Thu, 05 May 2011 10:34:05 -0700 (PDT)
Message-ID: <20110505.103405.193731328.davem@davemloft.net>
References: <1304527586.32152.5.camel@edumazet-laptop>
	<953B660C027164448AE903364AC447D2070B8E35@mtldag01.mtl.com>
	<1304578518.32152.794.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37747
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755327Ab1EEReh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 13:34:37 -0400
In-Reply-To: <1304578518.32152.794.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 May 2011 08:55:18 +0200

> Really, we better use the linux/software full 32bit rxhash in this case,
> and wait for your 32bit full support.

Agreed.

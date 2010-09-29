From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] dummy: percpu stats and lockless xmit
Date: Wed, 29 Sep 2010 13:26:41 -0700 (PDT)
Message-ID: <20100929.132641.102556696.davem@davemloft.net>
References: <1285656633.10438.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34956
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754054Ab0I2U0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 16:26:21 -0400
In-Reply-To: <1285656633.10438.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Sep 2010 08:50:33 +0200

> Converts dummy network device driver to :
> 
> - percpu stats
> 
> - 64bit stats
> 
> - lockless xmit (NETIF_F_LLTX)
> 
> - performance features added (NETIF_F_SG | NETIF_F_FRAGLIST |
> NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

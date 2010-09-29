From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipip: enable lockless xmits
Date: Wed, 29 Sep 2010 13:27:04 -0700 (PDT)
Message-ID: <20100929.132704.245407933.davem@davemloft.net>
References: <1285669037.3154.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34964
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754906Ab0I2U0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 16:26:43 -0400
In-Reply-To: <1285669037.3154.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 28 Sep 2010 12:17:17 +0200

> IPIP tunnels can benefit from lockless xmits, using NETIF_F_LLTX
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

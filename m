From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_gre: comments change
Date: Wed, 29 Sep 2010 23:35:20 -0700 (PDT)
Message-ID: <20100929.233520.58441474.davem@davemloft.net>
References: <1285824777.5211.663.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54881
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753937Ab0I3GfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 02:35:04 -0400
In-Reply-To: <1285824777.5211.663.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Sep 2010 07:32:57 +0200

> HARD_TX_LOCK no longer protects tunnels from dead loops,
> but xmit_recursion percpu counter.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, t hanks Eric.

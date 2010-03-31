From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove redundant code
Date: Tue, 30 Mar 2010 23:58:46 -0700 (PDT)
Message-ID: <20100330.235846.143694378.davem@davemloft.net>
References: <1269961335.2012.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45772
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755790Ab0CaG6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:58:45 -0400
In-Reply-To: <1269961335.2012.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Mar 2010 17:02:15 +0200

> eth_type_trans(skb, netdev) does the "skb->dev = netdev;"
> initialization, we can remove it from various network drivers.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.

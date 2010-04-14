From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] drivers: net: use skb_headlen()
Date: Wed, 14 Apr 2010 15:59:49 -0700 (PDT)
Message-ID: <20100414.155949.210580528.davem@davemloft.net>
References: <1271191700.16881.574.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755166Ab0DNW7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 18:59:45 -0400
In-Reply-To: <1271191700.16881.574.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Apr 2010 22:48:20 +0200

> replaces (skb->len - skb->data_len) occurrences by skb_headlen(skb)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.

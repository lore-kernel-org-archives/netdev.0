From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 4/4] vlan: 64 bit rx counters
Date: Mon, 28 Jun 2010 23:37:50 -0700 (PDT)
Message-ID: <20100628.233750.233693756.davem@davemloft.net>
References: <1277376906.2816.287.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37648
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752213Ab0F2Ghh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:37:37 -0400
In-Reply-To: <1277376906.2816.287.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Jun 2010 12:55:06 +0200

> Use u64_stats_sync infrastructure to implement 64bit rx stats.
> 
> (tx stats are addressed later)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: u64_stats_sync improvements
Date: Mon, 28 Jun 2010 23:37:23 -0700 (PDT)
Message-ID: <20100628.233723.116379982.davem@davemloft.net>
References: <1277373878.2816.177.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38323
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752332Ab0F2GhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:37:10 -0400
In-Reply-To: <1277373878.2816.177.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Jun 2010 12:04:38 +0200

> - Add a comment about interrupts:
> 
> 6) If counter might be written by an interrupt, readers should block
> interrupts.
> 
> - Fix a typo in sample of use.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

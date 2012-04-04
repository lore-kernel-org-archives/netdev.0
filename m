From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: lpc_eth: no need to reserve 8 extra bytes in rx
 skb
Date: Wed, 04 Apr 2012 18:09:03 -0400 (EDT)
Message-ID: <20120404.180903.1873382612616035211.davem@davemloft.net>
References: <1333490531.18626.336.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stigge@antcom.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756925Ab2DDWKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:10:12 -0400
In-Reply-To: <1333490531.18626.336.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Apr 2012 00:02:11 +0200

> Probably a leftover from ancient code...
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Roland Stigge <stigge@antcom.de>

Applied to net-next, thanks Eric.

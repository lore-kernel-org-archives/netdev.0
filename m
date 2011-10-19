From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pptp: fix skb leak in pptp_xmit()
Date: Wed, 19 Oct 2011 02:39:56 -0400 (EDT)
Message-ID: <20111019.023956.173025317313602528.davem@davemloft.net>
References: <1318906907.2571.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60911 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470Ab1JSGkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 02:40:12 -0400
In-Reply-To: <1318906907.2571.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Oct 2011 05:01:47 +0200

> In case we cant transmit skb, we must free it
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Dmitry Kozlov <xeb@mail.ru>

Applied, thanks Eric.

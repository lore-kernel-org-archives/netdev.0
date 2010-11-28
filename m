From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: add netif_tx_queue_frozen_or_stopped
Date: Sun, 28 Nov 2010 10:49:22 -0800 (PST)
Message-ID: <20101128.104922.59685458.davem@davemloft.net>
References: <1290544922.2866.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36573
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753866Ab0K1Ss4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 13:48:56 -0500
In-Reply-To: <1290544922.2866.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Nov 2010 21:42:02 +0100

> When testing struct netdev_queue state against FROZEN bit, we also test
> XOFF bit. We can test both bits at once and save some cycles.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

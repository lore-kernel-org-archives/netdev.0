From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ip: Router Alert RCU conversion
Date: Mon, 07 Jun 2010 21:26:12 -0700 (PDT)
Message-ID: <20100607.212612.35795010.davem@davemloft.net>
References: <1275916328.2545.64.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42346
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752154Ab0FHE0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 00:26:02 -0400
In-Reply-To: <1275916328.2545.64.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Jun 2010 15:12:08 +0200

> Straightforward conversion to RCU.
> 
> One rwlock becomes a spinlock, and is static.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

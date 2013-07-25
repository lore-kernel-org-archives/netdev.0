From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Make devnet_rename_seq static
Date: Wed, 24 Jul 2013 17:57:50 -0700 (PDT)
Message-ID: <20130724.175750.726744281960412667.davem@davemloft.net>
References: <alpine.DEB.2.02.1307231559570.4089@ionos.tec.linutronix.de>
	<alpine.DEB.2.02.1307231612300.4089@ionos.tec.linutronix.de>
	<1374589035.1843.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab3GYA5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:57:51 -0400
In-Reply-To: <1374589035.1843.1.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Jul 2013 07:17:15 -0700

> On Tue, 2013-07-23 at 16:13 +0200, Thomas Gleixner wrote:
>> No users outside net/core/dev.c.
>> 
>> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
>> ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied to net-next, thanks.

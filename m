From: David Miller <davem@davemloft.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Fri, 09 Dec 2011 14:21:17 -0500 (EST)
Message-ID: <20111209.142117.357254752872525966.davem@davemloft.net>
References: <1322773527.2750.27.camel@edumazet-laptop>
	<4ED86B79.4060506@profihost.ag>
	<4EE25B06.7010907@profihost.ag>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jwboyer@gmail.com, hch@infradead.org,
	netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: s.priebe@profihost.ag
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942Ab1LITWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 14:22:45 -0500
In-Reply-To: <4EE25B06.7010907@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Priebe <s.priebe@profihost.ag>
Date: Fri, 09 Dec 2011 20:01:26 +0100

> any news on that? Systems still crashing every now and then. 3.0.13
> was released today but i haven't seen any of them.

I only had time to submit these fixes for 3.1.x-stable, you'll just
have to be incredibly patient.

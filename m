From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: Make temperature warnings/alarms more explicit.
Date: Wed, 29 Apr 2009 17:50:06 -0700 (PDT)
Message-ID: <20090429.175006.118660824.davem@davemloft.net>
References: <1240925799.3200.16.camel@achroite>
	<1240929844.10689.35.camel@localhost.localdomain>
	<1240930084.10689.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48190
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753488AbZD3AuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 20:50:12 -0400
In-Reply-To: <1240930084.10689.39.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Tue, 28 Apr 2009 16:48:04 +0200

> 
> The sfc driver can detect different hardware failures via the
> LM87 system.  One of the failures I have experienced is the
> temperature alarm, but the error message didn't reveal that this
> error was temperature related.  I had to read the code to
> discover that.
> 
> I think that the temperature error should be more explicit, in
> order to warn people before the board is permanently damaged.
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

Ben, ACK or something?

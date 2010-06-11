From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] pktgen: increasing transmission granularity
Date: Thu, 10 Jun 2010 23:08:56 -0700 (PDT)
Message-ID: <20100610.230856.233685392.davem@davemloft.net>
References: <20100609.135040.193710199.davem@davemloft.net>
	<4C10A603.2080402@gmail.com>
	<19473.2154.53423.374255@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.turull@gmail.com, netdev@vger.kernel.org,
	robert@herjulf.net, jens.laas@its.uu.se
To: robert.olsson@its.uu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753161Ab0FKGIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 02:08:46 -0400
In-Reply-To: <19473.2154.53423.374255@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <robert.olsson@its.uu.se>
Date: Thu, 10 Jun 2010 17:44:42 +0200

> So the scheduling of the next transmission is based on the previous
> transmission rather rather than now() + delay.
 ...
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>
> 
> 
>>Daniel Turull wrote: This patch correct a bug in the delay of pktgen.
>>It makes sure the inter-packet interval is accurate.
>>
>>Signed-off-by: Daniel Turull <daniel.turull@gmail.com>

Applied, thanks everyone.

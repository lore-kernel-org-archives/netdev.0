From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: use flow dissector helpers for aRFS
Date: Sun, 29 May 2016 22:39:58 -0700 (PDT)
Message-ID: <20160529.223958.493298847764781570.davem@davemloft.net>
References: <1464281796.5939.96.camel@edumazet-glaptop3.roam.corp.google.com>
	<5747608D.1090509@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbcE3Fj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 01:39:59 -0400
In-Reply-To: <5747608D.1090509@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Thu, 26 May 2016 21:46:05 +0100

> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
> This seems to work in my testing, but I first looked at the flow dissector
> API less than four hours ago, so I might be doing it wrong.
> 
> I still think that this is too big a change for 'net' and that it's better
> to take the original fix now and then I'll respin this patch for net-next
> when it opens up.  But I'm also happy for you to take this now in which
> case I'll respin Jon's patch 2/2 on top of the result.  Your choice.

I definitely prefer this and have applied it, please respin Jon's patch.

Thanks!

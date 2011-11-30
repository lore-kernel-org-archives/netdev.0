From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 10/10] sfc: Support for byte queue limits
Date: Wed, 30 Nov 2011 22:51:45 +0000
Message-ID: <1322693505.2762.46.camel@bwh-desktop>
References: <alpine.DEB.2.00.1111281822060.23687@pokey.mtv.corp.google.com>
	 <1322657043.2403.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111130.171239.236955684775039413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <therbert@google.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18850 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751659Ab1K3Wvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 17:51:49 -0500
In-Reply-To: <20111130.171239.236955684775039413.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-30 at 17:12 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 30 Nov 2011 13:44:03 +0100
> 
> > [PATCH net-next] sfc: fix race in efx_enqueue_skb_tso()
> > 
> > As soon as skb is pushed to hardware, it can be completed and freed, so
> > we should not dereference skb anymore.
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Applied, thanks Eric.

Thanks to all.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

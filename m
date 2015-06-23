From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bridge: multicast: restore router configuration
 on port link down/up
Date: Tue, 23 Jun 2015 03:30:30 -0700 (PDT)
Message-ID: <20150623.033030.1624607645349787543.davem@davemloft.net>
References: <1434702177-20887-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	herbert@gondor.apana.org.au, sashok@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330AbbFWKSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 06:18:42 -0400
In-Reply-To: <1434702177-20887-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Fri, 19 Jun 2015 01:22:57 -0700

> From: Satish Ashok <sashok@cumulusnetworks.com>
> 
> When a port goes through a link down/up the multicast router configuration
> is not restored.
> 
> Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: 0909e11758bd ("bridge: Add multicast_router sysfs entries")
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> v2: Added the acked-by and sent as a separate patch. I plan to repurpose
>     the second patch for net-next, they weren't dependent anyway.

Applied, thanks.
